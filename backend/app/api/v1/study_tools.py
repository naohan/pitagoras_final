from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_owned_student_exam
from app.diagnostics.exceptions import DiagnosticError, DiagnosticNotFoundError, ExamNotCompletedError
from app.models.exam import StudentExam
from app.schemas.study_tools import ConceptMapNodeResponse, FlashcardResponse
from app.study_tools.service import ConceptMapService, FlashcardService

router = APIRouter(prefix="/study-tools", tags=["Herramientas de estudio"])


def _handle_error(exc: DiagnosticError) -> HTTPException:
    code = status.HTTP_400_BAD_REQUEST
    if isinstance(exc, DiagnosticNotFoundError):
        code = status.HTTP_404_NOT_FOUND
    elif isinstance(exc, ExamNotCompletedError):
        code = status.HTTP_409_CONFLICT
    return HTTPException(status_code=code, detail=exc.message)


@router.get(
    "/student-exams/{student_exam_id}/flashcards",
    response_model=list[FlashcardResponse],
    summary="Flashcards desde errores y subtemas débiles (sin IA)",
)
def get_flashcards(
    owned: StudentExam = Depends(get_owned_student_exam),
    limit: int = 20,
    db: Session = Depends(get_db),
) -> list[FlashcardResponse]:
    try:
        cards = FlashcardService(db).get_flashcards(owned.id, limit=min(limit, 50))
        return [
            FlashcardResponse(
                question_id=card.question_id,
                front=card.front,
                back=card.back,
                subtopic_name=card.subtopic_name,
                source=card.source,
                curriculum_origins=card.curriculum_origins,
            )
            for card in cards
        ]
    except DiagnosticError as exc:
        raise _handle_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/concept-map",
    response_model=list[ConceptMapNodeResponse],
    summary="Árbol de dominio académico con puntajes del diagnóstico (sin IA)",
)
def get_concept_map(
    owned: StudentExam = Depends(get_owned_student_exam),
    db: Session = Depends(get_db),
) -> list[ConceptMapNodeResponse]:
    try:
        nodes = ConceptMapService(db).get_concept_map(owned.id)
        return [_to_response(node) for node in nodes]
    except DiagnosticError as exc:
        raise _handle_error(exc) from exc


def _to_response(node) -> ConceptMapNodeResponse:
    return ConceptMapNodeResponse(
        id=node.id,
        name=node.name,
        entity_type=node.entity_type,
        score_percent=node.score_percent,
        level=node.level,
        children=[_to_response(child) for child in node.children],
    )
