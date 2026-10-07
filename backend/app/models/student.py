from __future__ import annotations

from typing import TYPE_CHECKING, List

from sqlalchemy import BigInteger, Boolean, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import StudyPurpose
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.academic import AdmissionProcess, Career, Subtopic, University
    from app.models.exam import StudentExam
    from app.models.study_activity import StudyActivity
    from app.models.user import User


class Student(Base, TimestampMixin):
    __tablename__ = "students"
    __table_args__ = (
        UniqueConstraint("email", name="uq_students_email"),
        UniqueConstraint("user_id", name="uq_students_user_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    # admission = postular; topic_learning = aprender un tema (CNEB / colegio)
    purpose: Mapped[str | None] = mapped_column(String(32), nullable=True)

    # Perfil de preparación (diseño onboarding / Inicio del frontend)
    university_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("universities.id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    career_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("careers.id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    admission_process_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("admission_processes.id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )
    exam_target_code: Mapped[str | None] = mapped_column(String(40), nullable=True)
    focus_subtopic_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("subtopics.id", ondelete="SET NULL", onupdate="CASCADE"),
        nullable=True,
    )

    user: Mapped[User | None] = relationship(back_populates="student")
    university: Mapped[University | None] = relationship()
    career: Mapped[Career | None] = relationship()
    admission_process: Mapped[AdmissionProcess | None] = relationship()
    focus_subtopic: Mapped[Subtopic | None] = relationship()
    student_exams: Mapped[List[StudentExam]] = relationship(
        back_populates="student",
        cascade="save-update, merge",
    )
    study_activities: Mapped[List[StudyActivity]] = relationship(
        back_populates="student",
        cascade="save-update, merge",
    )
