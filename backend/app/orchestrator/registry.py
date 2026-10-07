"""Registro de agentes disponibles para el orquestador."""

from __future__ import annotations

from app.orchestrator.types import AgentName, Intent

INTENT_TO_AGENT: dict[Intent, AgentName] = {
    Intent.EXPLAIN_QUESTION: AgentName.TUTOR,
    Intent.ANALYZE_DIAGNOSTIC: AgentName.DIAGNOSTIC,
    Intent.MOTIVATE_STUDENT: AgentName.MOTIVATOR,
    Intent.PARENT_REPORT: AgentName.PARENTS,
}

AGENT_TO_INTENT: dict[AgentName, Intent] = {agent: intent for intent, agent in INTENT_TO_AGENT.items()}

AVAILABLE_AGENTS: frozenset[AgentName] = frozenset(AgentName)


def resolve_agent_for_intent(intent: Intent) -> AgentName | None:
    return INTENT_TO_AGENT.get(intent)


def resolve_intent_for_agent(agent_name: str) -> Intent | None:
    try:
        agent = AgentName(agent_name)
    except ValueError:
        return None
    return AGENT_TO_INTENT.get(agent)
