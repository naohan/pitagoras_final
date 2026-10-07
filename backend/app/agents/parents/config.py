"""Configuración del agente Padres."""

from app.agents.shared.config import AgentConfig

parents_agent_config = AgentConfig(
    app_name="pitagoras_parents",
    agent_name="pitagoras_parents",
    description="Agente que genera informes de progreso para padres de familia.",
    temperature=0.3,
)
