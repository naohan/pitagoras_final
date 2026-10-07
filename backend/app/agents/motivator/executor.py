"""Ejecutor del agente Motivador."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.agents.motivator.agent import get_motivator_agent
from app.agents.motivator.config import motivator_agent_config
from app.agents.shared.adk_runner import run_adk_agent
from app.agents.shared.config import resolve_model_label
from app.agents.shared.runtime import AgentRuntimeContext
from app.agents.types import AgentResponse
from app.rag.rag_service import RAGService


class MotivatorAgentExecutor:
    def __init__(
        self,
        session: Session,
        rag_service: RAGService | None = None,
    ) -> None:
        self._session = session
        self._rag = rag_service or RAGService()

    async def execute(
        self,
        student_exam_id: int,
        *,
        student_message: str | None = None,
    ) -> AgentResponse:
        runtime = AgentRuntimeContext(session=self._session, rag_service=self._rag)
        lines = [
            f"Motiva al estudiante según el examen student_exam_id={student_exam_id}.",
            "Usa las herramientas antes de responder.",
        ]
        if student_message:
            lines.append(f"Mensaje del estudiante: {student_message}")

        content = await run_adk_agent(
            agent=get_motivator_agent(),
            app_name=motivator_agent_config.app_name,
            user_message="\n".join(lines),
            runtime=runtime,
        )
        model_name, provider = resolve_model_label()
        return AgentResponse(
            agent_name=motivator_agent_config.agent_name,
            student_exam_id=student_exam_id,
            content=content,
            rag_sources=runtime.rag_sources,
            llm_model=model_name,
            llm_provider=provider,
            metadata=dict(runtime.metadata),
        )
