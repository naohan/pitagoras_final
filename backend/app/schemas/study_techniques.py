from pydantic import BaseModel, Field


class FeynmanAnalyzeRequest(BaseModel):
    subtopic_name: str = Field(..., min_length=2, max_length=150)
    subtopic_key: str = Field(default="general", max_length=80)
    explanation: str = Field(..., min_length=10, max_length=4000)


class FeynmanAnalyzeResponse(BaseModel):
    score_percent: float
    strengths: list[str]
    gaps: list[str]
    suggestions: list[str]


class ErrorGuidanceResponse(BaseModel):
    question_id: int
    error_step: str
    concept_name: str
    concept_reminder: str
    quick_tip: str
    similar_question_id: int | None = None
    similar_question_stem: str | None = None
    has_rich_data: bool = False
    allow_retry: bool = True
