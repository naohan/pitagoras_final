"""Herramientas de estudio sin LLM: flashcards y mapa conceptual."""

from __future__ import annotations

from dataclasses import dataclass, field
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.curriculum.service import CurriculumService
from app.diagnostics.diagnostic_service import DiagnosticService, PerformanceLevel
from app.diagnostics.rules import STRENGTH_THRESHOLD, WEAKNESS_THRESHOLD
from app.models.academic import Area, Component, Subtopic, Topic
from app.models.answer import StudentAnswer
from app.models.exam import ExamTemplate, StudentExam
from app.models.question import Question
from app.repositories.question_repository import QuestionRepository
from app.recommendations.recommendation_service import RecommendationService


@dataclass
class FlashcardItem:
    question_id: int
    front: str
    back: str
    subtopic_name: str
    source: str
    subtopic_id: int | None = None
    curriculum_origins: list[str] = field(default_factory=list)


@dataclass
class ConceptMapNode:
    id: int
    name: str
    entity_type: str
    score_percent: float | None = None
    level: str | None = None
    children: list[ConceptMapNode] = field(default_factory=list)


class FlashcardService:
    def __init__(self, session: Session) -> None:
        self._session = session
        self._diagnostics = DiagnosticService(session)
        self._recommendations = RecommendationService(session)
        self._questions = QuestionRepository(session)
        self._curriculum = CurriculumService(session)

    def get_flashcards(self, student_exam_id: int, *, limit: int = 20) -> list[FlashcardItem]:
        diagnostic = self._diagnostics.get_diagnostic(student_exam_id)
        plan = self._recommendations.get_study_plan(student_exam_id)
        cards: list[FlashcardItem] = []
        seen_ids: set[int] = set()

        wrong_answers = self._list_wrong_answers(student_exam_id)
        for answer in wrong_answers:
            if len(cards) >= limit:
                break
            card = self._to_flashcard(answer.question, source="wrong_answer")
            if card and card.question_id not in seen_ids:
                cards.append(card)
                seen_ids.add(card.question_id)

        weak_ids = [
            item.entity_id
            for item in diagnostic.subtopics
            if item.score_percent < WEAKNESS_THRESHOLD
        ]
        if not weak_ids:
            weak_ids = [
                rec.entity_id
                for rec in plan.recommendations
                if rec.entity_type == "subtopic"
            ][:3]

        for subtopic_id in weak_ids:
            if len(cards) >= limit:
                break
            for question in self._questions.list_by_subtopic_id_with_options(
                subtopic_id, limit=5, active_only=True
            ):
                if len(cards) >= limit:
                    break
                if question.id in seen_ids:
                    continue
                card = self._to_flashcard(question, source="weak_subtopic")
                if card:
                    cards.append(card)
                    seen_ids.add(card.question_id)

        return self._attach_curriculum_origins(cards[:limit])

    def _attach_curriculum_origins(self, cards: list[FlashcardItem]) -> list[FlashcardItem]:
        subtopic_ids = [c.subtopic_id for c in cards if c.subtopic_id is not None]
        origins_map = self._curriculum.origin_labels_for_subtopics(subtopic_ids)
        for card in cards:
            if card.subtopic_id is not None:
                card.curriculum_origins = origins_map.get(card.subtopic_id, [])
        return cards

    def _list_wrong_answers(self, student_exam_id: int) -> list[StudentAnswer]:
        stmt = (
            select(StudentAnswer)
            .where(
                StudentAnswer.student_exam_id == student_exam_id,
                StudentAnswer.is_correct.is_(False),
            )
            .options(
                selectinload(StudentAnswer.question).selectinload(Question.options),
                selectinload(StudentAnswer.question)
                .selectinload(Question.subtopic),
            )
            .order_by(StudentAnswer.id)
        )
        return list(self._session.scalars(stmt).all())

    def _to_flashcard(self, question: Question | None, *, source: str) -> FlashcardItem | None:
        if question is None:
            return None
        correct = next((opt for opt in question.options if opt.is_correct), None)
        if correct is None:
            return None

        front = question.stem if len(question.stem) <= 220 else f"{question.stem[:217]}..."
        back_parts = [f"{correct.label}) {correct.text}"]
        if question.explanation:
            back_parts.append(question.explanation)
        subtopic_name = question.subtopic.name if question.subtopic else "General"

        return FlashcardItem(
            question_id=question.id,
            front=front,
            back="\n\n".join(back_parts),
            subtopic_name=subtopic_name,
            source=source,
            subtopic_id=question.subtopic_id,
        )


class ConceptMapService:
    def __init__(self, session: Session) -> None:
        self._session = session
        self._diagnostics = DiagnosticService(session)

    def get_concept_map(self, student_exam_id: int) -> list[ConceptMapNode]:
        admission_id = self._resolve_admission_process_id(student_exam_id)
        if admission_id is None:
            return []

        diagnostic = self._diagnostics.get_diagnostic(student_exam_id)
        score_by_subtopic = {
            item.entity_id: float(item.score_percent) for item in diagnostic.subtopics
        }
        level_by_subtopic = {
            item.entity_id: item.level.value for item in diagnostic.subtopics
        }

        stmt = (
            select(Area)
            .where(Area.admission_process_id == admission_id, Area.is_active.is_(True))
            .options(
                selectinload(Area.components)
                .selectinload(Component.topics)
                .selectinload(Topic.subtopics),
            )
            .order_by(Area.display_order)
        )
        areas = list(self._session.scalars(stmt).all())
        return [
            self._area_node(area, score_by_subtopic, level_by_subtopic) for area in areas
        ]

    def _resolve_admission_process_id(self, student_exam_id: int) -> int | None:
        stmt = (
            select(ExamTemplate.admission_process_id)
            .join(StudentExam, StudentExam.exam_template_id == ExamTemplate.id)
            .where(StudentExam.id == student_exam_id)
        )
        return self._session.scalar(stmt)

    def _area_node(
        self,
        area: Area,
        scores: dict[int, float],
        levels: dict[int, str],
    ) -> ConceptMapNode:
        components = sorted(area.components, key=lambda c: c.display_order)
        return ConceptMapNode(
            id=area.id,
            name=area.name,
            entity_type="area",
            children=[
                self._component_node(component, scores, levels) for component in components
            ],
        )

    def _component_node(
        self,
        component: Component,
        scores: dict[int, float],
        levels: dict[int, str],
    ) -> ConceptMapNode:
        topics = sorted(component.topics, key=lambda t: t.display_order)
        return ConceptMapNode(
            id=component.id,
            name=component.name,
            entity_type="component",
            children=[self._topic_node(topic, scores, levels) for topic in topics],
        )

    def _topic_node(
        self,
        topic: Topic,
        scores: dict[int, float],
        levels: dict[int, str],
    ) -> ConceptMapNode:
        subtopics = sorted(topic.subtopics, key=lambda s: s.display_order)
        return ConceptMapNode(
            id=topic.id,
            name=topic.name,
            entity_type="topic",
            children=[
                self._subtopic_node(subtopic, scores, levels) for subtopic in subtopics
            ],
        )

    def _subtopic_node(
        self,
        subtopic: Subtopic,
        scores: dict[int, float],
        levels: dict[int, str],
    ) -> ConceptMapNode:
        score = scores.get(subtopic.id)
        level = levels.get(subtopic.id)
        if score is not None and level is None:
            level = self._level_from_score(Decimal(str(score))).value
        return ConceptMapNode(
            id=subtopic.id,
            name=subtopic.name,
            entity_type="subtopic",
            score_percent=score,
            level=level,
            children=[],
        )

    @staticmethod
    def _level_from_score(score: Decimal) -> PerformanceLevel:
        if score >= STRENGTH_THRESHOLD:
            return PerformanceLevel.STRENGTH
        if score < WEAKNESS_THRESHOLD:
            return PerformanceLevel.WEAKNESS
        return PerformanceLevel.NEUTRAL
