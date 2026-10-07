from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class CareerBase(BaseModel):
    university_id: int
    code: str = Field(..., max_length=30)
    name: str = Field(..., max_length=150)
    is_active: bool = True
    target_score: Decimal | None = None
    score_min: Decimal | None = None
    score_max: Decimal | None = None


class CareerCreate(CareerBase):
    pass


class CareerUpdate(BaseModel):
    university_id: int | None = None
    code: str | None = Field(default=None, max_length=30)
    name: str | None = Field(default=None, max_length=150)
    is_active: bool | None = None
    target_score: Decimal | None = None
    score_min: Decimal | None = None
    score_max: Decimal | None = None


class CareerResponse(CareerBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
    score_range_label: str | None = None
