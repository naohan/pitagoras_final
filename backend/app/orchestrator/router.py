"""Lógica de enrutamiento del orquestador."""

from __future__ import annotations

from app.orchestrator.registry import (
    AVAILABLE_AGENTS,
    resolve_agent_for_intent,
    resolve_intent_for_agent,
)
from app.orchestrator.types import AgentName, Intent, OrchestratorState


def resolve_intent(state: OrchestratorState) -> Intent:
    """Determina la intención a partir del estado de entrada."""
    explicit_agent = state.get("agent_name")
    if explicit_agent:
        intent = resolve_intent_for_agent(explicit_agent)
        if intent is not None:
            return intent

    if state.get("question_id"):
        return Intent.EXPLAIN_QUESTION

    if state.get("student_exam_id") and explicit_agent == AgentName.DIAGNOSTIC.value:
        return Intent.ANALYZE_DIAGNOSTIC
    if state.get("student_exam_id") and explicit_agent == AgentName.MOTIVATOR.value:
        return Intent.MOTIVATE_STUDENT
    if state.get("student_exam_id") and explicit_agent == AgentName.PARENTS.value:
        return Intent.PARENT_REPORT

    return Intent.UNKNOWN


def route_request(state: OrchestratorState) -> dict:
    """Nodo router: resuelve intent y agente destino."""
    explicit_agent = state.get("agent_name")
    if explicit_agent:
        try:
            agent = AgentName(explicit_agent)
        except ValueError:
            return {
                "intent": Intent.UNKNOWN.value,
                "selected_agent": None,
                "error": f"Agente desconocido: {explicit_agent}",
            }
        if agent not in AVAILABLE_AGENTS:
            return {
                "intent": Intent.UNKNOWN.value,
                "selected_agent": None,
                "error": f"Agente no disponible: {explicit_agent}",
            }
        intent = resolve_intent_for_agent(explicit_agent) or Intent.UNKNOWN
        return {"intent": intent.value, "selected_agent": agent.value}

    intent = resolve_intent(state)
    selected_agent = resolve_agent_for_intent(intent)
    update: dict = {"intent": intent.value}

    if selected_agent is not None:
        update["selected_agent"] = selected_agent.value
    else:
        update["selected_agent"] = None
        update["error"] = f"No hay agente registrado para la intención '{intent.value}'."

    return update


def route_after_router(state: OrchestratorState) -> str:
    """Arista condicional: devuelve el nodo del agente a ejecutar."""
    if state.get("error"):
        return "__end__"

    selected = state.get("selected_agent")
    if selected and selected in {agent.value for agent in AgentName}:
        return selected

    return "__end__"
