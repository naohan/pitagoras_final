from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING, List

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    UniqueConstraint,
)
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import StudentExamStatus
from app.models.mixins import CreatedAtMixin, TimestampMixin

if TYPE_CHECKING:
    from app.models.academic import AdmissionProcess
    from app.models.answer import StudentAnswer
    from app.models.question import Question
    from app.models.result import (
        ExamResult,
        ExamResultArea,
        ExamResultComponent,
        ExamResultSubtopic,
        ExamResultTopic,
    )
    from app.models.student import Student


class ExamTemplate(Base, TimestampMixin):
    __tablename__ = "exam_templates"
    __table_args__ = (
        Index("idx_exam_templates_admission_process_id", "admission_process_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    admission_process_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("admission_processes.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    duration_minutes: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    question_count: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    admission_process: Mapped[AdmissionProcess] = relationship(back_populates="exam_templates")
    template_questions: Mapped[List[ExamTemplateQuestion]] = relationship(
        back_populates="exam_template",
        cascade="all, delete-orphan",
        order_by="ExamTemplateQuestion.display_order",
    )
    student_exams: Mapped[List[StudentExam]] = relationship(
        back_populates="exam_template",
        cascade="save-update, merge",
    )


class ExamTemplateQuestion(Base, CreatedAtMixin):
    __tablename__ = "exam_template_questions"
    __table_args__ = (
        UniqueConstraint(
            "exam_template_id",
            "question_id",
            name="uq_etq_template_question",
        ),
        UniqueConstraint(
            "exam_template_id",
            "display_order",
            name="uq_etq_template_order",
        ),
        Index("idx_etq_template_order", "exam_template_id", "display_order"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    exam_template_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("exam_templates.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    question_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("questions.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False)

    exam_template: Mapped[ExamTemplate] = relationship(back_populates="template_questions")
    question: Mapped[Question] = relationship(back_populates="exam_template_questions")


class StudentExam(Base, TimestampMixin):
    __tablename__ = "student_exams"
    __table_args__ = (
        Index("idx_student_exams_student_status", "student_id", "status"),
        Index("idx_student_exams_template_id", "exam_template_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("students.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    exam_template_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("exam_templates.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    status: Mapped[StudentExamStatus] = mapped_column(
        SAEnum(
            StudentExamStatus,
            name="student_exam_status",
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        nullable=False,
        server_default=StudentExamStatus.PENDING.value,
    )
    started_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    student: Mapped[Student] = relationship(back_populates="student_exams")
    exam_template: Mapped[ExamTemplate] = relationship(back_populates="student_exams")
    answers: Mapped[List[StudentAnswer]] = relationship(
        back_populates="student_exam",
        cascade="all, delete-orphan",
    )
    result: Mapped[ExamResult | None] = relationship(
        back_populates="student_exam",
        cascade="all, delete-orphan",
        uselist=False,
    )
    result_areas: Mapped[List[ExamResultArea]] = relationship(
        back_populates="student_exam",
        cascade="all, delete-orphan",
    )
    result_components: Mapped[List[ExamResultComponent]] = relationship(
        back_populates="student_exam",
        cascade="all, delete-orphan",
    )
    result_topics: Mapped[List[ExamResultTopic]] = relationship(
        back_populates="student_exam",
        cascade="all, delete-orphan",
    )
    result_subtopics: Mapped[List[ExamResultSubtopic]] = relationship(
        back_populates="student_exam",
        cascade="all, delete-orphan",
    )
