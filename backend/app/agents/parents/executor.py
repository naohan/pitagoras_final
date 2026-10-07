"""Ejecutor del agente Padres."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.agents.parents.agent import get_parents_agent
from app.agents.parents.config import parents_agent_config
from app.agents.shared.adk_runner import run_adk_agent
from app.agents.shared.config import resolve_model_label
from app.agents.shared.runtime import AgentRuntimeContext
from app.agents.types import AgentResponse
from app.rag.rag_service import RAGService


class ParentsAgentExecutor:
    def __init__(
        self,
        session: Session,
        rag_service: RAGService | None = None,
    ) -> None:
        self._session = session
        self._rag = rag_service or RAGService()

    async def execute(self, student_exam_id: int) -> AgentResponse:
        runtime = AgentRuntimeContext(session=self._session, rag_service=self._rag)
        content = await run_adk_agent(
            agent=get_parents_agent(),
            app_name=parents_agent_config.app_name,
            user_message=(
                f"Genera un informe para padres del examen student_exam_id={student_exam_id}. "
                "Usa las herramientas antes de responder."
            ),
            runtime=runtime,
        )
        model_name, provider = resolve_model_label()
        return AgentResponse(
            agent_name=parents_agent_config.agent_name,
            student_exam_id=student_exam_id,
            content=content,
            rag_sources=runtime.rag_sources,
            llm_model=model_name,
            llm_provider=provider,
            metadata=dict(runtime.metadata),
        )
