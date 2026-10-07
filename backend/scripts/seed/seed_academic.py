"""Árbol académico demo compartido por scripts de seed.

Jerarquía alineada al CNEB + cursos clásicos internos:
  Área oficial (CNEB) → Curso (Component) → Tema → Subtema

Ejemplo Matemática → Aritmética / Álgebra / Geometría / Trigonometría / Estadística
"""

from __future__ import annotations

from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.academic import Area, Component, Subtopic, Topic

MATH_AREA_NAME = "Matemática"
_LEGACY_MATH_AREA_NAMES = ("Matemáticas", "Matematica")

# slug → (subtopic_name, topic_name, course_name)
# course_name = Component = curso clásico interno
SUBTOPIC_CATALOG: list[tuple[str, str, str, str]] = [
    ("operaciones_basicas", "Operaciones básicas", "Números y operaciones", "Aritmética"),
    ("proporcionalidad", "Proporcionalidad", "Razones y proporciones", "Aritmética"),
    ("divisibilidad_analogias", "Divisibilidad y analogías", "Divisibilidad", "Aritmética"),
    ("ecuaciones", "Ecuaciones lineales", "Ecuaciones", "Álgebra"),
    ("funciones", "Funciones y representación", "Funciones", "Álgebra"),
    ("geometria", "Geometría plana", "Figuras y medidas", "Geometría"),
    ("trigonometria", "Razones trigonométricas", "Triángulos", "Trigonometría"),
    ("probabilidad", "Probabilidad", "Datos y azar", "Estadística"),
    ("estadistica", "Estadística descriptiva", "Datos y azar", "Estadística"),
    ("general", "Matemática general", "Fundamentos", "Aritmética"),
]

SUBTOPIC_KEYWORDS: list[tuple[str, tuple[str, ...]]] = [
    ("probabilidad", ("probabilidad", "azar", "bola", "moneda", "premio")),
    ("estadistica", ("mediana", "frecuencia", "tabla de frecuencias", "estadística")),
    ("trigonometria", ("seno", "coseno", "tangente", "trigonométr", "ángulo")),
    ("geometria", (
        "área", "triángulo", "círculo", "octógono", "perímetro", "garaje",
        "semielipse", "tangencia", "figura", "volumen", "hipotenusa",
    )),
    ("funciones", ("función", "f(x)", "funciones", "representación")),
    ("proporcionalidad", ("proporcional", "obreros", "pasteles", "razón de", "directamente proporcional")),
    ("divisibilidad_analogias", ("analogía", "divisib", "mcm", "mcd", "múltiplo de 3")),
    ("ecuaciones", ("ecuación", "valor de x", "x +", "x -", "x²", "despejar")),
    ("operaciones_basicas", ("simplifica", "potencia", "²", "³", "√")),
]


def classify_subtopic_key(stem: str) -> str:
    text = stem.lower()
    for key, keywords in SUBTOPIC_KEYWORDS:
        if any(word in text for word in keywords):
            return key
    return "general"


def ensure_engineering_math_tree(db: Session, admission_process_id: int) -> dict[str, int]:
    """Crea/realinea área Matemática con cursos internos; slug → subtopic_id."""
    area = _ensure_math_area(db, admission_process_id)
    slug_map: dict[str, int] = {}

    component_cache = _load_components(db, area.id)
    topic_cache = _load_topics(db, area.id)

    for order, (slug, subtopic_name, topic_name, course_name) in enumerate(
        SUBTOPIC_CATALOG, start=1
    ):
        if course_name not in component_cache:
            component = Component(
                area_id=area.id,
                name=course_name,
                display_order=len(component_cache) + 1,
                is_active=True,
            )
            db.add(component)
            db.flush()
            component_cache[course_name] = component

        component = component_cache[course_name]
        topic_key = (course_name, topic_name)
        if topic_key not in topic_cache:
            topic = Topic(
                component_id=component.id,
                name=topic_name,
                display_order=len(topic_cache) + 1,
                is_active=True,
            )
            db.add(topic)
            db.flush()
            topic_cache[topic_key] = topic

        topic = topic_cache[topic_key]
        existing = _find_subtopic_in_process(db, admission_process_id, subtopic_name)
        if existing is not None:
            if existing.topic_id != topic.id:
                existing.topic_id = topic.id
            if existing.display_order != order:
                existing.display_order = order
            if not existing.is_active:
                existing.is_active = True
            slug_map[slug] = existing.id
            continue

        subtopic = Subtopic(
            topic_id=topic.id,
            name=subtopic_name,
            display_order=order,
            is_active=True,
        )
        db.add(subtopic)
        db.flush()
        slug_map[slug] = subtopic.id

    return slug_map


def _ensure_math_area(db: Session, admission_process_id: int) -> Area:
    stmt = select(Area).where(
        Area.admission_process_id == admission_process_id,
        Area.name == MATH_AREA_NAME,
    )
    area = db.scalars(stmt).first()
    if area is not None:
        return area

    for legacy in _LEGACY_MATH_AREA_NAMES:
        stmt = select(Area).where(
            Area.admission_process_id == admission_process_id,
            Area.name == legacy,
        )
        legacy_area = db.scalars(stmt).first()
        if legacy_area is not None:
            legacy_area.name = MATH_AREA_NAME
            db.flush()
            return legacy_area

    area = Area(
        admission_process_id=admission_process_id,
        name=MATH_AREA_NAME,
        weight_percent=Decimal("100.00"),
        display_order=1,
        is_active=True,
    )
    db.add(area)
    db.flush()
    return area


def _find_subtopic_in_process(
    db: Session, admission_process_id: int, subtopic_name: str
) -> Subtopic | None:
    stmt = (
        select(Subtopic)
        .join(Topic)
        .join(Component)
        .join(Area)
        .where(
            Area.admission_process_id == admission_process_id,
            Subtopic.name == subtopic_name,
        )
    )
    return db.scalars(stmt).first()


def _load_components(db: Session, area_id: int) -> dict[str, Component]:
    stmt = select(Component).where(Component.area_id == area_id)
    return {component.name: component for component in db.scalars(stmt).all()}


def _load_topics(db: Session, area_id: int) -> dict[tuple[str, str], Topic]:
    stmt = (
        select(Topic, Component)
        .join(Component, Topic.component_id == Component.id)
        .where(Component.area_id == area_id)
    )
    cache: dict[tuple[str, str], Topic] = {}
    for topic, component in db.execute(stmt).all():
        cache[(component.name, topic.name)] = topic
    return cache


def resolve_subtopic_id(slug_map: dict[str, int], key: str) -> int:
    if key in slug_map:
        return slug_map[key]
    if "general" in slug_map:
        return slug_map["general"]
    return next(iter(slug_map.values()))
