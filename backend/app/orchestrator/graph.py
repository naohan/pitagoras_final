"""Construcción del grafo LangGraph del orquestador."""

from __future__ import annotations

from langgraph.graph import END, START, StateGraph
from sqlalchemy.orm import Session

from app.orchestrator.nodes import (
    build_diagnostic_node,
    build_motivator_node,
    build_parents_node,
    build_tutor_node,
)
from app.orchestrator.router import route_after_router, route_request
from app.orchestrator.types import AgentName, OrchestratorState
from app.rag.rag_service import RAGService


def build_orchestrator_graph(
    session: Session,
    rag_service: RAGService | None = None,
):
    graph = StateGraph(OrchestratorState)

    graph.add_node("router", route_request)
    graph.add_node(AgentName.TUTOR.value, build_tutor_node(session, rag_service))
    graph.add_node(AgentName.DIAGNOSTIC.value, build_diagnostic_node(session, rag_service))
    graph.add_node(AgentName.MOTIVATOR.value, build_motivator_node(session, rag_service))
    graph.add_node(AgentName.PARENTS.value, build_parents_node(session, rag_service))

    graph.add_edge(START, "router")
    graph.add_conditional_edges(
        "router",
        route_after_router,
        {
            AgentName.TUTOR.value: AgentName.TUTOR.value,
            AgentName.DIAGNOSTIC.value: AgentName.DIAGNOSTIC.value,
            AgentName.MOTIVATOR.value: AgentName.MOTIVATOR.value,
            AgentName.PARENTS.value: AgentName.PARENTS.value,
            "__end__": END,
        },
    )
    for agent in AgentName:
        graph.add_edge(agent.value, END)

    return graph.compile()
