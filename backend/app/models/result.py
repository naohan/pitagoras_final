from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import TYPE_CHECKING

from sqlalchemy import (
    BigInteger,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    SmallInteger,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.mixins import CreatedAtMixin

if TYPE_CHECKING:
    from app.models.academic import Area, Component, Subtopic, Topic
    from app.models.exam import StudentExam


class ExamResult(Base, CreatedAtMixin):
    __tablename__ = "exam_results"
    __table_args__ = (
        UniqueConstraint("student_exam_id", name="uq_exam_results_student_exam"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_exam_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("student_exams.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    total_questions: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    correct_answers: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    score_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    duration_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    calculated_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    student_exam: Mapped[StudentExam] = relationship(back_populates="result")


class ExamResultArea(Base):
    __tablename__ = "exam_result_areas"
    __table_args__ = (
        UniqueConstraint("student_exam_id", "area_id", name="uq_era_exam_area"),
        Index("idx_era_student_exam_id", "student_exam_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_exam_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("student_exams.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    area_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("areas.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    total_questions: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    correct_answers: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    score_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)

    student_exam: Mapped[StudentExam] = relationship(back_populates="result_areas")
    area: Mapped[Area] = relationship(back_populates="exam_result_areas")


class ExamResultComponent(Base):
    __tablename__ = "exam_result_components"
    __table_args__ = (
        UniqueConstraint(
            "student_exam_id",
            "component_id",
            name="uq_erc_exam_component",
        ),
        Index("idx_erc_student_exam_id", "student_exam_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_exam_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("student_exams.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    component_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("components.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    total_questions: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    correct_answers: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    score_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)

    student_exam: Mapped[StudentExam] = relationship(back_populates="result_components")
    component: Mapped[Component] = relationship(back_populates="exam_result_components")


class ExamResultTopic(Base):
    __tablename__ = "exam_result_topics"
    __table_args__ = (
        UniqueConstraint("student_exam_id", "topic_id", name="uq_ert_exam_topic"),
        Index("idx_ert_student_exam_id", "student_exam_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_exam_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("student_exams.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    topic_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("topics.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    total_questions: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    correct_answers: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    score_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)

    student_exam: Mapped[StudentExam] = relationship(back_populates="result_topics")
    topic: Mapped[Topic] = relationship(back_populates="exam_result_topics")


class ExamResultSubtopic(Base):
    __tablename__ = "exam_result_subtopics"
    __table_args__ = (
        UniqueConstraint(
            "student_exam_id",
            "subtopic_id",
            name="uq_erst_exam_subtopic",
        ),
        Index("idx_erst_student_exam_id", "student_exam_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_exam_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("student_exams.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    subtopic_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("subtopics.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    total_questions: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    correct_answers: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    score_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)

    student_exam: Mapped[StudentExam] = relationship(back_populates="result_subtopics")
    subtopic: Mapped[Subtopic] = relationship(back_populates="exam_result_subtopics")
