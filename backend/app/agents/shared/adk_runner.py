"""Ejecutor ADK reutilizable por todos los agentes."""

from __future__ import annotations

import uuid

from google.adk.agents import Agent
from google.adk.runners import InMemoryRunner
from google.adk.utils.context_utils import Aclosing
from google.genai import types

from app.agents.shared.runtime import AgentRuntimeContext, reset_agent_runtime, set_agent_runtime


async def run_adk_agent(
    *,
    agent: Agent,
    app_name: str,
    user_message: str,
    runtime: AgentRuntimeContext,
) -> str:
    token = set_agent_runtime(runtime)
    try:
        async with InMemoryRunner(agent=agent, app_name=app_name) as runner:
            adk_session = await runner.session_service.create_session(
                app_name=app_name,
                user_id="pitagoras",
                session_id=str(uuid.uuid4()),
            )

            explanation = ""
            async with Aclosing(
                runner.run_async(
                    user_id=adk_session.user_id,
                    session_id=adk_session.id,
                    new_message=types.Content(
                        role="user",
                        parts=[types.Part(text=user_message)],
                    ),
                )
            ) as event_stream:
                async for event in event_stream:
                    if event.content and event.is_final_response():
                        explanation = _extract_text(event.content)
            return explanation.strip()
    finally:
        reset_agent_runtime(token)


def _extract_text(content: types.Content) -> str:
    if not content.parts:
        return ""
    parts = [part.text for part in content.parts if part.text and not part.thought]
    return "\n".join(parts)
