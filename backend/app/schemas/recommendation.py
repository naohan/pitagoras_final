from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.recommendations.types import ResourceType


class RecommendationRuleResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    resource_type: ResourceType
    min_percent: Decimal
    max_percent: Decimal
    priority: int
    message_template: str


class StudyRecommendationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    entity_type: str
    entity_id: int
    entity_name: str
    score_percent: Decimal
    resource_type: ResourceType
    rule_id: str
    message: str


class StudyPlanResponse(BaseModel):
    student_exam_id: int
    global_score_percent: Decimal
    estimated_days: int
    focus_subtopics: list[str] = Field(default_factory=list)
    recommendations: list[StudyRecommendationResponse] = Field(default_factory=list)
    by_resource_type: dict[str, list[StudyRecommendationResponse]] = Field(
        default_factory=dict
    )
