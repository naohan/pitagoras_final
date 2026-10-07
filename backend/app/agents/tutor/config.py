"""Configuración del agente Tutor Google ADK."""

from app.agents.shared.config import AgentConfig

tutor_agent_config = AgentConfig(
    app_name="pitagoras_tutor",
    agent_name="pitagoras_tutor",
    description="Tutor académico para exámenes de admisión universitaria en Perú.",
    temperature=0.3,
)
