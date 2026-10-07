from pydantic import BaseModel, Field


class FlashcardResponse(BaseModel):
    question_id: int
    front: str
    back: str
    subtopic_name: str
    source: str
    curriculum_origins: list[str] = Field(default_factory=list)


class ConceptMapNodeResponse(BaseModel):
    id: int
    name: str
    entity_type: str
    score_percent: float | None = None
    level: str | None = None
    children: list["ConceptMapNodeResponse"] = Field(default_factory=list)


ConceptMapNodeResponse.model_rebuild()
