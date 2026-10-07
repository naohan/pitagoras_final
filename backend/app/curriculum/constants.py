"""Constantes compartidas del currículo de aprendizaje."""

from __future__ import annotations

from app.models.enums import CurriculumFramework

FRAMEWORK_UI_LABELS: dict[CurriculumFramework, str] = {
    CurriculumFramework.CNEB_SECUNDARIA: "Base escolar (CNEB)",
    CurriculumFramework.ADMISSION_TEMARIO: "Temario / balotario de admisión",
}

# Orden oficial del Programa Curricular de Secundaria (MINEDU)
CNEB_AREA_ORDER: tuple[str, ...] = (
    "Desarrollo Personal, Ciudadanía y Cívica",
    "Ciencias Sociales",
    "Comunicación",
    "Castellano como Segunda Lengua",
    "Inglés como Lengua Extranjera",
    "Matemática",
    "Ciencia y Tecnología",
    "Educación para el Trabajo",
)

# Fuera del catálogo de aprendizaje (no se enseñan en la app).
EXCLUDED_LEARNING_AREAS: frozenset[str] = frozenset(
    {
        "Arte y Cultura",
        "Educación Física",
        "Educación Religiosa",
    }
)
