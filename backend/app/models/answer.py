from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    SmallInteger,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.mixins import CreatedAtMixin

if TYPE_CHECKING:
    from app.models.exam import StudentExam
    from app.models.question import Question, QuestionOption


class StudentAnswer(Base, CreatedAtMixin):
    __tablename__ = "student_answers"
    __table_args__ = (
        UniqueConstraint(
            "student_exam_id",
            "question_id",
            name="uq_student_answers_exam_question",
        ),
        Index("idx_student_answers_exam_id", "student_exam_id"),
        Index("idx_student_answers_question_id", "question_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_exam_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("student_exams.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    question_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("questions.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    selected_option_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("question_options.id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    is_correct: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    is_saved: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    time_seconds: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)
    answered_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    student_exam: Mapped[StudentExam] = relationship(back_populates="answers")
    question: Mapped[Question] = relationship(back_populates="student_answers")
    selected_option: Mapped[QuestionOption | None] = relationship(
        back_populates="student_answers",
    )
