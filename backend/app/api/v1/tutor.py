from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.agents.exceptions import TutorError
from app.agents.tutor_service import TutorExplanation, TutorService
from app.core.dependencies import get_current_student_id, get_db
from app.schemas.tutor import (
    AcademicContextResponse,
    RAGSourceResponse,
    TutorExplainRequest,
    TutorExplainResponse,
)

router = APIRouter(prefix="/tutor", tags=["Tutor IA"])


def get_tutor_service(db: Session = Depends(get_db)) -> TutorService:
    return TutorService(db)


def _handle_tutor_error(exc: TutorError) -> HTTPException:
    status_code = status.HTTP_400_BAD_REQUEST
    if exc.code == "question_not_found":
        status_code = status.HTTP_404_NOT_FOUND
    elif exc.code == "llm_configuration_error":
        status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    elif exc.code == "llm_request_error":
        status_code = status.HTTP_502_BAD_GATEWAY
    return HTTPException(status_code=status_code, detail={"code": exc.code, "message": exc.message})


def _to_response(result: TutorExplanation) -> TutorExplainResponse:
    return TutorExplainResponse(
        question_id=result.question_id,
        explanation=result.explanation,
        academic_context=AcademicContextResponse(
            question_id=result.academic_context.question_id,
            subtopic_id=result.academic_context.subtopic_id,
            subtopic_name=result.academic_context.subtopic_name,
            topic_name=result.academic_context.topic_name,
            component_name=result.academic_context.component_name,
            area_name=result.academic_context.area_name,
            admission_context=result.academic_context.admission_context,
        ),
        rag_sources=[RAGSourceResponse(**source) for source in result.rag_sources],
        llm_model=result.llm_model,
        llm_provider=result.llm_provider,
    )


@router.post(
    "/explain",
    response_model=TutorExplainResponse,
    summary="Explicar una pregunta con RAG + LLM",
)
def explain_question(
    payload: TutorExplainRequest,
    service: TutorService = Depends(get_tutor_service),
    student_id: int = Depends(get_current_student_id),
) -> TutorExplainResponse:
    try:
        result = service.explain(
            payload.question_id,
            student_message=payload.student_message,
            selected_option_id=payload.selected_option_id,
            top_k=payload.top_k,
            student_id=student_id,
        )
        return _to_response(result)
    except TutorError as exc:
        raise _handle_tutor_error(exc) from exc


@router.post(
    "/hint",
    response_model=TutorExplainResponse,
    summary="Tip breve de resolución (sin revelar la respuesta)",
)
def hint_question(
    payload: TutorExplainRequest,
    service: TutorService = Depends(get_tutor_service),
    student_id: int = Depends(get_current_student_id),
) -> TutorExplainResponse:
    try:
        result = service.hint(
            payload.question_id,
            selected_option_id=payload.selected_option_id,
            top_k=payload.top_k,
            student_id=student_id,
        )
        return _to_response(result)
    except TutorError as exc:
        raise _handle_tutor_error(exc) from exc
