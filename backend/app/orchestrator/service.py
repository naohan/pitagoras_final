"""Servicio del orquestador LangGraph + modo compacto anti-tokens."""

from __future__ import annotations

import logging
from typing import TypeVar

from sqlalchemy.orm import Session

from app.agents.exceptions import LLMRequestError, TutorError
from app.agents.shared.compact_executor import CompactAgentExecutor
from app.agents.types import AgentResponse, TutorExplanation
from app.core.config import settings
from app.diagnostics.exceptions import DiagnosticError
from app.insights.template_service import InsightTemplateService
from app.orchestrator.exceptions import OrchestratorRoutingError
from app.orchestrator.graph import build_orchestrator_graph
from app.orchestrator.types import AgentName, OrchestratorState
from app.rag.rag_service import RAGService

logger = logging.getLogger(__name__)

T = TypeVar("T", TutorExplanation, AgentResponse)


class OrchestratorService:
    """Orquestador: decide qué agente ejecutar según la intención."""

    def __init__(
        self,
        session: Session,
        rag_service: RAGService | None = None,
    ) -> None:
        self._session = session
        self._rag = rag_service
        self._graph = build_orchestrator_graph(session, rag_service)
        self._templates = InsightTemplateService(session)

    def explain_question(
        self,
        question_id: int,
        *,
        student_message: str | None = None,
        selected_option_id: int | None = None,
        top_k: int | None = None,
        student_id: int | None = None,
    ) -> TutorExplanation:
        result = self._invoke(
            {
                "agent_name": AgentName.TUTOR.value,
                "question_id": question_id,
                "student_message": student_message,
                "selected_option_id": selected_option_id,
                "top_k": top_k,
                "student_id": student_id,
            }
        )
        if not isinstance(result, TutorExplanation):
            raise OrchestratorRoutingError("El orquestador no devolvió una respuesta de tutor.")
        return result

    def analyze_diagnostic(self, student_exam_id: int) -> AgentResponse:
        return self._run_insight_agent(
            agent_key="diagnostic",
            student_exam_id=student_exam_id,
            use_llm=settings.use_llm_for_diagnostic,
            template_fn=lambda: self._templates.analyze_diagnostic(student_exam_id),
            full_agent=AgentName.DIAGNOSTIC,
        )

    def motivate_student(
        self,
        student_exam_id: int,
        *,
        student_message: str | None = None,
    ) -> AgentResponse:
        return self._run_insight_agent(
            agent_key="motivator",
            student_exam_id=student_exam_id,
            student_message=student_message,
            use_llm=settings.use_llm_for_motivator,
            template_fn=lambda: self._templates.motivate(
                student_exam_id,
                student_message=student_message,
            ),
            full_agent=AgentName.MOTIVATOR,
            full_payload={"student_message": student_message},
        )

    def parent_report(self, student_exam_id: int) -> AgentResponse:
        return self._run_insight_agent(
            agent_key="parents",
            student_exam_id=student_exam_id,
            use_llm=settings.use_llm_for_parents,
            template_fn=lambda: self._templates.parent_report(student_exam_id),
            full_agent=AgentName.PARENTS,
        )

    def _run_insight_agent(
        self,
        *,
        agent_key: str,
        student_exam_id: int,
        use_llm: bool,
        template_fn,
        full_agent: AgentName,
        student_message: str | None = None,
        full_payload: dict | None = None,
    ) -> AgentResponse:
        mode = settings.agent_execution_mode.strip().lower()

        if not use_llm or mode == "rules":
            return template_fn()

        if mode == "compact":
            try:
                return CompactAgentExecutor(
                    self._session,
                    rag_service=self._rag,
                ).run(
                    agent_key=agent_key,
                    student_exam_id=student_exam_id,
                    student_message=student_message,
                )
            except Exception as exc:
                logger.warning(
                    "Agente %s compact falló (%s); fallback a plantillas.",
                    agent_key,
                    exc,
                )
                result = template_fn()
                result.metadata = {
                    **(result.metadata or {}),
                    "fallback_from": "compact",
                    "fallback_error": str(exc)[:200],
                }
                # Cachea el fallback para no reintentar LLM fallido en cada tap.
                from app.agents.shared.response_cache import agent_response_cache

                cache_key = agent_response_cache.make_key(
                    agent=agent_key,
                    student_exam_id=student_exam_id,
                    student_message=student_message,
                    mode="compact",
                )
                agent_response_cache.set(
                    cache_key,
                    result,
                    ttl_seconds=min(300, settings.agent_cache_ttl_seconds),
                )
                return result

        # mode == full → ADK + tools
        try:
            payload = {"student_exam_id": student_exam_id, **(full_payload or {})}
            return self._invoke_agent(full_agent, payload)
        except Exception as exc:
            logger.warning(
                "Agente %s full falló (%s); fallback a plantillas.",
                agent_key,
                exc,
            )
            result = template_fn()
            result.metadata = {
                **(result.metadata or {}),
                "fallback_from": "full",
                "fallback_error": str(exc)[:200],
            }
            return result

    def _invoke_agent(self, agent_name: AgentName, payload: OrchestratorState) -> AgentResponse:
        payload = {**payload, "agent_name": agent_name.value}
        result = self._invoke(payload)
        if not isinstance(result, AgentResponse):
            raise OrchestratorRoutingError(
                f"El orquestador no devolvió una respuesta del agente {agent_name.value}."
            )
        return result

    def _invoke(self, initial_state: OrchestratorState) -> TutorExplanation | AgentResponse:
        try:
            final_state = self._graph.invoke(initial_state)
        except (TutorError, DiagnosticError):
            raise
        except Exception as exc:
            raise LLMRequestError(str(exc)) from exc

        if final_state.get("error"):
            raise OrchestratorRoutingError(final_state["error"])

        result = final_state.get("result")
        if result is None:
            raise OrchestratorRoutingError("El orquestador no produjo resultado.")

        return result
