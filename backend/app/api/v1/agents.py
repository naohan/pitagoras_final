from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.agents.exceptions import TutorError
from app.agents.types import AgentResponse
from app.core.dependencies import get_db
from app.diagnostics.exceptions import DiagnosticError
from app.orchestrator.exceptions import OrchestratorError
from app.orchestrator.service import OrchestratorService
from app.schemas.agents import AgentRunRequest, AgentRunResponse

router = APIRouter(prefix="/agents", tags=["Agentes IA"])


def get_orchestrator(db: Session = Depends(get_db)) -> OrchestratorService:
    return OrchestratorService(db)


def _handle_agent_error(exc: TutorError | OrchestratorError | DiagnosticError) -> HTTPException:
    status_code = status.HTTP_400_BAD_REQUEST
    if exc.code == "question_not_found":
        status_code = status.HTTP_404_NOT_FOUND
    elif exc.code in ("diagnostic_not_found",):
        status_code = status.HTTP_404_NOT_FOUND
    elif exc.code == "exam_not_completed":
        status_code = status.HTTP_409_CONFLICT
    elif exc.code == "llm_configuration_error":
        status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    elif exc.code in ("llm_request_error", "orchestrator_routing_error"):
        status_code = status.HTTP_502_BAD_GATEWAY
    return HTTPException(status_code=status_code, detail={"code": exc.code, "message": exc.message})


def _to_response(result: AgentResponse) -> AgentRunResponse:
    return AgentRunResponse(
        agent_name=result.agent_name,
        student_exam_id=result.student_exam_id,
        question_id=result.question_id,
        content=result.content,
        rag_sources=result.rag_sources,
        llm_model=result.llm_model,
        llm_provider=result.llm_provider,
        metadata=result.metadata,
    )


@router.post(
    "/diagnostic/analyze",
    response_model=AgentRunResponse,
    summary="Análisis diagnóstico con IA",
)
def analyze_diagnostic(
    payload: AgentRunRequest,
    orchestrator: OrchestratorService = Depends(get_orchestrator),
) -> AgentRunResponse:
    try:
        result = orchestrator.analyze_diagnostic(payload.student_exam_id)
        return _to_response(result)
    except (TutorError, OrchestratorError, DiagnosticError) as exc:
        raise _handle_agent_error(exc) from exc


@router.post(
    "/motivator/encourage",
    response_model=AgentRunResponse,
    summary="Mensaje motivacional personalizado",
)
def encourage_student(
    payload: AgentRunRequest,
    orchestrator: OrchestratorService = Depends(get_orchestrator),
) -> AgentRunResponse:
    try:
        result = orchestrator.motivate_student(
            payload.student_exam_id,
            student_message=payload.student_message,
        )
        return _to_response(result)
    except (TutorError, OrchestratorError, DiagnosticError) as exc:
        raise _handle_agent_error(exc) from exc


@router.post(
    "/parents/report",
    response_model=AgentRunResponse,
    summary="Informe de progreso para padres",
)
def parent_report(
    payload: AgentRunRequest,
    orchestrator: OrchestratorService = Depends(get_orchestrator),
) -> AgentRunResponse:
    try:
        result = orchestrator.parent_report(payload.student_exam_id)
        return _to_response(result)
    except (TutorError, OrchestratorError, DiagnosticError) as exc:
        raise _handle_agent_error(exc) from exc
