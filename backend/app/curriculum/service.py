"""Origen curricular (CNEB / temario de admisión) ligado a subtemas."""

from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.curriculum.constants import (
    CNEB_AREA_ORDER,
    EXCLUDED_LEARNING_AREAS,
    FRAMEWORK_UI_LABELS,
)
from app.models.academic import Component, Subtopic, Topic
from app.models.curriculum import CurriculumMapping
from app.models.enums import CurriculumFramework

# Re-export para callers que importaban desde service.
__all__ = [
    "CNEB_AREA_ORDER",
    "EXCLUDED_LEARNING_AREAS",
    "FRAMEWORK_UI_LABELS",
    "CurriculumArea",
    "CurriculumCourse",
    "CurriculumService",
    "LearnableTopic",
]


@dataclass(frozen=True)
class LearnableTopic:
    subtopic_id: int
    subtopic_name: str
    topic_name: str
    course_name: str
    area_name: str
    theory_text: str
    framework: CurriculumFramework
    external_code: str
    external_label: str
    origin_label: str


@dataclass(frozen=True)
class CurriculumCourse:
    course_id: int
    course_name: str
    topics: list[LearnableTopic]


@dataclass(frozen=True)
class CurriculumArea:
    area_name: str
    courses: list[CurriculumCourse]


class CurriculumService:
    def __init__(self, session: Session) -> None:
        self._session = session

    def list_for_subtopic(self, subtopic_id: int) -> list[CurriculumMapping]:
        stmt = (
            select(CurriculumMapping)
            .where(CurriculumMapping.subtopic_id == subtopic_id)
            .order_by(CurriculumMapping.framework, CurriculumMapping.id)
        )
        return list(self._session.scalars(stmt).all())

    def list_learnable_topics(
        self,
        *,
        framework: CurriculumFramework = CurriculumFramework.CNEB_SECUNDARIA,
        limit: int = 300,
    ) -> list[LearnableTopic]:
        """Catálogo plano para modo «aprender un tema» (base escolar CNEB)."""
        items = self._collect_learnable(framework=framework)
        items.sort(
            key=lambda x: (x.area_name, x.course_name, x.topic_name, x.subtopic_name)
        )
        return items[:limit]

    def get_learnable_topic(
        self,
        subtopic_id: int,
        *,
        framework: CurriculumFramework = CurriculumFramework.CNEB_SECUNDARIA,
    ) -> LearnableTopic | None:
        """Un tema con teoría (para relectura desde Estudiar)."""
        for item in self._collect_learnable(framework=framework):
            if item.subtopic_id == subtopic_id:
                return item

        # Fallback: subtema activo aunque el mapping use otro framework.
        stmt = (
            select(Subtopic)
            .where(Subtopic.id == subtopic_id, Subtopic.is_active.is_(True))
            .options(
                selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area)
            )
        )
        subtopic = self._session.scalars(stmt).first()
        if subtopic is None:
            return None
        topic = subtopic.topic
        component = topic.component if topic else None
        area = component.area if component else None
        area_name = area.name if area else ""
        if area_name in EXCLUDED_LEARNING_AREAS:
            return None
        mappings = self.list_for_subtopic(subtopic_id)
        mapping = next(
            (
                m
                for m in mappings
                if (
                    m.framework
                    if isinstance(m.framework, CurriculumFramework)
                    else CurriculumFramework(m.framework)
                )
                == framework
            ),
            mappings[0] if mappings else None,
        )
        if mapping is None:
            return LearnableTopic(
                subtopic_id=subtopic.id,
                subtopic_name=subtopic.name,
                topic_name=topic.name if topic else "",
                course_name=component.name if component else "",
                area_name=area_name,
                theory_text=subtopic.theory_text or "",
                framework=framework,
                external_code="",
                external_label="",
                origin_label=FRAMEWORK_UI_LABELS[framework],
            )
        fw = (
            mapping.framework
            if isinstance(mapping.framework, CurriculumFramework)
            else CurriculumFramework(mapping.framework)
        )
        return LearnableTopic(
            subtopic_id=subtopic.id,
            subtopic_name=subtopic.name,
            topic_name=topic.name if topic else "",
            course_name=component.name if component else "",
            area_name=area_name,
            theory_text=subtopic.theory_text or "",
            framework=fw,
            external_code=mapping.external_code,
            external_label=mapping.external_label,
            origin_label=FRAMEWORK_UI_LABELS[fw],
        )

    def list_catalog(
        self,
        *,
        framework: CurriculumFramework = CurriculumFramework.CNEB_SECUNDARIA,
    ) -> list[CurriculumArea]:
        """Áreas CNEB → cursos internos → temas (deduplicado por nombre)."""
        items = self._collect_learnable(framework=framework)
        areas: dict[str, dict[str, CurriculumCourse]] = {}
        course_order: dict[str, list[str]] = {}

        for item in items:
            area_bucket = areas.setdefault(item.area_name, {})
            if item.area_name not in course_order:
                course_order[item.area_name] = []

            # Resolve course_id from first occurrence; topics carry course via component
            course = area_bucket.get(item.course_name)
            if course is None:
                course_id = self._course_id_for_subtopic(item.subtopic_id) or 0
                course = CurriculumCourse(
                    course_id=course_id,
                    course_name=item.course_name,
                    topics=[],
                )
                area_bucket[item.course_name] = course
                course_order[item.area_name].append(item.course_name)

            # Replace frozen dataclass topics list by rebuilding
            area_bucket[item.course_name] = CurriculumCourse(
                course_id=course.course_id,
                course_name=course.course_name,
                topics=[*course.topics, item],
            )

        result: list[CurriculumArea] = []
        area_names = sorted(
            areas.keys(),
            key=lambda name: (
                CNEB_AREA_ORDER.index(name)
                if name in CNEB_AREA_ORDER
                else 100 + len(name),
                name,
            ),
        )
        for area_name in area_names:
            courses = [
                areas[area_name][course_name]
                for course_name in course_order[area_name]
            ]
            result.append(CurriculumArea(area_name=area_name, courses=courses))
        return result

    def _collect_learnable(
        self,
        *,
        framework: CurriculumFramework,
    ) -> list[LearnableTopic]:
        stmt = (
            select(CurriculumMapping)
            .where(CurriculumMapping.framework == framework)
            .options(
                selectinload(CurriculumMapping.subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area)
            )
            .order_by(CurriculumMapping.id)
        )
        rows = list(self._session.scalars(stmt).all())
        # Deduplicar por (área, curso, subtema) para no repetir multi-universidad
        seen: set[tuple[str, str, str]] = set()
        items: list[LearnableTopic] = []
        for row in rows:
            subtopic = row.subtopic
            if subtopic is None or not subtopic.is_active:
                continue
            topic = subtopic.topic
            component = topic.component if topic else None
            area = component.area if component else None
            area_name = area.name if area else ""
            if area_name in EXCLUDED_LEARNING_AREAS:
                continue
            if area is not None and not area.is_active:
                continue
            course_name = component.name if component else ""
            topic_name = topic.name if topic else ""
            key = (area_name, course_name, subtopic.name)
            if key in seen:
                continue
            seen.add(key)
            fw = (
                row.framework
                if isinstance(row.framework, CurriculumFramework)
                else CurriculumFramework(row.framework)
            )
            items.append(
                LearnableTopic(
                    subtopic_id=subtopic.id,
                    subtopic_name=subtopic.name,
                    topic_name=topic_name,
                    course_name=course_name,
                    area_name=area_name,
                    theory_text=subtopic.theory_text or "",
                    framework=fw,
                    external_code=row.external_code,
                    external_label=row.external_label,
                    origin_label=FRAMEWORK_UI_LABELS[fw],
                )
            )
        return items

    def _course_id_for_subtopic(self, subtopic_id: int) -> int | None:
        stmt = (
            select(Component.id)
            .join(Topic, Topic.component_id == Component.id)
            .join(Subtopic, Subtopic.topic_id == Topic.id)
            .where(Subtopic.id == subtopic_id)
        )
        return self._session.scalars(stmt).first()

    def origin_labels_for_subtopics(
        self,
        subtopic_ids: list[int],
    ) -> dict[int, list[str]]:
        if not subtopic_ids:
            return {}
        stmt = select(CurriculumMapping).where(
            CurriculumMapping.subtopic_id.in_(subtopic_ids)
        )
        rows = list(self._session.scalars(stmt).all())
        result: dict[int, list[str]] = {sid: [] for sid in subtopic_ids}
        seen: dict[int, set[str]] = {sid: set() for sid in subtopic_ids}
        for row in rows:
            label = FRAMEWORK_UI_LABELS.get(
                row.framework
                if isinstance(row.framework, CurriculumFramework)
                else CurriculumFramework(row.framework),
                str(row.framework),
            )
            bucket = seen[row.subtopic_id]
            if label not in bucket:
                bucket.add(label)
                result[row.subtopic_id].append(label)
        return result

    def ensure_mapping(
        self,
        *,
        subtopic_id: int,
        framework: CurriculumFramework,
        external_code: str,
        external_label: str,
    ) -> CurriculumMapping:
        stmt = select(CurriculumMapping).where(
            CurriculumMapping.subtopic_id == subtopic_id,
            CurriculumMapping.framework == framework,
            CurriculumMapping.external_code == external_code,
        )
        existing = self._session.scalars(stmt).first()
        if existing is not None:
            if existing.external_label != external_label:
                existing.external_label = external_label
            return existing

        mapping = CurriculumMapping(
            subtopic_id=subtopic_id,
            framework=framework,
            external_code=external_code,
            external_label=external_label,
        )
        self._session.add(mapping)
        self._session.flush()
        return mapping
