"""Configuración del agente Motivador."""

from app.agents.shared.config import AgentConfig

motivator_agent_config = AgentConfig(
    app_name="pitagoras_motivator",
    agent_name="pitagoras_motivator",
    description="Agente motivacional para estudiantes en preparación de admisión universitaria.",
    temperature=0.5,
)
