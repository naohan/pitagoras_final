"""Servicio del Tutor IA — delega en el orquestador LangGraph."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.agents.exceptions import LLMConfigurationError, LLMRequestError, QuestionNotFoundError
from app.agents.types import AcademicContext, TutorExplanation
from app.orchestrator.exceptions import OrchestratorRoutingError
from app.orchestrator.service import OrchestratorService
from app.rag.rag_service import RAGService

__all__ = ["AcademicContext", "TutorExplanation", "TutorService"]


class TutorService:
    """Fachada del Tutor IA: enruta la petición vía LangGraph → agente ADK."""

    def __init__(
        self,
        session: Session,
        rag_service: RAGService | None = None,
    ) -> None:
        self._orchestrator = OrchestratorService(session, rag_service=rag_service)

    def explain(
        self,
        question_id: int,
        *,
        student_message: str | None = None,
        selected_option_id: int | None = None,
        top_k: int | None = None,
        student_id: int | None = None,
    ) -> TutorExplanation:
        try:
            return self._orchestrator.explain_question(
                question_id,
                student_message=student_message,
                selected_option_id=selected_option_id,
                top_k=top_k,
                student_id=student_id,
            )
        except (LLMConfigurationError, QuestionNotFoundError):
            raise
        except OrchestratorRoutingError as exc:
            raise LLMRequestError(exc.message) from exc
        except Exception as exc:
            raise LLMRequestError(str(exc)) from exc

    def hint(
        self,
        question_id: int,
        *,
        selected_option_id: int | None = None,
        top_k: int | None = None,
        student_id: int | None = None,
    ) -> TutorExplanation:
        hint_prompt = (
            "Modo TIP DE RESOLUCIÓN: responde en máximo 3 oraciones con una pista "
            "o estrategia para abordar el problema. NO reveles la letra de la respuesta "
            "correcta ni des la solución numérica final. Solo orienta el método o concepto clave."
        )
        return self.explain(
            question_id,
            student_message=hint_prompt,
            selected_option_id=selected_option_id,
            top_k=top_k or 3,
            student_id=student_id,
        )
