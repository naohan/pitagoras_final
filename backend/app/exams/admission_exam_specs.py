"""Especificaciones oficiales de exámenes de admisión UNSA / UCSM.

Fuente narrativa: docs/ADMISSION_EXAM_SPECS.md
No incluye enunciados de exámenes reales (copyright).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping


@dataclass(frozen=True)
class ExamModalitySpec:
    code: str
    label: str
    university_code: str
    question_count: int
    duration_minutes: int
    area_key: str = "ingenierias"


# --- UNSA: Ordinario / CEPREUNSA / Quintos → 80 preguntas, 150 min ---
UNSA_QUESTION_COUNT = 80
UNSA_DURATION_MINUTES = 150

# --- UCSM: Ordinario / CEPRE → 80 preguntas, 120 min ---
UCSM_QUESTION_COUNT = 80
UCSM_DURATION_MINUTES = 120
UCSM_EXTRAORDINARIO_QUESTION_COUNT = 50
UCSM_EXTRAORDINARIO_DURATION_MINUTES = 90

# Matriz UNSA Art. 38 (tres columnas suman 80) — área Ingenierías (SIS/CIV).
UNSA_MATRIX_INGENIERIAS: Mapping[str, int] = {
    "razonamiento_logico": 4,
    "razonamiento_matematico": 5,
    "razonamiento_verbal": 4,
    "comprension_lectora": 5,
    "algebra": 4,
    "aritmetica": 4,
    "geometria": 4,
    "trigonometria": 3,
    "historia": 4,
    "geografia": 4,
    "quimica": 6,
    "biologia": 5,
    "fisica": 7,
    "filosofia": 3,
    "psicologia": 4,
    "educacion_civica": 3,
    "lenguaje": 4,
    "literatura": 3,
    "lengua_extranjera_lectura": 2,
    "lengua_extranjera_gramatica": 2,
}

# Ponderación UCSM Ingenierías (% → ítems aprox. sobre 80).
UCSM_WEIGHTS_INGENIERIAS_PCT: Mapping[str, int] = {
    "matematica_raz_matematico": 18,
    "comunicacion_raz_verbal": 10,
    "desarrollo_personal": 6,
    "historia": 5,
    "arte_cultura": 5,
    "ingles": 8,
    "biologia": 5,
    "quimica": 13,
    "fisica": 16,
    "emprendimiento": 4,
    "pensamiento_critico": 10,
}


def ucsm_items_from_weights(
    weights_pct: Mapping[str, int],
    total: int = UCSM_QUESTION_COUNT,
) -> dict[str, int]:
    """Convierte % a enteros que suman exactamente `total`."""
    raw = {k: total * v / 100 for k, v in weights_pct.items()}
    floors = {k: int(v) for k, v in raw.items()}
    rem = total - sum(floors.values())
    order = sorted(raw.keys(), key=lambda k: raw[k] - floors[k], reverse=True)
    for k in order[:rem]:
        floors[k] += 1
    return floors


UNSA_MODALITIES: tuple[ExamModalitySpec, ...] = (
    ExamModalitySpec(
        code="quinto",
        label="UNSA Quinto",
        university_code="UNSA",
        question_count=UNSA_QUESTION_COUNT,
        duration_minutes=UNSA_DURATION_MINUTES,
    ),
    ExamModalitySpec(
        code="cepreunsa",
        label="UNSA CEPREUNSA",
        university_code="UNSA",
        question_count=UNSA_QUESTION_COUNT,
        duration_minutes=UNSA_DURATION_MINUTES,
    ),
    ExamModalitySpec(
        code="ordinario",
        label="UNSA Ordinario",
        university_code="UNSA",
        question_count=UNSA_QUESTION_COUNT,
        duration_minutes=UNSA_DURATION_MINUTES,
    ),
)

UCSM_MODALITIES: tuple[ExamModalitySpec, ...] = (
    ExamModalitySpec(
        code="ordinario",
        label="UCSM Ordinario",
        university_code="UCSM",
        question_count=UCSM_QUESTION_COUNT,
        duration_minutes=UCSM_DURATION_MINUTES,
    ),
    ExamModalitySpec(
        code="cepre",
        label="UCSM CEPRE",
        university_code="UCSM",
        question_count=UCSM_QUESTION_COUNT,
        duration_minutes=UCSM_DURATION_MINUTES,
    ),
)


def all_modality_specs() -> tuple[ExamModalitySpec, ...]:
    return UNSA_MODALITIES + UCSM_MODALITIES


def template_name(spec: ExamModalitySpec, area_label: str = "Ingenierías") -> str:
    return f"{spec.label} - {area_label}"
