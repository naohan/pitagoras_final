from __future__ import annotations

from decimal import Decimal
from typing import TYPE_CHECKING, List

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    ForeignKey,
    Index,
    Numeric,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.mysql import MEDIUMTEXT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.admission_exam_target import AdmissionExamTarget
    from app.models.curriculum import CurriculumMapping
    from app.models.exam import ExamTemplate
    from app.models.question import Question
    from app.models.result import (
        ExamResultArea,
        ExamResultComponent,
        ExamResultSubtopic,
        ExamResultTopic,
    )


class University(Base, TimestampMixin):
    __tablename__ = "universities"
    __table_args__ = (UniqueConstraint("code", name="uq_universities_code"),)

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(20), nullable=False)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    country: Mapped[str] = mapped_column(String(60), nullable=False, server_default="PE")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    careers: Mapped[List[Career]] = relationship(
        back_populates="university",
        cascade="save-update, merge",
    )
    exam_targets: Mapped[List["AdmissionExamTarget"]] = relationship(
        back_populates="university",
        cascade="save-update, merge",
    )


class Career(Base, TimestampMixin):
    __tablename__ = "careers"
    __table_args__ = (
        UniqueConstraint("university_id", "code", name="uq_careers_university_code"),
        Index("idx_careers_university_id", "university_id"),
        CheckConstraint(
            "target_score IS NULL OR (target_score >= 0 AND target_score <= 100)",
            name="chk_careers_target_score",
        ),
        CheckConstraint(
            "score_min IS NULL OR (score_min >= 0 AND score_min <= 100)",
            name="chk_careers_score_min",
        ),
        CheckConstraint(
            "score_max IS NULL OR (score_max >= 0 AND score_max <= 100)",
            name="chk_careers_score_max",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    university_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("universities.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    code: Mapped[str] = mapped_column(String(30), nullable=False)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")
    # Techo histórico / meta de ingreso (UI Inicio: "Meta {universidad}")
    target_score: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)
    # Rango orientativo mostrado en onboarding de carrera
    score_min: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)
    score_max: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)

    university: Mapped[University] = relationship(back_populates="careers")
    admission_processes: Mapped[List[AdmissionProcess]] = relationship(
        back_populates="career",
        cascade="save-update, merge",
    )


class AdmissionProcess(Base, TimestampMixin):
    __tablename__ = "admission_processes"
    __table_args__ = (
        UniqueConstraint("career_id", "year", name="uq_admission_processes_career_year"),
        Index("idx_admission_processes_career_id", "career_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    career_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("careers.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    year: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    career: Mapped[Career] = relationship(back_populates="admission_processes")
    areas: Mapped[List[Area]] = relationship(
        back_populates="admission_process",
        cascade="save-update, merge",
    )
    exam_templates: Mapped[List[ExamTemplate]] = relationship(
        back_populates="admission_process",
        cascade="save-update, merge",
    )


class Area(Base, TimestampMixin):
    __tablename__ = "areas"
    __table_args__ = (
        UniqueConstraint("admission_process_id", "name", name="uq_areas_process_name"),
        Index("idx_areas_admission_process_id", "admission_process_id"),
        CheckConstraint(
            "weight_percent >= 0 AND weight_percent <= 100",
            name="chk_areas_weight_percent",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    admission_process_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("admission_processes.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    weight_percent: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="0")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    admission_process: Mapped[AdmissionProcess] = relationship(back_populates="areas")
    components: Mapped[List[Component]] = relationship(
        back_populates="area",
        cascade="save-update, merge",
    )
    exam_result_areas: Mapped[List[ExamResultArea]] = relationship(
        back_populates="area",
        cascade="save-update, merge",
    )


class Component(Base, TimestampMixin):
    __tablename__ = "components"
    __table_args__ = (
        UniqueConstraint("area_id", "name", name="uq_components_area_name"),
        Index("idx_components_area_id", "area_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    area_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("areas.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="0")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    area: Mapped[Area] = relationship(back_populates="components")
    topics: Mapped[List[Topic]] = relationship(
        back_populates="component",
        cascade="save-update, merge",
    )
    exam_result_components: Mapped[List[ExamResultComponent]] = relationship(
        back_populates="component",
        cascade="save-update, merge",
    )


class Topic(Base, TimestampMixin):
    __tablename__ = "topics"
    __table_args__ = (
        UniqueConstraint("component_id", "name", name="uq_topics_component_name"),
        Index("idx_topics_component_id", "component_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    component_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("components.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="0")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    component: Mapped[Component] = relationship(back_populates="topics")
    subtopics: Mapped[List[Subtopic]] = relationship(
        back_populates="topic",
        cascade="save-update, merge",
    )
    exam_result_topics: Mapped[List[ExamResultTopic]] = relationship(
        back_populates="topic",
        cascade="save-update, merge",
    )


class Subtopic(Base, TimestampMixin):
    __tablename__ = "subtopics"
    __table_args__ = (
        UniqueConstraint("topic_id", "name", name="uq_subtopics_topic_name"),
        Index("idx_subtopics_topic_id", "topic_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    topic_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("topics.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    theory_text: Mapped[str | None] = mapped_column(
        Text().with_variant(MEDIUMTEXT(), "mysql"),
        nullable=True,
    )
    display_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, server_default="0")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="1")

    topic: Mapped[Topic] = relationship(back_populates="subtopics")
    questions: Mapped[List[Question]] = relationship(
        back_populates="subtopic",
        cascade="save-update, merge",
    )
    exam_result_subtopics: Mapped[List[ExamResultSubtopic]] = relationship(
        back_populates="subtopic",
        cascade="save-update, merge",
    )
    curriculum_mappings: Mapped[List["CurriculumMapping"]] = relationship(
        back_populates="subtopic",
        cascade="save-update, merge",
    )
