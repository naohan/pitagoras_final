from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.academic import Component, Subtopic, Topic
from app.models.answer import StudentAnswer
from app.models.exam import ExamTemplate, ExamTemplateQuestion, StudentExam
from app.models.question import Question
from app.repositories.base import BaseRepository


class StudentExamRepository(BaseRepository[StudentExam]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, StudentExam)

    def get_with_template_and_questions(self, student_exam_id: int) -> StudentExam | None:
        stmt = (
            select(StudentExam)
            .where(StudentExam.id == student_exam_id)
            .options(
                selectinload(StudentExam.exam_template)
                .selectinload(ExamTemplate.template_questions)
                .selectinload(ExamTemplateQuestion.question)
                .selectinload(Question.options),
                selectinload(StudentExam.answers),
            )
        )
        return self._session.scalars(stmt).first()

    def get_for_grading(self, student_exam_id: int) -> StudentExam | None:
        stmt = (
            select(StudentExam)
            .where(StudentExam.id == student_exam_id)
            .options(
                selectinload(StudentExam.exam_template),
                selectinload(StudentExam.answers)
                .selectinload(StudentAnswer.question)
                .selectinload(Question.subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area),
                selectinload(StudentExam.answers)
                .selectinload(StudentAnswer.selected_option),
            )
        )
        return self._session.scalars(stmt).first()

    def get_for_review(self, student_exam_id: int) -> StudentExam | None:
        stmt = (
            select(StudentExam)
            .where(StudentExam.id == student_exam_id)
            .options(
                selectinload(StudentExam.exam_template)
                .selectinload(ExamTemplate.template_questions),
                selectinload(StudentExam.answers)
                .selectinload(StudentAnswer.question)
                .selectinload(Question.options),
                selectinload(StudentExam.answers)
                .selectinload(StudentAnswer.question)
                .selectinload(Question.subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area),
            )
        )
        return self._session.scalars(stmt).first()

    def get_with_result(self, student_exam_id: int) -> StudentExam | None:
        stmt = (
            select(StudentExam)
            .where(StudentExam.id == student_exam_id)
            .options(
                selectinload(StudentExam.result),
                selectinload(StudentExam.result_areas),
                selectinload(StudentExam.result_components),
                selectinload(StudentExam.result_topics),
                selectinload(StudentExam.result_subtopics),
            )
        )
        return self._session.scalars(stmt).first()

    def list_by_student_id(
        self,
        student_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
    ) -> Sequence[StudentExam]:
        stmt = (
            select(StudentExam)
            .where(StudentExam.student_id == student_id)
            .order_by(StudentExam.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return self._session.scalars(stmt).all()
