from typing import Any

from pydantic import BaseModel, Field


class TutorExplainRequest(BaseModel):
    question_id: int = Field(..., gt=0)
    student_message: str | None = Field(
        default=None,
        description="Mensaje opcional del estudiante (ej. 'No entiendo por qué es B')",
    )
    selected_option_id: int | None = Field(
        default=None,
        description="Opción que eligió el estudiante, si aplica",
    )
    top_k: int | None = Field(default=None, ge=1, le=10)


class AcademicContextResponse(BaseModel):
    question_id: int
    subtopic_id: int
    subtopic_name: str
    topic_name: str
    component_name: str
    area_name: str
    admission_context: str


class RAGSourceResponse(BaseModel):
    id: str
    score: float
    text: str
    metadata: dict[str, Any] = Field(default_factory=dict)


class TutorExplainResponse(BaseModel):
    question_id: int
    explanation: str
    academic_context: AcademicContextResponse
    rag_sources: list[RAGSourceResponse] = Field(default_factory=list)
    llm_model: str
    llm_provider: str
