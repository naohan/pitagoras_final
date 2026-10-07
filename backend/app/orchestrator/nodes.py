"""Nodos del grafo LangGraph."""

from __future__ import annotations

import asyncio
from typing import Callable

from sqlalchemy.orm import Session

from app.agents.diagnostic.executor import DiagnosticAgentExecutor
from app.agents.motivator.executor import MotivatorAgentExecutor
from app.agents.parents.executor import ParentsAgentExecutor
from app.agents.tutor.executor import TutorAgentExecutor
from app.orchestrator.types import AgentName, OrchestratorState
from app.rag.rag_service import RAGService


def build_tutor_node(
    session: Session,
    rag_service: RAGService | None = None,
) -> Callable[[OrchestratorState], dict]:
    executor = TutorAgentExecutor(session, rag_service=rag_service)

    def run_tutor(state: OrchestratorState) -> dict:
        question_id = state.get("question_id")
        if question_id is None:
            return {"error": "question_id es requerido para el agente tutor."}

        result = asyncio.run(
            executor.execute(
                question_id,
                student_message=state.get("student_message"),
                selected_option_id=state.get("selected_option_id"),
                top_k=state.get("top_k"),
                student_id=state.get("student_id"),
            )
        )
        return {"result": result, "selected_agent": AgentName.TUTOR.value}

    return run_tutor


def build_diagnostic_node(
    session: Session,
    rag_service: RAGService | None = None,
) -> Callable[[OrchestratorState], dict]:
    executor = DiagnosticAgentExecutor(session, rag_service=rag_service)

    def run_diagnostic(state: OrchestratorState) -> dict:
        student_exam_id = state.get("student_exam_id")
        if student_exam_id is None:
            return {"error": "student_exam_id es requerido para el agente diagnóstico."}

        result = asyncio.run(executor.execute(student_exam_id))
        return {"result": result, "selected_agent": AgentName.DIAGNOSTIC.value}

    return run_diagnostic


def build_motivator_node(
    session: Session,
    rag_service: RAGService | None = None,
) -> Callable[[OrchestratorState], dict]:
    executor = MotivatorAgentExecutor(session, rag_service=rag_service)

    def run_motivator(state: OrchestratorState) -> dict:
        student_exam_id = state.get("student_exam_id")
        if student_exam_id is None:
            return {"error": "student_exam_id es requerido para el agente motivador."}

        result = asyncio.run(
            executor.execute(
                student_exam_id,
                student_message=state.get("student_message"),
            )
        )
        return {"result": result, "selected_agent": AgentName.MOTIVATOR.value}

    return run_motivator


def build_parents_node(
    session: Session,
    rag_service: RAGService | None = None,
) -> Callable[[OrchestratorState], dict]:
    executor = ParentsAgentExecutor(session, rag_service=rag_service)

    def run_parents(state: OrchestratorState) -> dict:
        student_exam_id = state.get("student_exam_id")
        if student_exam_id is None:
            return {"error": "student_exam_id es requerido para el agente padres."}

        result = asyncio.run(executor.execute(student_exam_id))
        return {"result": result, "selected_agent": AgentName.PARENTS.value}

    return run_parents
