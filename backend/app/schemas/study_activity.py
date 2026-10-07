from datetime import date

from pydantic import BaseModel, Field

from app.models.enums import StudyActivityType


class StudyActivityRecordRequest(BaseModel):
    activity_type: StudyActivityType
    ref_id: str | None = Field(default=None, max_length=64)


class StudyActivityRecordResponse(BaseModel):
    id: int
    student_id: int
    activity_type: StudyActivityType
    activity_date: date
    ref_id: str


class StreakResponse(BaseModel):
    current_streak: int
    longest_streak: int
    week_mask: list[bool] = Field(..., min_length=7, max_length=7)
    last_activity_date: date | None = None
