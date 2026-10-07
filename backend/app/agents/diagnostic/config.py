"""Configuración del agente Diagnóstico."""

from app.agents.shared.config import AgentConfig

diagnostic_agent_config = AgentConfig(
    app_name="pitagoras_diagnostic",
    agent_name="pitagoras_diagnostic",
    description="Agente que interpreta el diagnóstico académico post-examen con IA.",
    temperature=0.3,
)
