"""Tipos del orquestador LangGraph."""

from __future__ import annotations

from enum import StrEnum
from typing import Any, TypedDict

from app.agents.types import AgentResponse, TutorExplanation


class AgentName(StrEnum):
    TUTOR = "tutor"
    DIAGNOSTIC = "diagnostic"
    MOTIVATOR = "motivator"
    PARENTS = "parents"


class Intent(StrEnum):
    EXPLAIN_QUESTION = "explain_question"
    ANALYZE_DIAGNOSTIC = "analyze_diagnostic"
    MOTIVATE_STUDENT = "motivate_student"
    PARENT_REPORT = "parent_report"
    UNKNOWN = "unknown"


class OrchestratorState(TypedDict, total=False):
    intent: str
    agent_name: str | None
    selected_agent: str | None
    question_id: int
    student_exam_id: int
    student_message: str | None
    selected_option_id: int | None
    top_k: int | None
    result: TutorExplanation | AgentResponse | None
    error: str | None
    metadata: dict[str, Any]
