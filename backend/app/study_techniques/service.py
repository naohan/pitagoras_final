"""Técnicas de estudio demo: Feynman y aprendizaje por errores (sin LLM por defecto)."""

from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.question import Question
from app.repositories.question_repository import QuestionRepository

# Palabras clave mínimas por subtema (slug) para validar explicación Feynman
FEYNMAN_KEYWORDS: dict[str, tuple[str, ...]] = {
    "ecuaciones": ("ecuación", "incógnita", "despejar", "valor", "x", "igual"),
    "funciones": ("función", "variable", "gráfica", "pendiente", "dominio", "rango"),
    "geometria": ("área", "perímetro", "triángulo", "figura", "lado", "volumen"),
    "probabilidad": ("probabilidad", "caso", "favorable", "evento", "azar"),
    "proporcionalidad": ("proporción", "razón", "inversa", "directa", "regla de tres"),
    "operaciones_basicas": ("operación", "simplificar", "potencia", "raíz", "expresión"),
    "estadistica": ("media", "varianza", "dato", "promedio", "frecuencia"),
    "divisibilidad_analogias": ("divisor", "múltiplo", "mcm", "mcd", "divisible"),
    "general": ("porque", "entonces", "paso", "resultado", "ejemplo"),
}


@dataclass
class FeynmanAnalysis:
    score_percent: float
    strengths: list[str]
    gaps: list[str]
    suggestions: list[str]


@dataclass
class ErrorGuidance:
    question_id: int
    error_step: str
    concept_name: str
    concept_reminder: str
    quick_tip: str
    similar_question_id: int | None
    similar_question_stem: str | None
    has_rich_data: bool
    allow_retry: bool = True


class FeynmanService:
    def __init__(self, session: Session) -> None:
        self._session = session

    def analyze(self, *, subtopic_name: str, subtopic_key: str, explanation: str) -> FeynmanAnalysis:
        text = explanation.strip()
        lowered = text.lower()
        strengths: list[str] = []
        gaps: list[str] = []
        suggestions: list[str] = []

        if len(text) < 40:
            gaps.append("La explicación es muy corta para demostrar comprensión.")
            suggestions.append("Explica el concepto con al menos 3 oraciones y un ejemplo numérico.")
        else:
            strengths.append("Desarrollaste la idea con suficiente detalle.")

        keywords = FEYNMAN_KEYWORDS.get(subtopic_key, FEYNMAN_KEYWORDS["general"])
        found = [word for word in keywords if word in lowered]
        missing = [word for word in keywords if word not in lowered][:4]

        if len(found) >= 2:
            strengths.append(f"Usaste vocabulario del tema ({', '.join(found[:3])}).")
        else:
            gaps.append(f"Faltan términos clave de «{subtopic_name}».")
            suggestions.append(
                f"Intenta mencionar: {', '.join(missing)}."
            )

        if "porque" not in lowered and "por qué" not in lowered and "entonces" not in lowered:
            gaps.append("No explicitas el razonamiento (el «por qué» del procedimiento).")
            suggestions.append("Añade una frase que empiece con «Esto ocurre porque…».")

        if "ejemplo" not in lowered and not any(char.isdigit() for char in text):
            gaps.append("No incluyes un ejemplo concreto.")
            suggestions.append("Cierra con un mini-ejemplo numérico o situación real.")

        score = 100.0
        score -= len(gaps) * 18
        score = max(25.0, min(100.0, score))

        if not strengths:
            strengths.append("Buen intento: explicar con tus palabras ya es aprendizaje activo.")

        return FeynmanAnalysis(
            score_percent=round(score, 1),
            strengths=strengths,
            gaps=gaps,
            suggestions=suggestions,
        )


class ErrorLearningService:
    def __init__(self, session: Session) -> None:
        self._session = session
        self._questions = QuestionRepository(session)

    def get_guidance(
        self,
        question_id: int,
        *,
        selected_option_id: int | None = None,
    ) -> ErrorGuidance:
        question = self._questions.get_with_academic_context(question_id)
        if question is None:
            raise ValueError(f"Pregunta {question_id} no encontrada")

        subtopic = question.subtopic
        concept_name = subtopic.name if subtopic else "Matemáticas"
        subtopic_key = _slug_from_subtopic_name(concept_name)

        selected_label = "tu opción"
        if selected_option_id is not None:
            selected = next((o for o in question.options if o.id == selected_option_id), None)
            if selected is not None:
                selected_label = f"la opción {selected.label}"

        error_step = (
            f"El error suele estar al interpretar el enunciado o al operar después de elegir "
            f"{selected_label}. Revisa el primer paso antes de calcular el resultado final."
        )

        concept_reminder = _concept_reminder(question, concept_name, for_display=True)
        similar = self._find_easier_similar(question)
        quick_tip = _build_quick_tip(concept_name, selected_label)
        has_rich = similar is not None or bool(
            question.explanation and not _explanation_leaks_answer(question.explanation)
        )

        return ErrorGuidance(
            question_id=question_id,
            error_step=error_step,
            concept_name=concept_name,
            concept_reminder=concept_reminder,
            quick_tip=quick_tip,
            similar_question_id=similar.id if similar else None,
            similar_question_stem=similar.stem if similar else None,
            has_rich_data=has_rich,
        )

    def _find_easier_similar(self, question: Question) -> Question | None:
        if question.subtopic_id is None:
            return None
        stmt = (
            select(Question)
            .where(
                Question.subtopic_id == question.subtopic_id,
                Question.is_active.is_(True),
                Question.id != question.id,
                Question.difficulty < question.difficulty,
            )
            .options(selectinload(Question.options))
            .order_by(Question.difficulty)
            .limit(1)
        )
        easier = self._session.scalars(stmt).first()
        if easier is not None:
            return easier

        stmt_any = (
            select(Question)
            .where(
                Question.subtopic_id == question.subtopic_id,
                Question.is_active.is_(True),
                Question.id != question.id,
            )
            .options(selectinload(Question.options))
            .order_by(Question.difficulty)
            .limit(1)
        )
        return self._session.scalars(stmt_any).first()


def _concept_reminder(
    question: Question,
    concept_name: str,
    *,
    for_display: bool = False,
) -> str:
    if question.explanation and not _explanation_leaks_answer(question.explanation):
        first = question.explanation.split(".")[0].strip()
        if first:
            return f"Concepto ({concept_name}): {first}."
    if for_display:
        return (
            f"Repasa los fundamentos de «{concept_name}». "
            "Aún estamos ampliando el banco de ejercicios similares."
        )
    return (
        f"Repasa los fundamentos de «{concept_name}» antes de volver a intentar. "
        "No mostramos la respuesta correcta hasta que lo intentes de nuevo."
    )


def _explanation_leaks_answer(text: str) -> bool:
    lowered = text.lower()
    leaks = ("respuesta ", "respuesta:", "opción ", "opcion ", "correcta es", "la clave")
    return any(marker in lowered for marker in leaks)


def _build_quick_tip(concept_name: str, selected_label: str) -> str:
    return (
        f"Revisa el enunciado paso a paso en «{concept_name}». "
        f"Tras elegir {selected_label}, vuelve al primer dato del problema "
        "antes de calcular el resultado final."
    )


def _slug_from_subtopic_name(name: str) -> str:
    lowered = name.lower()
    mapping = {
        "ecuación": "ecuaciones",
        "función": "funciones",
        "geometría": "geometria",
        "probabilidad": "probabilidad",
        "proporcional": "proporcionalidad",
        "estadística": "estadistica",
        "operaciones": "operaciones_basicas",
        "divisibilidad": "divisibilidad_analogias",
    }
    for key, slug in mapping.items():
        if key in lowered:
            return slug
    return "general"
