from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class AreaBase(BaseModel):
    admission_process_id: int
    name: str = Field(..., max_length=100)
    weight_percent: Decimal = Field(..., ge=0, le=100)
    display_order: int = Field(default=0, ge=0)
    is_active: bool = True


class AreaCreate(AreaBase):
    pass


class AreaUpdate(BaseModel):
    admission_process_id: int | None = None
    name: str | None = Field(default=None, max_length=100)
    weight_percent: Decimal | None = Field(default=None, ge=0, le=100)
    display_order: int | None = Field(default=None, ge=0)
    is_active: bool | None = None


class AreaResponse(AreaBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
