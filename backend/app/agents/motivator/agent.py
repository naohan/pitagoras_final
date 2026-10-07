"""Definición del agente Motivador con Google ADK."""

from __future__ import annotations

from functools import lru_cache

from google.adk.agents import Agent

from app.agents.motivator.config import motivator_agent_config
from app.agents.motivator.instructions import (
    MOTIVATOR_AGENT_INSTRUCTION,
    MOTIVATOR_STATIC_INSTRUCTION,
)
from app.agents.motivator.tools import get_exam_diagnostic_report, get_study_plan_summary
from app.agents.shared.config import resolve_adk_model


@lru_cache(maxsize=1)
def get_motivator_agent() -> Agent:
    return Agent(
        name=motivator_agent_config.agent_name,
        model=resolve_adk_model(temperature=motivator_agent_config.temperature),
        description=motivator_agent_config.description,
        static_instruction=MOTIVATOR_STATIC_INSTRUCTION,
        instruction=MOTIVATOR_AGENT_INSTRUCTION,
        tools=[get_exam_diagnostic_report, get_study_plan_summary],
    )
