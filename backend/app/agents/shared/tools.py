"""Tools ADK compartidas: MySQL y ChromaDB."""

from __future__ import annotations

from typing import Any

from app.agents.shared.runtime import get_agent_runtime
from app.core.config import settings
from app.rag.chroma import VectorSearchResult
from app.rag.rag_service import RAGService


def search_subtopic_material(
    query: str,
    subtopic_id: int,
    top_k: int | None = None,
) -> dict[str, Any]:
    """Busca material indexado (PDF/apuntes) relevante para el subtema."""
    runtime = get_agent_runtime()
    limit = min(top_k or settings.agent_rag_top_k, settings.agent_rag_top_k)
    results = _search_with_fallback(
        runtime.rag_service,
        query=query,
        subtopic_id=subtopic_id,
        student_id=runtime.student_id,
        top_k=limit,
    )

    max_chars = settings.agent_rag_fragment_chars
    fragments = []
    for result in results:
        text = " ".join((result.text or "").split())
        if len(text) > max_chars:
            text = f"{text[: max_chars - 3]}..."
        source = {
            "id": result.id,
            "score": result.score,
            "text": text,
            "metadata": {
                k: result.metadata.get(k)
                for k in ("source", "title", "subtopic_id")
                if result.metadata.get(k) is not None
            },
        }
        runtime.rag_sources.append(source)
        fragments.append(source)

    if not fragments:
        return {
            "subtopic_id": subtopic_id,
            "fragments": [],
            "message": (
                "No se encontró material indexado. El estudiante puede subir PDFs "
                "en Material de estudio; se usarán en la próxima explicación."
            ),
        }

    return {
        "subtopic_id": subtopic_id,
        "fragments": fragments,
        "message": f"Se encontraron {len(fragments)} fragmentos de tus apuntes o material.",
    }


def _search_with_fallback(
    rag: RAGService,
    *,
    query: str,
    subtopic_id: int,
    student_id: int | None,
    top_k: int,
) -> list[VectorSearchResult]:
    """Prioriza material del estudiante y del subtema; luego amplía la búsqueda."""
    strategies: list[dict[str, int | None]] = []
    if student_id is not None:
        strategies.append({"subtopic_id": subtopic_id, "student_id": student_id})
        strategies.append({"subtopic_id": None, "student_id": student_id})
    strategies.append({"subtopic_id": subtopic_id, "student_id": None})
    strategies.append({"subtopic_id": None, "student_id": None})

    seen_ids: set[str] = set()
    merged: list[VectorSearchResult] = []
    for strategy in strategies:
        batch = rag.search(
            query,
            top_k=top_k,
            subtopic_id=strategy["subtopic_id"],
            student_id=strategy["student_id"],
        )
        for item in batch:
            if item.id in seen_ids:
                continue
            seen_ids.add(item.id)
            merged.append(item)
            if len(merged) >= top_k:
                return merged
    return merged


def get_exam_diagnostic_report(student_exam_id: int) -> dict[str, Any]:
    """Tool ADK: perfil académico compacto (sin árbol completo)."""
    from app.agents.shared.context_brief import build_exam_brief

    runtime = get_agent_runtime()
    return build_exam_brief(runtime.session, student_exam_id)


def get_study_plan_summary(student_exam_id: int) -> dict[str, Any]:
    """Tool ADK: plan de estudio compacto."""
    from app.agents.shared.context_brief import build_exam_brief

    runtime = get_agent_runtime()
    brief = build_exam_brief(runtime.session, student_exam_id)
    return {
        "student_exam_id": brief["exam_id"],
        "global_score_percent": brief["score"],
        "estimated_days": brief["dias_estimados"],
        "focus_subtopics": brief["foco"],
        "recommendations": brief["recomendaciones"],
    }