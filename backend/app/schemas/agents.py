from typing import Any

from pydantic import BaseModel, Field


class AgentRunRequest(BaseModel):
    student_exam_id: int = Field(..., gt=0)
    student_message: str | None = Field(
        default=None,
        description="Mensaje opcional del estudiante (aplica al motivador)",
    )


class AgentRunResponse(BaseModel):
    agent_name: str
    student_exam_id: int | None = None
    question_id: int | None = None
    content: str
    rag_sources: list[dict[str, Any]] = Field(default_factory=list)
    llm_model: str
    llm_provider: str
    metadata: dict[str, Any] = Field(default_factory=dict)
