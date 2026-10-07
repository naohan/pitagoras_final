"""Seed CNEB para enseñar (sin Religión / Arte / Ed. Física) + teoría por tema.

Uso (desde backend/):
    python -m scripts.migrate.migrate_subtopic_theory
    python -m scripts.seed.seed_cneb_secondary
"""

from __future__ import annotations

import re
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.curriculum.service import CurriculumService
from app.database.session import SessionLocal
from app.models.academic import (
    AdmissionProcess,
    Area,
    Career,
    Component,
    Subtopic,
    Topic,
    University,
)
from app.models.enums import CurriculumFramework
from scripts.curriculum.cneb_catalog import CNEB_FULL_CATALOG, EXCLUDED_AREA_NAMES
from scripts.curriculum.cneb_extra_topics import EXTRA_TEACHING_TOPICS
from scripts.seed.seed_academic import ensure_engineering_math_tree


def _catalog_nodes():
    return list(CNEB_FULL_CATALOG) + list(EXTRA_TEACHING_TOPICS)


def _university_code(university: University) -> str:
    if university.code and university.code.strip():
        return re.sub(r"[^A-Za-z0-9]", "", university.code).upper()[:12]
    initials = "".join(
        part[0] for part in university.name.split() if part and part[0].isalpha()
    )
    return (initials or "UNI").upper()[:12]


def _ensure_area(
    db: Session,
    admission_id: int,
    name: str,
    weight: Decimal,
    order: int,
) -> Area:
    stmt = select(Area).where(Area.admission_process_id == admission_id, Area.name == name)
    area = db.scalars(stmt).first()
    if area is not None:
        area.display_order = order
        area.is_active = True
        return area
    area = Area(
        admission_process_id=admission_id,
        name=name,
        weight_percent=weight,
        display_order=order,
        is_active=True,
    )
    db.add(area)
    db.flush()
    return area


def _deactivate_excluded_areas(db: Session, admission_id: int) -> None:
    stmt = select(Area).where(
        Area.admission_process_id == admission_id,
        Area.name.in_(tuple(EXCLUDED_AREA_NAMES)),
    )
    for area in db.scalars(stmt).all():
        area.is_active = False


def _ensure_component(db: Session, area_id: int, name: str, order: int) -> Component:
    stmt = select(Component).where(Component.area_id == area_id, Component.name == name)
    component = db.scalars(stmt).first()
    if component is not None:
        component.display_order = order
        component.is_active = True
        return component
    component = Component(
        area_id=area_id, name=name, display_order=order, is_active=True
    )
    db.add(component)
    db.flush()
    return component


def _ensure_topic(db: Session, component_id: int, name: str, order: int) -> Topic:
    stmt = select(Topic).where(Topic.component_id == component_id, Topic.name == name)
    topic = db.scalars(stmt).first()
    if topic is not None:
        topic.display_order = order
        topic.is_active = True
        return topic
    topic = Topic(
        component_id=component_id, name=name, display_order=order, is_active=True
    )
    db.add(topic)
    db.flush()
    return topic


def _ensure_subtopic(
    db: Session,
    *,
    admission_process_id: int,
    topic: Topic,
    name: str,
    order: int,
    theory: str,
) -> Subtopic:
    stmt = (
        select(Subtopic)
        .join(Topic)
        .join(Component)
        .join(Area)
        .where(
            Area.admission_process_id == admission_process_id,
            Subtopic.name == name,
        )
    )
    existing = db.scalars(stmt).first()
    if existing is not None:
        existing.topic_id = topic.id
        existing.display_order = order
        existing.is_active = True
        # No pisar teoría enriquecida (Wikipedia / desarrollo largo).
        current = (existing.theory_text or "").strip()
        if not current:
            existing.theory_text = theory
        elif "wikipedia.org" not in current and len(theory) > len(current):
            existing.theory_text = theory
        return existing

    subtopic = Subtopic(
        topic_id=topic.id,
        name=name,
        display_order=order,
        is_active=True,
        theory_text=theory,
    )
    db.add(subtopic)
    db.flush()
    return subtopic


def _ensure_university(db: Session, code: str, name: str) -> University:
    stmt = select(University).where(
        (University.code == code) | (University.name == name)
    )
    uni = db.scalars(stmt).first()
    if uni is not None:
        return uni
    uni = University(code=code, name=name, country="PE", is_active=True)
    db.add(uni)
    db.flush()
    return uni


def _ensure_career(db: Session, university_id: int, code: str, name: str) -> Career:
    stmt = select(Career).where(Career.university_id == university_id, Career.code == code)
    career = db.scalars(stmt).first()
    if career is not None:
        return career
    career = Career(
        university_id=university_id, code=code, name=name, is_active=True
    )
    db.add(career)
    db.flush()
    return career


def _ensure_admission_process(db: Session, career_id: int, year: int = 2026) -> AdmissionProcess:
    stmt = select(AdmissionProcess).where(
        AdmissionProcess.career_id == career_id,
        AdmissionProcess.year == year,
    )
    process = db.scalars(stmt).first()
    if process is not None:
        return process
    process = AdmissionProcess(
        career_id=career_id,
        name=f"Admisión {year}",
        year=year,
        description="Proceso de admisión (temario / balotario / prospecto)",
        is_active=True,
    )
    db.add(process)
    db.flush()
    return process


def _ensure_multi_university_catalog(db: Session) -> None:
    unsa = _ensure_university(db, "UNSA", "Universidad Nacional de San Agustín")
    ucsm = _ensure_university(db, "UCSM", "Universidad Católica de Santa María")
    for uni, careers in (
        (unsa, (("SIS", "Ingeniería de Sistemas"), ("CIV", "Ingeniería Civil"))),
        (ucsm, (("SIS", "Ingeniería de Sistemas"),)),
    ):
        for code, name in careers:
            career = _ensure_career(db, uni.id, code, name)
            _ensure_admission_process(db, career.id)


def _list_admission_processes(db: Session) -> list[tuple[AdmissionProcess, Career, University]]:
    stmt = (
        select(AdmissionProcess)
        .options(
            selectinload(AdmissionProcess.career).selectinload(Career.university),
        )
        .where(AdmissionProcess.is_active.is_(True))
        .order_by(AdmissionProcess.id.asc())
    )
    rows: list[tuple[AdmissionProcess, Career, University]] = []
    for process in db.scalars(stmt).all():
        career = process.career
        if career is None or career.university is None:
            continue
        rows.append((process, career, career.university))
    return rows


def _seed_process(
    db: Session,
    curriculum: CurriculumService,
    process: AdmissionProcess,
    university: University,
) -> int:
    ensure_engineering_math_tree(db, process.id)
    _deactivate_excluded_areas(db, process.id)

    acronym = _university_code(university)
    course_orders: dict[int, dict[str, int]] = {}
    topic_orders: dict[int, dict[str, int]] = {}
    mapped = 0

    for node in _catalog_nodes():
        if node.area_name in EXCLUDED_AREA_NAMES:
            continue
        weight = Decimal("100.00") if node.area_name == "Matemática" else Decimal("0")
        area = _ensure_area(
            db, process.id, node.area_name, weight, node.area_order
        )

        area_courses = course_orders.setdefault(area.id, {})
        if node.course_name not in area_courses:
            area_courses[node.course_name] = len(area_courses) + 1
        component = _ensure_component(
            db, area.id, node.course_name, area_courses[node.course_name]
        )

        component_topics = topic_orders.setdefault(component.id, {})
        if node.topic_name not in component_topics:
            component_topics[node.topic_name] = len(component_topics) + 1
        topic = _ensure_topic(
            db, component.id, node.topic_name, component_topics[node.topic_name]
        )

        subtopic = _ensure_subtopic(
            db,
            admission_process_id=process.id,
            topic=topic,
            name=node.subtopic_name,
            order=mapped + 1,
            theory=node.theory,
        )
        curriculum.ensure_mapping(
            subtopic_id=subtopic.id,
            framework=CurriculumFramework.CNEB_SECUNDARIA,
            external_code=node.cneb_code,
            external_label=node.cneb_label,
        )
        curriculum.ensure_mapping(
            subtopic_id=subtopic.id,
            framework=CurriculumFramework.ADMISSION_TEMARIO,
            external_code=f"{acronym}-{node.temario_suffix}",
            external_label=f"Balotario {acronym} — {node.temario_label}",
        )
        mapped += 1

    return mapped


def seed() -> None:
    db = SessionLocal()
    try:
        _ensure_multi_university_catalog(db)
        processes = _list_admission_processes(db)
        if not processes:
            print("No hay procesos de admisión. Ejecuta seed_demo primero.")
            return

        curriculum = CurriculumService(db)
        total = 0
        for process, career, university in processes:
            n = _seed_process(db, curriculum, process, university)
            total += n
            print(
                f"  {university.code} / {career.name}: "
                f"{n} temas con teoría (sin Arte/EF/Religión)"
            )

        db.commit()
        nodes = _catalog_nodes()
        areas = sorted({n.area_name for n in nodes if n.area_name not in EXCLUDED_AREA_NAMES})
        print(
            f"Seed listo. Procesos: {len(processes)}. "
            f"Temas/proceso: {len([n for n in nodes if n.area_name not in EXCLUDED_AREA_NAMES])}. "
            f"Áreas: {len(areas)}."
        )
        for name in areas:
            print(f"  - {name}")
        print("Excluidas:", ", ".join(sorted(EXCLUDED_AREA_NAMES)))
        print("Luego corre: python -m scripts.curriculum.enrich_topic_theory")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
