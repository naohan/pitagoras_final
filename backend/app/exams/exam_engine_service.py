from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy.orm import Session

from app.exams.exceptions import (
    ExamAlreadyCompletedError,
    ExamEngineError,
    ExamNotFoundError,
    ExamNotInProgressError,
    ExamTimeExpiredError,
    InsufficientQuestionsError,
    InvalidOptionError,
    QuestionNotInExamError,
    StudentNotFoundError,
    TemplateNotFoundError,
)
from app.models.answer import StudentAnswer
from app.models.enums import StudentExamStatus
from app.models.exam import ExamTemplate, ExamTemplateQuestion, StudentExam
from app.models.question import Question
from app.models.result import (
    ExamResult,
    ExamResultArea,
    ExamResultComponent,
    ExamResultSubtopic,
    ExamResultTopic,
)
from app.repositories.area_repository import AreaRepository
from app.repositories.exam_result_repository import ExamResultRepository
from app.repositories.exam_template_repository import ExamTemplateRepository
from app.repositories.question_selection_repository import QuestionSelectionRepository
from app.repositories.student_answer_repository import StudentAnswerRepository
from app.repositories.student_exam_repository import StudentExamRepository
from app.repositories.student_repository import StudentRepository


@dataclass
class ExamTimeStatus:
    student_exam_id: int
    status: StudentExamStatus
    started_at: datetime | None
    finished_at: datetime | None
    duration_minutes: int
    elapsed_seconds: int
    remaining_seconds: int
    is_expired: bool


class ExamEngineService:
    """Motor de exÃ¡menes: plantillas, sesiones, respuestas, tiempo y calificaciÃ³n."""

    def __init__(self, session: Session) -> None:
        self._session = session
        self._templates = ExamTemplateRepository(session)
        self._student_exams = StudentExamRepository(session)
        self._answers = StudentAnswerRepository(session)
        self._results = ExamResultRepository(session)
        self._students = StudentRepository(session)
        self._areas = AreaRepository(session)
        self._selection = QuestionSelectionRepository(session)

    def create_exam_template(
        self,
        *,
        admission_process_id: int,
        name: str,
        duration_minutes: int,
        question_count: int,
        auto_select_questions: bool = True,
        question_ids: list[int] | None = None,
    ) -> ExamTemplate:
        template = ExamTemplate(
            admission_process_id=admission_process_id,
            name=name,
            duration_minutes=duration_minutes,
            question_count=question_count,
        )
        self._templates.create(template)

        if auto_select_questions:
            selected = self._select_questions_by_area_weights(
                admission_process_id=admission_process_id,
                question_count=question_count,
            )
            self._attach_questions(template, [q.id for q in selected])
        elif question_ids:
            if len(question_ids) != question_count:
                raise ExamEngineError(
                    f"Expected {question_count} question ids, got {len(question_ids)}",
                    "invalid_question_ids",
                )
            self._attach_questions(template, question_ids)
        else:
            raise ExamEngineError(
                "Provide question_ids or enable auto_select_questions",
                "missing_questions",
            )

        self._session.flush()
        self._session.refresh(template)
        return self._templates.get_with_questions(template.id)  # type: ignore[return-value]

    def start_student_exam(
        self,
        *,
        student_id: int,
        exam_template_id: int,
    ) -> StudentExam:
        if self._students.get_by_id(student_id) is None:
            raise StudentNotFoundError(student_id)

        template = self._templates.get_with_questions(exam_template_id)
        if template is None or not template.is_active:
            raise TemplateNotFoundError(exam_template_id)

        if not template.template_questions:
            raise ExamEngineError(
                "Exam template has no questions",
                "empty_template",
            )

        now = datetime.utcnow()
        student_exam = StudentExam(
            student_id=student_id,
            exam_template_id=exam_template_id,
            status=StudentExamStatus.IN_PROGRESS,
            started_at=now,
        )
        self._student_exams.create(student_exam)

        for item in sorted(template.template_questions, key=lambda x: x.display_order):
            self._answers.create(
                StudentAnswer(
                    student_exam_id=student_exam.id,
                    question_id=item.question_id,
                )
            )

        self._session.flush()
        return self._student_exams.get_with_template_and_questions(student_exam.id)  # type: ignore

    def start_adaptive_simulacro(
        self,
        *,
        student_id: int,
        based_on_student_exam_id: int,
        question_count: int = 15,
    ) -> StudentExam:
        """Simulacro personalizado segÃºn debilidades del diagnÃ³stico y banco ampliado."""
        from app.diagnostics.diagnostic_service import DiagnosticService, PerformanceLevel
        from app.diagnostics.exceptions import DiagnosticNotFoundError, ExamNotCompletedError

        base_exam = self._get_student_exam_or_raise(based_on_student_exam_id)
        if base_exam.student_id != student_id:
            raise ExamEngineError(
                "Diagnostic exam does not belong to this student",
                "exam_not_found",
            )
        if base_exam.exam_template is None:
            raise ExamEngineError("Exam template missing", "template_not_found")

        try:
            diagnostic = DiagnosticService(self._session).get_diagnostic(
                based_on_student_exam_id
            )
        except (DiagnosticNotFoundError, ExamNotCompletedError) as exc:
            raise ExamEngineError(str(exc), "diagnostic_not_ready") from exc

        weak_subtopic_ids = [
            item.entity_id
            for item in diagnostic.subtopics
            if item.level == PerformanceLevel.WEAKNESS
        ]
        exclude_ids = {answer.question_id for answer in base_exam.answers}
        admission_process_id = base_exam.exam_template.admission_process_id

        selected = self._select_adaptive_questions(
            admission_process_id=admission_process_id,
            weak_subtopic_ids=weak_subtopic_ids,
            question_count=question_count,
            exclude_ids=exclude_ids,
        )
        if not selected:
            raise ExamEngineError(
                "No hay preguntas en el banco para el simulacro. "
                "Ejecuta: python -m scripts.seed.seed_extra_questions y "
                "python -m scripts.seed.seed_rubinos_questions",
                "insufficient_questions",
            )

        actual_count = len(selected)
        template = self.create_exam_template(
            admission_process_id=admission_process_id,
            name=f"Simulacro adaptativo ({actual_count} preguntas)",
            duration_minutes=max(30, actual_count * 2),
            question_count=actual_count,
            auto_select_questions=False,
            question_ids=[question.id for question in selected],
        )
        return self.start_student_exam(
            student_id=student_id,
            exam_template_id=template.id,
        )

    def _select_adaptive_questions(
        self,
        *,
        admission_process_id: int,
        weak_subtopic_ids: list[int],
        question_count: int,
        exclude_ids: set[int],
    ) -> list[Question]:
        selected: list[Question] = []
        selected_ids: set[int] = set()

        weak_quota = 0
        if weak_subtopic_ids:
            weak_quota = max(1, round(question_count * 0.6))
            per_subtopic = max(1, weak_quota // len(weak_subtopic_ids))
            for subtopic_id in weak_subtopic_ids:
                batch = self._selection.list_active_by_subtopic_id(
                    subtopic_id,
                    limit=per_subtopic,
                    exclude_ids=selected_ids | exclude_ids,
                )
                for question in batch:
                    if question.id not in selected_ids:
                        selected.append(question)
                        selected_ids.add(question.id)

        remaining = question_count - len(selected)
        if remaining > 0:
            batch = self._selection.list_active_by_admission_process(
                admission_process_id,
                limit=remaining + len(weak_subtopic_ids),
                exclude_ids=selected_ids | exclude_ids,
            )
            for question in batch:
                if len(selected) >= question_count:
                    break
                if question.id not in selected_ids:
                    selected.append(question)
                    selected_ids.add(question.id)

        # Banco pequeÃ±o (solo seed_demo): relajar exclusiÃ³n del diagnÃ³stico.
        if len(selected) < question_count:
            batch = self._selection.list_active_by_admission_process(
                admission_process_id,
                limit=question_count - len(selected),
                exclude_ids=selected_ids,
            )
            for question in batch:
                if len(selected) >= question_count:
                    break
                if question.id not in selected_ids:
                    selected.append(question)
                    selected_ids.add(question.id)

        return selected[:question_count]

    def get_time_status(self, student_exam_id: int) -> ExamTimeStatus:
        student_exam = self._get_student_exam_or_raise(student_exam_id)
        template = student_exam.exam_template
        if template is None:
            template = self._templates.get_by_id(student_exam.exam_template_id)
        duration_minutes = template.duration_minutes if template else 0

        elapsed = 0
        remaining = duration_minutes * 60
        is_expired = False

        if student_exam.started_at:
            elapsed = int((datetime.utcnow() - student_exam.started_at).total_seconds())
            remaining = max(0, duration_minutes * 60 - elapsed)
            is_expired = (
                student_exam.status == StudentExamStatus.IN_PROGRESS
                and elapsed >= duration_minutes * 60
            )

        return ExamTimeStatus(
            student_exam_id=student_exam.id,
            status=student_exam.status,
            started_at=student_exam.started_at,
            finished_at=student_exam.finished_at,
            duration_minutes=duration_minutes,
            elapsed_seconds=elapsed,
            remaining_seconds=remaining,
            is_expired=is_expired,
        )

    def submit_answer(
        self,
        *,
        student_exam_id: int,
        question_id: int,
        selected_option_id: int | None,
        time_seconds: int | None = None,
    ) -> StudentAnswer:
        student_exam = self._get_student_exam_or_raise(student_exam_id)
        self._ensure_in_progress(student_exam)
        self._check_and_expire(student_exam)

        if not self._question_in_exam(student_exam, question_id):
            raise QuestionNotInExamError(question_id)

        answer = self._answers.get_by_exam_and_question(student_exam_id, question_id)
        if answer is None:
            raise ExamEngineError("Answer slot not found", "answer_not_found")

        is_correct: bool | None = None
        if selected_option_id is not None:
            question = self._get_question_from_exam(student_exam, question_id)
            option = next((o for o in question.options if o.id == selected_option_id), None)
            if option is None:
                raise InvalidOptionError(selected_option_id)
            is_correct = option.is_correct

        answer.selected_option_id = selected_option_id
        answer.is_correct = is_correct
        answer.time_seconds = time_seconds
        answer.answered_at = datetime.utcnow()

        self._session.flush()
        self._session.refresh(answer)
        return answer

    def toggle_save_answer(
        self,
        *,
        student_exam_id: int,
        question_id: int,
        is_saved: bool,
    ) -> StudentAnswer:
        student_exam = self._get_student_exam_or_raise(student_exam_id)

        if not self._question_in_exam(student_exam, question_id):
            raise QuestionNotInExamError(question_id)

        answer = self._answers.get_by_exam_and_question(student_exam_id, question_id)
        if answer is None:
            raise ExamEngineError("Answer slot not found", "answer_not_found")

        answer.is_saved = is_saved
        self._session.flush()
        self._session.refresh(answer)
        return answer

    def list_saved_answers(
        self,
        student_id: int,
        *,
        correctness: str = "all",
    ) -> list[StudentAnswer]:
        if self._students.get_by_id(student_id) is None:
            raise StudentNotFoundError(student_id)
        filter_value: Literal["all", "correct", "incorrect"] = "all"
        if correctness in ("correct", "incorrect"):
            filter_value = correctness  # type: ignore[assignment]
        return list(
            self._answers.list_saved_by_student_id(
                student_id,
                correctness=filter_value,
            )
        )

    def get_exam_review(
        self,
        student_exam_id: int,
        *,
        correctness: str = "all",
    ) -> list[tuple[StudentAnswer, int]]:
        student_exam = self._student_exams.get_for_review(student_exam_id)
        if student_exam is None:
            raise ExamNotFoundError(student_exam_id)

        if student_exam.status != StudentExamStatus.COMPLETED:
            raise ExamEngineError(
                "Exam must be completed to review answers",
                "exam_not_completed",
            )

        template = student_exam.exam_template
        if template is None:
            raise ExamEngineError("Exam template missing", "template_not_found")

        answer_by_question = {a.question_id: a for a in student_exam.answers}
        ordered: list[tuple[StudentAnswer, int]] = []

        for item in sorted(template.template_questions, key=lambda x: x.display_order):
            answer = answer_by_question.get(item.question_id)
            if answer is None:
                continue
            if correctness == "correct" and answer.is_correct is not True:
                continue
            if correctness == "incorrect" and answer.is_correct is not False:
                continue
            if correctness == "saved" and not answer.is_saved:
                continue
            ordered.append((answer, item.display_order))

        return ordered

    def finish_exam(self, student_exam_id: int) -> StudentExam:
        student_exam = self._student_exams.get_for_grading(student_exam_id)
        if student_exam is None:
            raise ExamNotFoundError(student_exam_id)

        if student_exam.status == StudentExamStatus.COMPLETED:
            raise ExamAlreadyCompletedError()

        if student_exam.status == StudentExamStatus.IN_PROGRESS:
            self._mark_expired_if_needed(student_exam)

        if student_exam.status not in (
            StudentExamStatus.IN_PROGRESS,
            StudentExamStatus.EXPIRED,
        ):
            raise ExamNotInProgressError(student_exam.status.value)

        self._grade_unanswered(student_exam)
        self._save_results(student_exam)

        student_exam.status = StudentExamStatus.COMPLETED
        student_exam.finished_at = datetime.utcnow()

        self._session.flush()
        return self._student_exams.get_with_result(student_exam_id)  # type: ignore

    def _select_questions_by_area_weights(
        self,
        *,
        admission_process_id: int,
        question_count: int,
    ) -> list[Question]:
        areas = list(
            self._areas.list_by_admission_process_id(
                admission_process_id,
                limit=1000,
                active_only=True,
            )
        )
        if not areas:
            raise ExamEngineError(
                "No areas found for admission process",
                "no_areas",
            )

        selected: list[Question] = []
        selected_ids: set[int] = set()
        weights = [float(area.weight_percent) for area in areas]
        total_weight = sum(weights) or 1.0

        allocations: list[int] = []
        remaining = question_count
        for i, area in enumerate(areas):
            if i == len(areas) - 1:
                count = remaining
            else:
                count = round(question_count * weights[i] / total_weight)
                remaining -= count
            allocations.append(max(0, count))

        for area, count in zip(areas, allocations):
            if count <= 0:
                continue
            batch = self._selection.list_active_by_area_id(
                area.id,
                limit=count,
                exclude_ids=selected_ids,
            )
            for question in batch:
                if question.id not in selected_ids:
                    selected.append(question)
                    selected_ids.add(question.id)

        if len(selected) < question_count:
            extra = self._selection.list_active_by_admission_process(
                admission_process_id,
                limit=question_count - len(selected),
                exclude_ids=selected_ids,
            )
            for question in extra:
                if question.id not in selected_ids:
                    selected.append(question)
                    selected_ids.add(question.id)

        if len(selected) < question_count:
            raise InsufficientQuestionsError(question_count, len(selected))

        return selected[:question_count]

    def _attach_questions(self, template: ExamTemplate, question_ids: list[int]) -> None:
        for order, question_id in enumerate(question_ids, start=1):
            template.template_questions.append(
                ExamTemplateQuestion(
                    exam_template_id=template.id,
                    question_id=question_id,
                    display_order=order,
                )
            )

    def _get_student_exam_or_raise(self, student_exam_id: int) -> StudentExam:
        student_exam = self._student_exams.get_with_template_and_questions(student_exam_id)
        if student_exam is None:
            raise ExamNotFoundError(student_exam_id)
        return student_exam

    def _ensure_in_progress(self, student_exam: StudentExam) -> None:
        if student_exam.status != StudentExamStatus.IN_PROGRESS:
            raise ExamNotInProgressError(student_exam.status.value)

    def _check_and_expire(self, student_exam: StudentExam) -> None:
        if self._mark_expired_if_needed(student_exam):
            raise ExamTimeExpiredError()

    def _mark_expired_if_needed(self, student_exam: StudentExam) -> bool:
        if student_exam.status != StudentExamStatus.IN_PROGRESS or not student_exam.started_at:
            return False
        template = student_exam.exam_template or self._templates.get_by_id(
            student_exam.exam_template_id
        )
        if template is None:
            return False
        deadline = student_exam.started_at + timedelta(minutes=template.duration_minutes)
        if datetime.utcnow() >= deadline:
            student_exam.status = StudentExamStatus.EXPIRED
            self._session.flush()
            return True
        return False

    def _question_in_exam(self, student_exam: StudentExam, question_id: int) -> bool:
        template = student_exam.exam_template
        if template is None:
            return False
        return any(tq.question_id == question_id for tq in template.template_questions)

    def _get_question_from_exam(self, student_exam: StudentExam, question_id: int) -> Question:
        template = student_exam.exam_template
        for tq in template.template_questions:
            if tq.question_id == question_id and tq.question is not None:
                return tq.question
        raise QuestionNotInExamError(question_id)

    def _grade_unanswered(self, student_exam: StudentExam) -> None:
        for answer in student_exam.answers:
            if answer.is_correct is None:
                answer.is_correct = False

    def _save_results(self, student_exam: StudentExam) -> None:
        total = len(student_exam.answers)
        correct = sum(1 for a in student_exam.answers if a.is_correct)
        score = Decimal("0.00")
        if total > 0:
            score = (Decimal(correct) / Decimal(total) * Decimal(100)).quantize(
                Decimal("0.01"),
                rounding=ROUND_HALF_UP,
            )

        duration_seconds: int | None = None
        if student_exam.started_at:
            end = student_exam.finished_at or datetime.utcnow()
            duration_seconds = int((end - student_exam.started_at).total_seconds())

        result = ExamResult(
            student_exam_id=student_exam.id,
            total_questions=total,
            correct_answers=correct,
            score_percent=score,
            duration_seconds=duration_seconds,
            calculated_at=datetime.utcnow(),
        )

        area_stats: dict[int, list[bool]] = defaultdict(list)
        component_stats: dict[int, list[bool]] = defaultdict(list)
        topic_stats: dict[int, list[bool]] = defaultdict(list)
        subtopic_stats: dict[int, list[bool]] = defaultdict(list)

        for answer in student_exam.answers:
            question = answer.question
            if question is None or question.subtopic is None:
                continue
            subtopic = question.subtopic
            topic = subtopic.topic
            component = topic.component if topic else None
            area = component.area if component else None
            is_correct = bool(answer.is_correct)

            subtopic_stats[subtopic.id].append(is_correct)
            if topic:
                topic_stats[topic.id].append(is_correct)
            if component:
                component_stats[component.id].append(is_correct)
            if area:
                area_stats[area.id].append(is_correct)

        area_rows = self._build_breakdown_rows(
            student_exam.id, area_stats, ExamResultArea, "area_id"
        )
        component_rows = self._build_breakdown_rows(
            student_exam.id, component_stats, ExamResultComponent, "component_id"
        )
        topic_rows = self._build_breakdown_rows(
            student_exam.id, topic_stats, ExamResultTopic, "topic_id"
        )
        subtopic_rows = self._build_breakdown_rows(
            student_exam.id, subtopic_stats, ExamResultSubtopic, "subtopic_id"
        )

        self._results.save_breakdown(
            result,
            area_rows,
            component_rows,
            topic_rows,
            subtopic_rows,
        )

    def _build_breakdown_rows(
        self,
        student_exam_id: int,
        stats: dict[int, list[bool]],
        model_cls: type,
        id_field: str,
    ) -> list:
        rows = []
        for entity_id, values in stats.items():
            total = len(values)
            correct = sum(1 for v in values if v)
            percent = Decimal("0.00")
            if total > 0:
                percent = (Decimal(correct) / Decimal(total) * Decimal(100)).quantize(
                    Decimal("0.01"),
                    rounding=ROUND_HALF_UP,
                )
            rows.append(
                model_cls(
                    student_exam_id=student_exam_id,
                    **{
                        id_field: entity_id,
                        "total_questions": total,
                        "correct_answers": correct,
                        "score_percent": percent,
                    },
                )
            )
        return rows
