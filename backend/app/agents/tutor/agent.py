"""Definición del agente Tutor con Google ADK."""

from __future__ import annotations

from functools import lru_cache

from google.adk.agents import Agent

from app.agents.shared.config import resolve_adk_model
from app.agents.tutor.config import tutor_agent_config
from app.agents.tutor.instructions import TUTOR_AGENT_INSTRUCTION, TUTOR_STATIC_INSTRUCTION
from app.agents.tutor.tools import get_question_context, search_subtopic_material


@lru_cache(maxsize=1)
def get_root_agent() -> Agent:
    return Agent(
        name=tutor_agent_config.agent_name,
        model=resolve_adk_model(temperature=tutor_agent_config.temperature),
        description=tutor_agent_config.description,
        static_instruction=TUTOR_STATIC_INSTRUCTION,
        instruction=TUTOR_AGENT_INSTRUCTION,
        tools=[get_question_context, search_subtopic_material],
    )
