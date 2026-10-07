from decimal import Decimal
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class PerformanceLevel(str, Enum):
    STRENGTH = "strength"
    NEUTRAL = "neutral"
    WEAKNESS = "weakness"


class DiagnosticItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    entity_id: int
    name: str
    total_questions: int
    correct_answers: int
    score_percent: Decimal
    level: PerformanceLevel
    parent_name: str | None = None


class DiagnosticReportResponse(BaseModel):
    student_exam_id: int
    global_score_percent: Decimal
    total_questions: int
    correct_answers: int
    areas: list[DiagnosticItemResponse] = Field(default_factory=list)
    components: list[DiagnosticItemResponse] = Field(default_factory=list)
    topics: list[DiagnosticItemResponse] = Field(default_factory=list)
    subtopics: list[DiagnosticItemResponse] = Field(default_factory=list)
    strengths: list[str] = Field(default_factory=list)
    weaknesses: list[str] = Field(default_factory=list)
