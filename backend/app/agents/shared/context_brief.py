"""Comprime diagnóstico + plan en un briefing corto para ahorrar tokens."""

from __future__ import annotations

import json
from typing import Any

from sqlalchemy.orm import Session

from app.core.config import settings
from app.diagnostics.diagnostic_service import DiagnosticService
from app.recommendations.recommendation_service import RecommendationService


def _short_label(text: str) -> str:
    if "→" in text:
        return text.split("→")[-1].strip()
    return text.strip()


def build_exam_brief(
    session: Session,
    student_exam_id: int,
    *,
    include_rag_hints: bool = False,
    rag_service: Any | None = None,
) -> dict[str, Any]:
    """
    Algoritmo de compresión de contexto:
    1. Toma solo score global + top fortalezas/debilidades.
    2. Omite árbol completo área/componente/tema (ahorra ~70-90% tokens).
    3. Limita recomendaciones y, opcionalmente, 1-2 fragmentos RAG cortos.
    """
    diagnostic = DiagnosticService(session).get_diagnostic(student_exam_id)
    plan = RecommendationService(session).get_study_plan(student_exam_id)

    max_items = settings.agent_brief_max_items
    strengths = [_short_label(s) for s in diagnostic.strengths[:max_items]]
    weaknesses = [_short_label(w) for w in diagnostic.weaknesses[:max_items]]

    if not weaknesses and diagnostic.subtopics:
        weak = sorted(diagnostic.subtopics, key=lambda item: item.score_percent)[:max_items]
        weaknesses = [item.name for item in weak]

    if not strengths and diagnostic.subtopics:
        strong = sorted(
            diagnostic.subtopics,
            key=lambda item: item.score_percent,
            reverse=True,
        )[:max_items]
        strengths = [item.name for item in strong]

    recommendations = [
        {
            "tema": rec.entity_name,
            "tipo": rec.resource_type.value,
            "msg": _truncate(rec.message, 120),
        }
        for rec in plan.recommendations[:max_items]
    ]

    brief: dict[str, Any] = {
        "exam_id": student_exam_id,
        "score": round(float(diagnostic.global_score_percent), 1),
        "aciertos": f"{diagnostic.correct_answers}/{diagnostic.total_questions}",
        "fortalezas": strengths,
        "debilidades": weaknesses,
        "foco": plan.focus_subtopics[:max_items],
        "dias_estimados": plan.estimated_days,
        "recomendaciones": recommendations,
    }

    if include_rag_hints and rag_service is not None and weaknesses:
        brief["apuntes"] = _compact_rag_hints(rag_service, weaknesses[0])

    return brief


def brief_to_prompt_block(brief: dict[str, Any]) -> str:
    """Serializa el briefing en JSON compacto (sin espacios innecesarios)."""
    return json.dumps(brief, ensure_ascii=False, separators=(",", ":"))


def _compact_rag_hints(rag_service: Any, query: str) -> list[str]:
    top_k = settings.agent_rag_top_k
    max_chars = settings.agent_rag_fragment_chars
    try:
        results = rag_service.search(query, top_k=top_k)
    except Exception:
        return []
    hints: list[str] = []
    for item in results:
        text = (item.text or "").strip().replace("\n", " ")
        if not text:
            continue
        hints.append(_truncate(text, max_chars))
    return hints


def _truncate(text: str, max_chars: int) -> str:
    cleaned = " ".join(text.split())
    if len(cleaned) <= max_chars:
        return cleaned
    return f"{cleaned[: max_chars - 3]}..."
