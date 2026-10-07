"""Contexto de ejecución compartido (MySQL + ChromaDB) para tools ADK."""

from __future__ import annotations

import contextvars
from dataclasses import dataclass, field
from typing import Any

from sqlalchemy.orm import Session

from app.rag.rag_service import RAGService


@dataclass
class AgentRuntimeContext:
    session: Session
    rag_service: RAGService
    student_id: int | None = None
    rag_sources: list[dict] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)


_agent_runtime: contextvars.ContextVar[AgentRuntimeContext | None] = contextvars.ContextVar(
    "agent_runtime",
    default=None,
)


def get_agent_runtime() -> AgentRuntimeContext:
    runtime = _agent_runtime.get()
    if runtime is None:
        raise RuntimeError("Agent runtime no inicializado.")
    return runtime


def set_agent_runtime(runtime: AgentRuntimeContext) -> contextvars.Token:
    return _agent_runtime.set(runtime)


def reset_agent_runtime(token: contextvars.Token) -> None:
    _agent_runtime.reset(token)
