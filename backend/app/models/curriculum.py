from __future__ import annotations

from typing import TYPE_CHECKING

from sqlalchemy import BigInteger, ForeignKey, Index, String, UniqueConstraint
from sqlalchemy import Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import CurriculumFramework
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.academic import Subtopic


class CurriculumMapping(Base, TimestampMixin):
    """Mapeo de subtemas del árbol de admisión a CNEB o temario/prospecto."""

    __tablename__ = "curriculum_mappings"
    __table_args__ = (
        UniqueConstraint(
            "subtopic_id",
            "framework",
            "external_code",
            name="uq_curriculum_mappings_subtopic_framework_code",
        ),
        Index("idx_curriculum_mappings_subtopic_id", "subtopic_id"),
        Index("idx_curriculum_mappings_framework", "framework"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    subtopic_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("subtopics.id", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    framework: Mapped[CurriculumFramework] = mapped_column(
        SAEnum(
            CurriculumFramework,
            name="curriculum_framework",
            values_callable=lambda x: [e.value for e in x],
        ),
        nullable=False,
    )
    external_code: Mapped[str] = mapped_column(String(64), nullable=False)
    external_label: Mapped[str] = mapped_column(String(255), nullable=False)

    subtopic: Mapped[Subtopic] = relationship(back_populates="curriculum_mappings")
