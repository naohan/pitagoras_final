import shutil
import tempfile
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.auth.auth_service import AuthUser
from app.core.dependencies import get_current_student_id, get_current_user, get_db
from app.curriculum.service import CurriculumService
from app.models.academic import AdmissionProcess, Area, Component, Subtopic, Topic
from app.rag.exceptions import RAGError
from app.rag.rag_service import RAGService
from app.schemas.rag import (
    RAGContextResponse,
    RAGDiagramNodeResponse,
    RAGDiagramRequest,
    RAGDiagramResponse,
    RAGIngestResponse,
    RAGIngestTextRequest,
    RAGSearchRequest,
    RAGSearchResponse,
    RAGSearchResultItem,
    RAGStatsResponse,
)

router = APIRouter(prefix="/rag", tags=["RAG"])


def get_rag_service() -> RAGService:
    return RAGService()


def _metadata_from_request(
    *,
    subtopic_id: int | None,
    topic_id: int | None,
    area_id: int | None,
    title: str | None,
    student_id: int | None = None,
) -> dict:
    meta: dict = {}
    if subtopic_id is not None:
        meta["subtopic_id"] = subtopic_id
    if topic_id is not None:
        meta["topic_id"] = topic_id
    if area_id is not None:
        meta["area_id"] = area_id
    if student_id is not None:
        meta["student_id"] = student_id
    if title:
        meta["title"] = title
    return meta


@router.post(
    "/ingest/text",
    response_model=RAGIngestResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Indexar texto plano en ChromaDB",
)
def ingest_text(
    payload: RAGIngestTextRequest,
    service: RAGService = Depends(get_rag_service),
    student_id: int = Depends(get_current_student_id),
) -> RAGIngestResponse:
    try:
        metadata = _metadata_from_request(
            subtopic_id=payload.subtopic_id,
            topic_id=payload.topic_id,
            area_id=payload.area_id,
            title=payload.title,
            student_id=student_id,
        )
        result = service.ingest_text(
            payload.text,
            source=payload.source,
            metadata=metadata,
        )
        return RAGIngestResponse(
            source=result.source,
            chunks_indexed=result.chunks_indexed,
            chunk_ids=result.chunk_ids,
        )
    except RAGError as exc:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=exc.message) from exc


@router.post(
    "/ingest/file",
    response_model=RAGIngestResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Indexar archivo (PDF, TXT, MD) en ChromaDB",
)
async def ingest_file(
    file: UploadFile = File(...),
    subtopic_id: int | None = Form(default=None),
    topic_id: int | None = Form(default=None),
    area_id: int | None = Form(default=None),
    title: str | None = Form(default=None),
    service: RAGService = Depends(get_rag_service),
    student_id: int = Depends(get_current_student_id),
) -> RAGIngestResponse:
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in {".txt", ".md", ".pdf"}:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=f"Unsupported format: {suffix}")

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name

        size_mb = Path(tmp_path).stat().st_size / (1024 * 1024)
        from app.core.config import settings

        if size_mb > settings.rag_max_upload_mb:
            Path(tmp_path).unlink(missing_ok=True)
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Archivo muy grande ({size_mb:.1f} MB). "
                    f"Máximo {settings.rag_max_upload_mb} MB. "
                    "Sube un capítulo en .txt o usa «Pegar texto» en la app."
                ),
            )

        metadata = _metadata_from_request(
            subtopic_id=subtopic_id,
            topic_id=topic_id,
            area_id=area_id,
            title=title or file.filename,
            student_id=student_id,
        )
        result = service.ingest_file(tmp_path, metadata=metadata)
        Path(tmp_path).unlink(missing_ok=True)
        return RAGIngestResponse(
            source=result.source,
            chunks_indexed=result.chunks_indexed,
            chunk_ids=result.chunk_ids,
            warning=result.warning,
        )
    except RAGError as exc:
        detail = _friendly_rag_error(exc)
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=detail) from exc
    except Exception as exc:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error al indexar el archivo: {exc}",
        ) from exc


def _friendly_rag_error(exc: RAGError) -> str:
    message = exc.message
    if "no extractable text" in message.lower() or "no se pudo extraer texto" in message.lower():
        return message
    if "pypdf is not installed" in message:
        return "El servidor no tiene soporte PDF instalado. Contacta al administrador."
    if exc.code == "unsupported_format":
        return message
    if "Failed to load document" in message:
        return message.split(":", 1)[-1].strip()
    return message


@router.post(
    "/search",
    response_model=RAGSearchResponse,
    summary="Búsqueda vectorial en la base de conocimiento",
)
def search_knowledge(
    payload: RAGSearchRequest,
    service: RAGService = Depends(get_rag_service),
    _: AuthUser = Depends(get_current_user),
) -> RAGSearchResponse:
    results = service.search(
        payload.query,
        top_k=payload.top_k,
        subtopic_id=payload.subtopic_id,
        topic_id=payload.topic_id,
        area_id=payload.area_id,
    )
    return RAGSearchResponse(
        query=payload.query,
        results=[
            RAGSearchResultItem(
                id=item.id,
                text=item.text,
                score=item.score,
                metadata=item.metadata,
            )
            for item in results
        ],
    )


def _diagram_to_response(node) -> RAGDiagramNodeResponse:
    return RAGDiagramNodeResponse(
        id=node.id,
        label=node.label,
        children=[_diagram_to_response(child) for child in node.children],
    )


@router.post(
    "/diagram",
    response_model=RAGDiagramResponse,
    summary="Diagrama jerárquico desde material indexado (PDF/texto)",
)
def build_material_diagram(
    payload: RAGDiagramRequest,
    service: RAGService = Depends(get_rag_service),
    student_id: int = Depends(get_current_student_id),
) -> RAGDiagramResponse:
    title, nodes, chunk_count = service.build_material_diagram(
        title=payload.title,
        query=payload.query,
        source=payload.source,
        subtopic_id=payload.subtopic_id,
        topic_id=payload.topic_id,
        area_id=payload.area_id,
        student_id=student_id,
        top_k=payload.top_k,
    )
    return RAGDiagramResponse(
        title=title,
        chunk_count=chunk_count,
        nodes=[_diagram_to_response(node) for node in nodes],
    )


@router.get(
    "/stats",
    response_model=RAGStatsResponse,
    summary="Estadísticas de la colección ChromaDB",
)
def rag_stats(
    service: RAGService = Depends(get_rag_service),
    _: AuthUser = Depends(get_current_user),
) -> RAGStatsResponse:
    data = service.stats()
    return RAGStatsResponse(**data)


@router.get(
    "/context",
    response_model=RAGContextResponse,
    summary="Subtema sugerido para indexar material según carrera",
)
def rag_context(
    career_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> RAGContextResponse:
    stmt_ap = (
        select(AdmissionProcess.id)
        .where(AdmissionProcess.career_id == career_id, AdmissionProcess.is_active.is_(True))
        .order_by(AdmissionProcess.year.desc())
        .limit(1)
    )
    admission_id = db.scalar(stmt_ap)
    if admission_id is None:
        return RAGContextResponse(career_id=career_id)

    stmt = (
        select(Subtopic, Topic, Area)
        .join(Topic, Subtopic.topic_id == Topic.id)
        .join(Component, Topic.component_id == Component.id)
        .join(Area, Component.area_id == Area.id)
        .where(Area.admission_process_id == admission_id, Subtopic.is_active.is_(True))
        .order_by(Subtopic.display_order)
        .limit(1)
    )
    row = db.execute(stmt).first()
    if row is None:
        return RAGContextResponse(career_id=career_id)

    subtopic, topic, area = row
    origins = CurriculumService(db).origin_labels_for_subtopics([subtopic.id]).get(
        subtopic.id, []
    )
    return RAGContextResponse(
        career_id=career_id,
        subtopic_id=subtopic.id,
        subtopic_name=subtopic.name,
        topic_name=topic.name,
        area_name=area.name,
        curriculum_origins=origins,
    )
