from __future__ import annotations

from datetime import date, datetime
from typing import TYPE_CHECKING

from sqlalchemy import BigInteger, Date, DateTime, ForeignKey, Index, String, UniqueConstraint, func
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import StudyActivityType

if TYPE_CHECKING:
    from app.models.student import Student


class StudyActivity(Base):
    """Registro diario de actividad de estudio (para rachas)."""

    __tablename__ = "study_activities"
    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "activity_type",
            "activity_date",
            "ref_id",
            name="uq_study_activities_student_type_date_ref",
        ),
        Index("idx_study_activities_student_date", "student_id", "activity_date"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    student_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("students.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    activity_type: Mapped[StudyActivityType] = mapped_column(
        SAEnum(
            StudyActivityType,
            name="study_activity_type",
            values_callable=lambda x: [e.value for e in x],
        ),
        nullable=False,
    )
    activity_date: Mapped[date] = mapped_column(Date, nullable=False)
    ref_id: Mapped[str] = mapped_column(String(64), nullable=False, server_default="")
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )

    student: Mapped[Student] = relationship(back_populates="study_activities")
