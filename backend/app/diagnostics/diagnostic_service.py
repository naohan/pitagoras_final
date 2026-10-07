from dataclasses import dataclass, field
from decimal import Decimal, ROUND_HALF_UP
from enum import Enum

from sqlalchemy.orm import Session

from app.diagnostics.exceptions import DiagnosticNotFoundError, ExamNotCompletedError
from app.diagnostics.rules import STRENGTH_THRESHOLD, WEAKNESS_THRESHOLD
from app.models.enums import StudentExamStatus
from app.models.exam import StudentExam
from app.models.result import (
    ExamResultArea,
    ExamResultComponent,
    ExamResultSubtopic,
    ExamResultTopic,
)
from app.repositories.diagnostic_repository import DiagnosticRepository


class PerformanceLevel(str, Enum):
    STRENGTH = "strength"
    NEUTRAL = "neutral"
    WEAKNESS = "weakness"


@dataclass
class DiagnosticItem:
    entity_id: int
    name: str
    total_questions: int
    correct_answers: int
    score_percent: Decimal
    level: PerformanceLevel
    parent_name: str | None = None


@dataclass
class DiagnosticReport:
    student_exam_id: int
    global_score_percent: Decimal
    total_questions: int
    correct_answers: int
    areas: list[DiagnosticItem] = field(default_factory=list)
    components: list[DiagnosticItem] = field(default_factory=list)
    topics: list[DiagnosticItem] = field(default_factory=list)
    subtopics: list[DiagnosticItem] = field(default_factory=list)
    strengths: list[str] = field(default_factory=list)
    weaknesses: list[str] = field(default_factory=list)


class DiagnosticService:
    """Calcula y clasifica el perfil académico post-examen sin IA."""

    def __init__(self, session: Session) -> None:
        self._session = session
        self._repo = DiagnosticRepository(session)

    def get_diagnostic(self, student_exam_id: int) -> DiagnosticReport:
        student_exam = self._repo.get_exam_with_diagnostic_snapshots(student_exam_id)
        if student_exam is None:
            raise DiagnosticNotFoundError(student_exam_id)

        if student_exam.status != StudentExamStatus.COMPLETED:
            raise ExamNotCompletedError(student_exam_id)

        if student_exam.result and student_exam.result_areas:
            report = self._build_from_snapshots(student_exam)
        else:
            student_exam = self._repo.get_exam_for_recalculation(student_exam_id)
            if student_exam is None:
                raise DiagnosticNotFoundError(student_exam_id)
            report = self._build_from_answers(student_exam)

        self._apply_strengths_weaknesses(report)
        return report

    def _build_from_snapshots(self, student_exam: StudentExam) -> DiagnosticReport:
        result = student_exam.result
        if result is None:
            raise DiagnosticNotFoundError(student_exam.id)

        return DiagnosticReport(
            student_exam_id=student_exam.id,
            global_score_percent=result.score_percent,
            total_questions=result.total_questions,
            correct_answers=result.correct_answers,
            areas=self._map_area_rows(student_exam.result_areas),
            components=self._map_component_rows(student_exam.result_components),
            topics=self._map_topic_rows(student_exam.result_topics),
            subtopics=self._map_subtopic_rows(student_exam.result_subtopics),
        )

    def _build_from_answers(self, student_exam: StudentExam) -> DiagnosticReport:
        area_stats: dict[int, dict] = {}
        component_stats: dict[int, dict] = {}
        topic_stats: dict[int, dict] = {}
        subtopic_stats: dict[int, dict] = {}

        for answer in student_exam.answers:
            question = answer.question
            if question is None or question.subtopic is None:
                continue

            subtopic = question.subtopic
            topic = subtopic.topic
            component = topic.component if topic else None
            area = component.area if component else None
            is_correct = bool(answer.is_correct)

            self._accumulate(
                subtopic_stats,
                subtopic.id,
                subtopic.name,
                is_correct,
                parent_name=topic.name if topic else None,
            )
            if topic:
                self._accumulate(topic_stats, topic.id, topic.name, is_correct)
            if component:
                self._accumulate(component_stats, component.id, component.name, is_correct)
            if area:
                self._accumulate(area_stats, area.id, area.name, is_correct)

        total = len(student_exam.answers)
        correct = sum(1 for a in student_exam.answers if a.is_correct)
        global_score = self._percent(correct, total)

        return DiagnosticReport(
            student_exam_id=student_exam.id,
            global_score_percent=global_score,
            total_questions=total,
            correct_answers=correct,
            areas=self._stats_to_items(area_stats),
            components=self._stats_to_items(component_stats),
            topics=self._stats_to_items(topic_stats),
            subtopics=self._stats_to_items(subtopic_stats),
        )

    def _map_area_rows(self, rows: list[ExamResultArea]) -> list[DiagnosticItem]:
        return [
            DiagnosticItem(
                entity_id=row.area_id,
                name=row.area.name if row.area else f"Area {row.area_id}",
                total_questions=row.total_questions,
                correct_answers=row.correct_answers,
                score_percent=row.score_percent,
                level=self._classify(row.score_percent),
            )
            for row in rows
        ]

    def _map_component_rows(self, rows: list[ExamResultComponent]) -> list[DiagnosticItem]:
        return [
            DiagnosticItem(
                entity_id=row.component_id,
                name=row.component.name if row.component else f"Component {row.component_id}",
                total_questions=row.total_questions,
                correct_answers=row.correct_answers,
                score_percent=row.score_percent,
                level=self._classify(row.score_percent),
            )
            for row in rows
        ]

    def _map_topic_rows(self, rows: list[ExamResultTopic]) -> list[DiagnosticItem]:
        return [
            DiagnosticItem(
                entity_id=row.topic_id,
                name=row.topic.name if row.topic else f"Topic {row.topic_id}",
                total_questions=row.total_questions,
                correct_answers=row.correct_answers,
                score_percent=row.score_percent,
                level=self._classify(row.score_percent),
            )
            for row in rows
        ]

    def _map_subtopic_rows(self, rows: list[ExamResultSubtopic]) -> list[DiagnosticItem]:
        return [
            DiagnosticItem(
                entity_id=row.subtopic_id,
                name=row.subtopic.name if row.subtopic else f"Subtopic {row.subtopic_id}",
                total_questions=row.total_questions,
                correct_answers=row.correct_answers,
                score_percent=row.score_percent,
                level=self._classify(row.score_percent),
                parent_name=(
                    row.subtopic.topic.name
                    if row.subtopic and row.subtopic.topic
                    else None
                ),
            )
            for row in rows
        ]

    def _accumulate(
        self,
        bucket: dict[int, dict],
        entity_id: int,
        name: str,
        is_correct: bool,
        *,
        parent_name: str | None = None,
    ) -> None:
        if entity_id not in bucket:
            bucket[entity_id] = {
                "name": name,
                "correct": 0,
                "total": 0,
                "parent_name": parent_name,
            }
        bucket[entity_id]["total"] += 1
        if is_correct:
            bucket[entity_id]["correct"] += 1

    def _stats_to_items(self, stats: dict[int, dict]) -> list[DiagnosticItem]:
        items = []
        for entity_id, data in stats.items():
            score = self._percent(data["correct"], data["total"])
            items.append(
                DiagnosticItem(
                    entity_id=entity_id,
                    name=data["name"],
                    total_questions=data["total"],
                    correct_answers=data["correct"],
                    score_percent=score,
                    level=self._classify(score),
                    parent_name=data.get("parent_name"),
                )
            )
        return sorted(items, key=lambda x: x.score_percent)

    def _percent(self, correct: int, total: int) -> Decimal:
        if total == 0:
            return Decimal("0.00")
        return (Decimal(correct) / Decimal(total) * Decimal(100)).quantize(
            Decimal("0.01"),
            rounding=ROUND_HALF_UP,
        )

    def _classify(self, score_percent: Decimal) -> PerformanceLevel:
        if score_percent >= STRENGTH_THRESHOLD:
            return PerformanceLevel.STRENGTH
        if score_percent < WEAKNESS_THRESHOLD:
            return PerformanceLevel.WEAKNESS
        return PerformanceLevel.NEUTRAL

    def _apply_strengths_weaknesses(self, report: DiagnosticReport) -> None:
        if report.subtopics:
            report.strengths = sorted(
                {
                    self._label_with_parent(item)
                    for item in report.subtopics
                    if item.level == PerformanceLevel.STRENGTH
                }
            )
            report.weaknesses = sorted(
                {
                    self._label_with_parent(item)
                    for item in report.subtopics
                    if item.level == PerformanceLevel.WEAKNESS
                }
            )
            return

        report.strengths = sorted(
            {item.name for item in report.topics if item.level == PerformanceLevel.STRENGTH}
        )
        report.weaknesses = sorted(
            {item.name for item in report.topics if item.level == PerformanceLevel.WEAKNESS}
        )

    @staticmethod
    def _label_with_parent(item: DiagnosticItem) -> str:
        if item.parent_name:
            return f"{item.parent_name} → {item.name}"
        return item.name
