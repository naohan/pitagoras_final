"""Tipos compartidos del módulo de agentes."""

from dataclasses import dataclass, field
from typing import Any


@dataclass
class AcademicContext:
    question_id: int
    subtopic_id: int
    subtopic_name: str
    topic_name: str
    component_name: str
    area_name: str
    admission_context: str


@dataclass
class TutorExplanation:
    question_id: int
    explanation: str
    academic_context: AcademicContext
    rag_sources: list[dict] = field(default_factory=list)
    llm_model: str = ""
    llm_provider: str = ""


@dataclass
class AgentResponse:
    agent_name: str
    content: str
    student_exam_id: int | None = None
    question_id: int | None = None
    rag_sources: list[dict] = field(default_factory=list)
    llm_model: str = ""
    llm_provider: str = ""
    metadata: dict[str, Any] = field(default_factory=dict)
