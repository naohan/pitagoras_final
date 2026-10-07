"""Ejecución del agente Tutor ADK (invocado por el orquestador LangGraph)."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.agents.exceptions import QuestionNotFoundError
from app.agents.shared.adk_runner import run_adk_agent
from app.agents.shared.config import resolve_model_label
from app.agents.shared.runtime import AgentRuntimeContext
from app.agents.tutor.agent import get_root_agent
from app.agents.tutor.config import tutor_agent_config
from app.agents.types import AcademicContext, TutorExplanation
from app.rag.rag_service import RAGService
from app.repositories.question_repository import QuestionRepository


class TutorAgentExecutor:
    """Ejecuta el agente Tutor ADK para una pregunta concreta."""

    def __init__(
        self,
        session: Session,
        rag_service: RAGService | None = None,
    ) -> None:
        self._session = session
        self._questions = QuestionRepository(session)
        self._rag = rag_service or RAGService()

    async def execute(
        self,
        question_id: int,
        *,
        student_message: str | None = None,
        selected_option_id: int | None = None,
        top_k: int | None = None,
        student_id: int | None = None,
    ) -> TutorExplanation:
        if self._questions.get_by_id(question_id) is None:
            raise QuestionNotFoundError(question_id)

        runtime = AgentRuntimeContext(
            session=self._session,
            rag_service=self._rag,
            student_id=student_id,
        )
        user_message = self._build_user_message(
            question_id=question_id,
            student_message=student_message,
            selected_option_id=selected_option_id,
            top_k=top_k,
        )
        explanation = await run_adk_agent(
            agent=get_root_agent(),
            app_name=tutor_agent_config.app_name,
            user_message=user_message,
            runtime=runtime,
        )

        academic_context = runtime.metadata.get("academic_context")
        if academic_context is None:
            question = self._questions.get_with_academic_context(question_id)
            if question is None:
                raise QuestionNotFoundError(question_id)
            academic_context = self._resolve_academic_context(question)

        model_name, provider = resolve_model_label()
        return TutorExplanation(
            question_id=question_id,
            explanation=explanation,
            academic_context=academic_context,
            rag_sources=runtime.rag_sources,
            llm_model=model_name,
            llm_provider=provider,
        )

    def _build_user_message(
        self,
        *,
        question_id: int,
        student_message: str | None,
        selected_option_id: int | None,
        top_k: int | None,
    ) -> str:
        lines = [
            f"Explica la pregunta con ID {question_id}.",
            "Usa las herramientas para obtener contexto y material de referencia antes de responder.",
        ]
        if student_message:
            lines.append(f"Mensaje del estudiante: {student_message}")
        if selected_option_id is not None:
            lines.append(f"Opción seleccionada por el estudiante (ID): {selected_option_id}")
        if top_k is not None:
            lines.append(f"Usa top_k={top_k} al buscar material RAG.")
        return "\n".join(lines)

    def _resolve_academic_context(self, question) -> AcademicContext:
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
