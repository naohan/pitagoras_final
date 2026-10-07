from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.schemas.study_techniques import (
    ErrorGuidanceResponse,
    FeynmanAnalyzeRequest,
    FeynmanAnalyzeResponse,
)
from app.study_techniques.service import ErrorLearningService, FeynmanService

router = APIRouter(prefix="/study-techniques", tags=["Técnicas de estudio"])


@router.post(
    "/feynman/analyze",
    response_model=FeynmanAnalyzeResponse,
    summary="Técnica Feynman — analiza explicación del estudiante (sin LLM)",
)
def analyze_feynman(
    payload: FeynmanAnalyzeRequest,
    db: Session = Depends(get_db),
) -> FeynmanAnalyzeResponse:
    result = FeynmanService(db).analyze(
        subtopic_name=payload.subtopic_name,
        subtopic_key=payload.subtopic_key,
        explanation=payload.explanation,
    )
    return FeynmanAnalyzeResponse(
        score_percent=result.score_percent,
        strengths=result.strengths,
        gaps=result.gaps,
        suggestions=result.suggestions,
    )


@router.get(
    "/questions/{question_id}/error-guidance",
    response_model=ErrorGuidanceResponse,
    summary="Aprendizaje por errores — guía sin revelar la respuesta correcta",
)
def get_error_guidance(
    question_id: int,
    selected_option_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
) -> ErrorGuidanceResponse:
    try:
        guidance = ErrorLearningService(db).get_guidance(
            question_id,
            selected_option_id=selected_option_id,
        )
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc

    return ErrorGuidanceResponse(
        question_id=guidance.question_id,
        error_step=guidance.error_step,
        concept_name=guidance.concept_name,
        concept_reminder=guidance.concept_reminder,
        quick_tip=guidance.quick_tip,
        similar_question_id=guidance.similar_question_id,
        similar_question_stem=guidance.similar_question_stem,
        has_rich_data=guidance.has_rich_data,
        allow_retry=guidance.allow_retry,
    )
