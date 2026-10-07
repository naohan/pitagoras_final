from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class UniversityBase(BaseModel):
    code: str = Field(..., max_length=20)
    name: str = Field(..., max_length=150)
    country: str = Field(default="PE", max_length=60)
    is_active: bool = True


class UniversityCreate(UniversityBase):
    pass


class UniversityUpdate(BaseModel):
    code: str | None = Field(default=None, max_length=20)
    name: str | None = Field(default=None, max_length=150)
    country: str | None = Field(default=None, max_length=60)
    is_active: bool | None = None


class UniversityResponse(UniversityBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime
