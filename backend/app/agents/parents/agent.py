"""Definición del agente Padres con Google ADK."""

from __future__ import annotations

from functools import lru_cache

from google.adk.agents import Agent

from app.agents.parents.config import parents_agent_config
from app.agents.parents.instructions import PARENTS_AGENT_INSTRUCTION, PARENTS_STATIC_INSTRUCTION
from app.agents.parents.tools import get_exam_diagnostic_report, get_study_plan_summary
from app.agents.shared.config import resolve_adk_model


@lru_cache(maxsize=1)
def get_parents_agent() -> Agent:
    return Agent(
        name=parents_agent_config.agent_name,
        model=resolve_adk_model(temperature=parents_agent_config.temperature),
        description=parents_agent_config.description,
        static_instruction=PARENTS_STATIC_INSTRUCTION,
        instruction=PARENTS_AGENT_INSTRUCTION,
        tools=[get_exam_diagnostic_report, get_study_plan_summary],
    )
