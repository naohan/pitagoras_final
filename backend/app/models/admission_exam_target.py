from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import BigInteger, Boolean, ForeignKey, Index, SmallInteger, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.academic import University


class AdmissionExamTarget(Base, TimestampMixin):
    """Modalidad de postulación (Quinto, CEPRE, Ordinario, etc.) por universidad.

    Alinea el diseño del onboarding del frontend (antes hardcodeado solo UNSA).
    """

    __tablename__ = "admission_exam_targets"
    __table_args__ = (
        UniqueConstraint("university_id", "code", name="uq_admission_exam_targets_uni_code"),
        Index("idx_admission_exam_targets_university_id", "university_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    university_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("universities.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    code: Mapped[str] = mapped_column(String(40), nullable=False)
    label: Mapped[str] = mapped_column(String(100), nullable=False)
    short_label: Mapped[str] = mapped_column(String(40), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    simulacro_focus: Mapped[str] = mapped_column(Text, nullable=False)
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="0")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    university: Mapped[University] = relationship(back_populates="exam_targets")
