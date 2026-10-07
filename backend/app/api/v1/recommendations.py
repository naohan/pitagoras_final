from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.diagnostics.exceptions import DiagnosticError
from app.recommendations.exceptions import RecommendationError
from app.recommendations.recommendation_service import RecommendationService, StudyPlan
from app.schemas.recommendation import (
    RecommendationRuleResponse,
    StudyPlanResponse,
    StudyRecommendationResponse,
)

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


def _recommendation_service(db: Session = Depends(get_db)) -> RecommendationService:
    return RecommendationService(db)


def _handle_errors(exc: Exception) -> HTTPException:
    if isinstance(exc, DiagnosticError):
        code = exc.code
        if code == "exam_not_completed":
            return HTTPException(status.HTTP_409_CONFLICT, detail={"code": code, "message": exc.message})
        return HTTPException(status.HTTP_404_NOT_FOUND, detail={"code": code, "message": exc.message})
    if isinstance(exc, RecommendationError):
        return HTTPException(status.HTTP_400_BAD_REQUEST, detail={"code": exc.code, "message": exc.message})
    raise exc


def _to_plan_response(plan: StudyPlan) -> StudyPlanResponse:
    return StudyPlanResponse(
        student_exam_id=plan.student_exam_id,
        global_score_percent=plan.global_score_percent,
        estimated_days=plan.estimated_days,
        focus_subtopics=plan.focus_subtopics,
        recommendations=[StudyRecommendationResponse.model_validate(r) for r in plan.recommendations],
        by_resource_type={
            key: [StudyRecommendationResponse.model_validate(r) for r in items]
            for key, items in plan.by_resource_type.items()
        },
    )


@router.get(
    "/student-exams/{student_exam_id}",
    response_model=StudyPlanResponse,
    summary="Plan de estudio basado en diagnóstico y reglas",
)
def get_study_plan(
    student_exam_id: int,
    service: RecommendationService = Depends(_recommendation_service),
) -> StudyPlanResponse:
    try:
        plan = service.get_study_plan(student_exam_id)
        return _to_plan_response(plan)
    except (DiagnosticError, RecommendationError) as exc:
        raise _handle_errors(exc) from exc


@router.get(
    "/rules",
    response_model=list[RecommendationRuleResponse],
    summary="Listar reglas de recomendación activas",
)
def list_recommendation_rules(
    service: RecommendationService = Depends(_recommendation_service),
) -> list[RecommendationRuleResponse]:
    return [RecommendationRuleResponse.model_validate(r) for r in service.list_rules()]
