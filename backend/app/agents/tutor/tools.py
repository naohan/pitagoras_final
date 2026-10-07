"""Tools del agente Tutor (Google ADK)."""

from __future__ import annotations

from typing import Any

from app.agents.shared.runtime import get_agent_runtime
from app.agents.shared.tools import search_subtopic_material
from app.agents.types import AcademicContext
from app.repositories.question_repository import QuestionRepository

__all__ = ["get_question_context", "search_subtopic_material"]


def get_question_context(question_id: int) -> dict[str, Any]:
    """Obtiene el enunciado, alternativas y contexto académico KGAA de una pregunta."""
    runtime = get_agent_runtime()
    question = QuestionRepository(runtime.session).get_with_academic_context(question_id)
    if question is None:
        return {"error": f"Pregunta {question_id} no encontrada."}

    context = _resolve_academic_context(question)
    runtime.metadata["academic_context"] = context

    options = []
    for option in sorted(question.options, key=lambda item: item.display_order):
        options.append(
            {
                "id": option.id,
                "label": option.label,
                "text": option.text,
                "is_correct": option.is_correct,
            }
        )

    return {
        "question_id": question.id,
        "stem": question.stem,
        "options": options,
        "official_explanation": question.explanation or "No disponible.",
        "academic_context": {
            "subtopic_id": context.subtopic_id,
            "subtopic_name": context.subtopic_name,
            "topic_name": context.topic_name,
            "component_name": context.component_name,
            "area_name": context.area_name,
            "admission_context": context.admission_context,
        },
    }


def _resolve_academic_context(question) -> AcademicContext:
    subtopic = question.subtopic
    topic = subtopic.topic if subtopic else None
    component = topic.component if topic else None
    area = component.area if component else None
    admission = area.admission_process if area else None
    career = admission.career if admission else None
    university = career.university if career else None

    admission_label = "Desconocido"
    if admission and career and university:
        admission_label = f"{university.name} / {career.name} / {admission.name}"

    return AcademicContext(
        question_id=question.id,
        subtopic_id=question.subtopic_id,
        subtopic_name=subtopic.name if subtopic else "Desconocido",
        topic_name=topic.name if topic else "Desconocido",
        component_name=component.name if component else "Desconocido",
        area_name=area.name if area else "Desconocido",
        admission_context=admission_label,
    )
