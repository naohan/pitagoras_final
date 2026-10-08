from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_owned_student_exam
from app.diagnostics.diagnostic_service import DiagnosticReport, DiagnosticService
from app.diagnostics.exceptions import DiagnosticError
from app.models.exam import StudentExam
from app.schemas.diagnostic import DiagnosticItemResponse, DiagnosticReportResponse

router = APIRouter(prefix="/diagnostics", tags=["Diagnostics"])


def _diagnostic_service(db: Session = Depends(get_db)) -> DiagnosticService:
    return DiagnosticService(db)


def _handle_diagnostic_error(exc: DiagnosticError) -> HTTPException:
    status_code = status.HTTP_400_BAD_REQUEST
    if exc.code in ("diagnostic_not_found",):
        status_code = status.HTTP_404_NOT_FOUND
    elif exc.code == "exam_not_completed":
        status_code = status.HTTP_409_CONFLICT
    return HTTPException(status_code=status_code, detail={"code": exc.code, "message": exc.message})


def _to_response(report: DiagnosticReport) -> DiagnosticReportResponse:
    return DiagnosticReportResponse(
        student_exam_id=report.student_exam_id,
        global_score_percent=report.global_score_percent,
        total_questions=report.total_questions,
        correct_answers=report.correct_answers,
        areas=[DiagnosticItemResponse.model_validate(i) for i in report.areas],
        components=[DiagnosticItemResponse.model_validate(i) for i in report.components],
        topics=[DiagnosticItemResponse.model_validate(i) for i in report.topics],
        subtopics=[DiagnosticItemResponse.model_validate(i) for i in report.subtopics],
        strengths=report.strengths,
        weaknesses=report.weaknesses,
    )


@router.get(
    "/student-exams/{student_exam_id}",
    response_model=DiagnosticReportResponse,
    summary="Obtener diagnóstico académico de un examen",
)
def get_exam_diagnostic(
    owned: StudentExam = Depends(get_owned_student_exam),
    service: DiagnosticService = Depends(_diagnostic_service),
) -> DiagnosticReportResponse:
    try:
        report = service.get_diagnostic(owned.id)
        return _to_response(report)
    except DiagnosticError as exc:
        raise _handle_diagnostic_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/areas",
    response_model=list[DiagnosticItemResponse],
    summary="Diagnóstico por área",
)
def get_diagnostic_by_areas(
    owned: StudentExam = Depends(get_owned_student_exam),
    service: DiagnosticService = Depends(_diagnostic_service),
) -> list[DiagnosticItemResponse]:
    try:
        report = service.get_diagnostic(owned.id)
        return [DiagnosticItemResponse.model_validate(i) for i in report.areas]
    except DiagnosticError as exc:
        raise _handle_diagnostic_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/components",
    response_model=list[DiagnosticItemResponse],
    summary="Diagnóstico por componente",
)
def get_diagnostic_by_components(
    owned: StudentExam = Depends(get_owned_student_exam),
    service: DiagnosticService = Depends(_diagnostic_service),
) -> list[DiagnosticItemResponse]:
    try:
        report = service.get_diagnostic(owned.id)
        return [DiagnosticItemResponse.model_validate(i) for i in report.components]
    except DiagnosticError as exc:
        raise _handle_diagnostic_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/topics",
    response_model=list[DiagnosticItemResponse],
    summary="Diagnóstico por tema",
)
def get_diagnostic_by_topics(
    owned: StudentExam = Depends(get_owned_student_exam),
    service: DiagnosticService = Depends(_diagnostic_service),
) -> list[DiagnosticItemResponse]:
    try:
        report = service.get_diagnostic(owned.id)
        return [DiagnosticItemResponse.model_validate(i) for i in report.topics]
    except DiagnosticError as exc:
        raise _handle_diagnostic_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/subtopics",
    response_model=list[DiagnosticItemResponse],
    summary="Diagnóstico por subtema",
)
def get_diagnostic_by_subtopics(
    owned: StudentExam = Depends(get_owned_student_exam),
    service: DiagnosticService = Depends(_diagnostic_service),
) -> list[DiagnosticItemResponse]:
    try:
        report = service.get_diagnostic(owned.id)
        return [DiagnosticItemResponse.model_validate(i) for i in report.subtopics]
    except DiagnosticError as exc:
        raise _handle_diagnostic_error(exc) from exc
