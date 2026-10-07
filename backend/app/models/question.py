from __future__ import annotations

from typing import TYPE_CHECKING, Any, List

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy import Enum as SAEnum
from sqlalchemy.dialects.mysql import JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import QuestionLevel
from app.models.mixins import CreatedAtMixin, TimestampMixin

if TYPE_CHECKING:
    from app.models.academic import Subtopic
    from app.models.answer import StudentAnswer
    from app.models.exam import ExamTemplateQuestion


class Question(Base, TimestampMixin):
    __tablename__ = "questions"
    __table_args__ = (
        Index("idx_questions_subtopic_active", "subtopic_id", "is_active"),
        Index("idx_questions_difficulty", "difficulty"),
        CheckConstraint("difficulty BETWEEN 1 AND 5", name="chk_questions_difficulty"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    subtopic_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("subtopics.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    stem: Mapped[str] = mapped_column(Text, nullable=False)
    explanation: Mapped[str | None] = mapped_column(Text, nullable=True)
    difficulty: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="3")
    level: Mapped[QuestionLevel] = mapped_column(
        SAEnum(
            QuestionLevel,
            name="question_level",
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        nullable=False,
        server_default=QuestionLevel.INTERMEDIATE.value,
    )
    avg_time_seconds: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)
    tags: Mapped[dict[str, Any] | list[Any] | None] = mapped_column(JSON, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    subtopic: Mapped[Subtopic] = relationship(back_populates="questions")
    options: Mapped[List[QuestionOption]] = relationship(
        back_populates="question",
        cascade="all, delete-orphan",
        order_by="QuestionOption.display_order",
    )
    exam_template_questions: Mapped[List[ExamTemplateQuestion]] = relationship(
        back_populates="question",
        cascade="save-update, merge",
    )
    student_answers: Mapped[List[StudentAnswer]] = relationship(
        back_populates="question",
        cascade="save-update, merge",
    )


class QuestionOption(Base, CreatedAtMixin):
    __tablename__ = "question_options"
    __table_args__ = (
        UniqueConstraint("question_id", "label", name="uq_question_options_question_label"),
        Index("idx_question_options_question_id", "question_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    question_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("questions.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    label: Mapped[str] = mapped_column(String(1), nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="0")
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="0")

    question: Mapped[Question] = relationship(back_populates="options")
    student_answers: Mapped[List[StudentAnswer]] = relationship(
        back_populates="selected_option",
        cascade="save-update, merge",
    )
