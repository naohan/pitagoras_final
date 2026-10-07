from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class SubtopicBase(BaseModel):
    topic_id: int
    name: str = Field(..., max_length=100)
    display_order: int = Field(default=0, ge=0)
    is_active: bool = True


class SubtopicCreate(SubtopicBase):
    pass


class SubtopicUpdate(BaseModel):
    topic_id: int | None = None
    name: str | None = Field(default=None, max_length=100)
    display_order: int | None = Field(default=None, ge=0)
    is_active: bool | None = None


class SubtopicResponse(SubtopicBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
