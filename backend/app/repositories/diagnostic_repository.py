from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.academic import Area, Component, Subtopic, Topic
from app.models.answer import StudentAnswer
from app.models.exam import StudentExam
from app.models.question import Question
from app.models.result import (
    ExamResult,
    ExamResultArea,
    ExamResultComponent,
    ExamResultSubtopic,
    ExamResultTopic,
)


class DiagnosticRepository:
    """Consultas para diagnóstico con jerarquía académica cargada."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def get_exam_with_diagnostic_snapshots(self, student_exam_id: int) -> StudentExam | None:
        stmt = (
            select(StudentExam)
            .where(StudentExam.id == student_exam_id)
            .options(
                selectinload(StudentExam.result),
                selectinload(StudentExam.result_areas).selectinload(ExamResultArea.area),
                selectinload(StudentExam.result_components).selectinload(
                    ExamResultComponent.component
                ),
                selectinload(StudentExam.result_topics).selectinload(ExamResultTopic.topic),
                selectinload(StudentExam.result_subtopics)
                .selectinload(ExamResultSubtopic.subtopic)
                .selectinload(Subtopic.topic),
            )
        )
        return self._session.scalars(stmt).first()

    def get_exam_for_recalculation(self, student_exam_id: int) -> StudentExam | None:
        stmt = (
            select(StudentExam)
            .where(StudentExam.id == student_exam_id)
            .options(
                selectinload(StudentExam.result),
                selectinload(StudentExam.answers)
                .selectinload(StudentAnswer.question)
                .selectinload(Question.subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area),
            )
        )
        return self._session.scalars(stmt).first()
