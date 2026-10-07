from typing import Literal, Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.academic import Area, Component, Subtopic, Topic
from app.models.answer import StudentAnswer
from app.models.exam import StudentExam
from app.models.question import Question
from app.repositories.base import BaseRepository


class StudentAnswerRepository(BaseRepository[StudentAnswer]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, StudentAnswer)

    def get_by_exam_and_question(
        self,
        student_exam_id: int,
        question_id: int,
    ) -> StudentAnswer | None:
        stmt = select(StudentAnswer).where(
            StudentAnswer.student_exam_id == student_exam_id,
            StudentAnswer.question_id == question_id,
        )
        return self._session.scalars(stmt).first()

    def list_saved_by_student_id(
        self,
        student_id: int,
        *,
        correctness: Literal["all", "correct", "incorrect"] = "all",
    ) -> Sequence[StudentAnswer]:
        stmt = (
            select(StudentAnswer)
            .join(StudentExam, StudentAnswer.student_exam_id == StudentExam.id)
            .where(
                StudentExam.student_id == student_id,
                StudentAnswer.is_saved.is_(True),
            )
            .options(
                selectinload(StudentAnswer.question)
                .selectinload(Question.options),
                selectinload(StudentAnswer.question)
                .selectinload(Question.subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area),
            )
            .order_by(StudentAnswer.answered_at.desc(), StudentAnswer.id.desc())
        )
        if correctness == "correct":
            stmt = stmt.where(StudentAnswer.is_correct.is_(True))
        elif correctness == "incorrect":
            stmt = stmt.where(StudentAnswer.is_correct.is_(False))
        return self._session.scalars(stmt).all()
