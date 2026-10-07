"""Ejecutor compacto: 1 llamada LLM con briefing precomprimido (sin tool-loop)."""

from __future__ import annotations

import logging
from dataclasses import replace

from sqlalchemy.orm import Session

from app.agents.shared.config import resolve_model_label
from app.agents.shared.context_brief import brief_to_prompt_block, build_exam_brief
from app.agents.shared.response_cache import agent_response_cache
from app.agents.types import AgentResponse
from app.core.config import settings
from app.llm.provider import LLMProvider, create_llm_provider
from app.rag.rag_service import RAGService

logger = logging.getLogger(__name__)

_SYSTEM_PROMPTS = {
    "diagnostic": (
        "Eres el agente Diagnóstico de Pitágoras (admisión universitaria Perú). "
        "Con el BRIEFING JSON dado, redacta un informe breve en español: "
        "1) resumen del puntaje, 2) fortalezas, 3) debilidades, 4) 2-3 prioridades de estudio. "
        "No inventes datos. Máximo 120 palabras. Sin markdown."
    ),
    "motivator": (
        "Eres Cachimbito, motivador de Pitágoras. Tono cercano, positivo y realista. "
        "Usa el BRIEFING JSON. Si hay mensaje del estudiante, respóndelo primero. "
        "Incluye 1 logro y 1 próximo paso concreto. Español. Máximo 90 palabras. Sin markdown."
    ),
    "parents": (
        "Eres el agente Padres de Pitágoras. Informe claro para padres/tutores. "
        "Con el BRIEFING: resumen, fortalezas, áreas a reforzar y cómo apoyar en casa. "
        "Lenguaje accesible. Español. Máximo 120 palabras. Sin markdown."
    ),
}

_AGENT_NAMES = {
    "diagnostic": "pitagoras_diagnostic",
    "motivator": "pitagoras_motivator",
    "parents": "pitagoras_parents",
}


class CompactAgentExecutor:
    """
    Algoritmo anti-tokens:
    - Comprime contexto (brief) en lugar de tool-calls con JSON enorme.
    - Una sola llamada LLM (sin rondas de tools).
    - Caché TTL por examen/agente/mensaje.
    - Recorta la salida a un tope de caracteres.
    """

    def __init__(
        self,
        session: Session,
        *,
        rag_service: RAGService | None = None,
        llm: LLMProvider | None = None,
    ) -> None:
        self._session = session
        self._rag = rag_service
        self._llm = llm or _build_llm()

    def run(
        self,
        *,
        agent_key: str,
        student_exam_id: int,
        student_message: str | None = None,
    ) -> AgentResponse:
        if agent_key not in _SYSTEM_PROMPTS:
            raise ValueError(f"Agente compacto desconocido: {agent_key}")

        cache_key = agent_response_cache.make_key(
            agent=agent_key,
            student_exam_id=student_exam_id,
            student_message=student_message,
            mode="compact",
        )
        cached = agent_response_cache.get(cache_key)
        if isinstance(cached, AgentResponse):
            return replace(
                cached,
                metadata={**(cached.metadata or {}), "cache_hit": True},
            )

        include_rag = agent_key == "diagnostic"
        brief = build_exam_brief(
            self._session,
            student_exam_id,
            include_rag_hints=include_rag,
            rag_service=self._rag if include_rag else None,
        )
        user_parts = [f"BRIEFING:{brief_to_prompt_block(brief)}"]
        if student_message and student_message.strip():
            user_parts.append(f"MENSAJE_ESTUDIANTE:{student_message.strip()[:280]}")

        llm_response = self._llm.generate(
            system_prompt=_SYSTEM_PROMPTS[agent_key],
            user_prompt="\n".join(user_parts),
            temperature=0.4 if agent_key == "motivator" else 0.25,
            max_output_tokens=settings.agent_max_output_tokens,
        )
        content = _clip(llm_response.content, settings.agent_max_output_chars)
        model_name, provider = resolve_model_label()

        result = AgentResponse(
            agent_name=_AGENT_NAMES[agent_key],
            student_exam_id=student_exam_id,
            content=content,
            llm_model=llm_response.model or model_name,
            llm_provider=f"{provider}+compact",
            metadata={
                "mode": "compact",
                "cache_hit": False,
                "brief_keys": list(brief.keys()),
                "brief_chars": len(brief_to_prompt_block(brief)),
            },
        )
        agent_response_cache.set(
            cache_key,
            result,
            ttl_seconds=settings.agent_cache_ttl_seconds,
        )
        return result


def _build_llm() -> LLMProvider:
    gemini_key = settings.gemini_api_key.strip() or settings.google_api_key_effective()
    return create_llm_provider(
        settings.llm_provider,
        openai_api_key=settings.openai_api_key,
        openai_model=settings.openai_model,
        gemini_api_key=gemini_key,
        gemini_model=settings.gemini_model,
    )


def _clip(text: str, max_chars: int) -> str:
    cleaned = text.strip()
    if max_chars <= 0 or len(cleaned) <= max_chars:
        return cleaned
    return f"{cleaned[: max_chars - 1].rstrip()}…"
