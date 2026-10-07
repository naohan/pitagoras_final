from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import QuestionLevel


class QuestionOptionBase(BaseModel):
    label: str = Field(..., max_length=1)
    text: str
    is_correct: bool = False
    display_order: int = Field(default=0, ge=0)


class QuestionOptionCreate(QuestionOptionBase):
    pass


class QuestionOptionResponse(QuestionOptionBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime


class QuestionBase(BaseModel):
    subtopic_id: int
    stem: str
    explanation: str | None = None
    difficulty: int = Field(default=3, ge=1, le=5)
    level: QuestionLevel = QuestionLevel.INTERMEDIATE
    avg_time_seconds: int | None = Field(default=None, ge=0)
    tags: dict[str, Any] | list[Any] | None = None
    is_active: bool = True


class QuestionCreate(QuestionBase):
    options: list[QuestionOptionCreate] = Field(default_factory=list)


class QuestionUpdate(BaseModel):
    subtopic_id: int | None = None
    stem: str | None = None
    explanation: str | None = None
    difficulty: int | None = Field(default=None, ge=1, le=5)
    level: QuestionLevel | None = None
    avg_time_seconds: int | None = Field(default=None, ge=0)
    tags: dict[str, Any] | list[Any] | None = None
    is_active: bool | None = None
    options: list[QuestionOptionCreate] | None = None


class QuestionResponse(QuestionBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
    options: list[QuestionOptionResponse] = Field(default_factory=list)
