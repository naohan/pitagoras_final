from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.models.enums import StudyPurpose


class AdmissionExamTargetResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    university_id: int
    code: str
    label: str
    short_label: str
    description: str
    simulacro_focus: str
    display_order: int
    is_active: bool


class AdmissionProcessResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    career_id: int
    name: str
    year: int
    description: str | None = None
    is_active: bool
    created_at: datetime
    updated_at: datetime


class PreparationProfileUpdate(BaseModel):
    purpose: StudyPurpose | None = None
    university_id: int | None = None
    career_id: int | None = None
    admission_process_id: int | None = None
    exam_target_code: str | None = Field(default=None, max_length=40)
    focus_subtopic_id: int | None = None

    @model_validator(mode="after")
    def validate_by_purpose(self) -> "PreparationProfileUpdate":
        purpose = self.purpose or StudyPurpose.ADMISSION
        if purpose == StudyPurpose.ADMISSION:
            if self.university_id is None or self.career_id is None:
                raise ValueError("university_and_career_required_for_admission")
        if purpose == StudyPurpose.TOPIC_LEARNING and self.focus_subtopic_id is None:
            raise ValueError("focus_subtopic_required_for_topic_learning")
        return self


class PreparationProfileResponse(BaseModel):
    purpose: StudyPurpose | None = None
    university_id: int | None = None
    university_code: str | None = None
    university_name: str | None = None
    career_id: int | None = None
    career_code: str | None = None
    career_name: str | None = None
    admission_process_id: int | None = None
    exam_target_code: str | None = None
    exam_target_label: str | None = None
    focus_subtopic_id: int | None = None
    focus_subtopic_name: str | None = None
    focus_topic_name: str | None = None
    focus_area_name: str | None = None
    learning_title: str | None = None
    target_score: Decimal | None = None
    score_min: Decimal | None = None
    score_max: Decimal | None = None
    meta_title: str | None = None
