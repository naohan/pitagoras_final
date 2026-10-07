"""Definición del agente Diagnóstico con Google ADK."""

from __future__ import annotations

from functools import lru_cache

from google.adk.agents import Agent

from app.agents.diagnostic.config import diagnostic_agent_config
from app.agents.diagnostic.instructions import (
    DIAGNOSTIC_AGENT_INSTRUCTION,
    DIAGNOSTIC_STATIC_INSTRUCTION,
)
from app.agents.diagnostic.tools import get_exam_diagnostic_report, search_subtopic_material
from app.agents.shared.config import resolve_adk_model


@lru_cache(maxsize=1)
def get_diagnostic_agent() -> Agent:
    return Agent(
        name=diagnostic_agent_config.agent_name,
        model=resolve_adk_model(temperature=diagnostic_agent_config.temperature),
        description=diagnostic_agent_config.description,
        static_instruction=DIAGNOSTIC_STATIC_INSTRUCTION,
        instruction=DIAGNOSTIC_AGENT_INSTRUCTION,
        tools=[get_exam_diagnostic_report, search_subtopic_material],
    )
