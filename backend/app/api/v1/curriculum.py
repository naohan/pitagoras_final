from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.helpers import not_found
from app.core.dependencies import get_db
from app.curriculum.service import FRAMEWORK_UI_LABELS, CurriculumService
from app.models.academic import Subtopic
from app.models.enums import CurriculumFramework
from app.repositories.subtopic_repository import SubtopicRepository
from app.schemas.curriculum import (
    CurriculumAreaResponse,
    CurriculumCatalogResponse,
    CurriculumCourseResponse,
    CurriculumMappingResponse,
    LearnableTopicResponse,
    SubtopicCurriculumResponse,
)

router = APIRouter(prefix="/curriculum", tags=["Currículo CNEB / temario"])


def _origin_label(framework: CurriculumFramework | str) -> str:
    if isinstance(framework, str):
        framework = CurriculumFramework(framework)
    return FRAMEWORK_UI_LABELS[framework]


def _to_learnable(item) -> LearnableTopicResponse:
    return LearnableTopicResponse(
        subtopic_id=item.subtopic_id,
        subtopic_name=item.subtopic_name,
        topic_name=item.topic_name,
        course_name=item.course_name,
        area_name=item.area_name,
        theory_text=item.theory_text,
        framework=item.framework,
        external_code=item.external_code,
        external_label=item.external_label,
        origin_label=item.origin_label,
    )


@router.get(
    "/catalog",
    response_model=CurriculumCatalogResponse,
    summary="Áreas CNEB con sus cursos internos y temas",
)
def get_curriculum_catalog(
    framework: CurriculumFramework = Query(
        default=CurriculumFramework.CNEB_SECUNDARIA,
    ),
    db: Session = Depends(get_db),
) -> CurriculumCatalogResponse:
    areas = CurriculumService(db).list_catalog(framework=framework)
    return CurriculumCatalogResponse(
        areas=[
            CurriculumAreaResponse(
                area_name=area.area_name,
                courses=[
                    CurriculumCourseResponse(
                        course_id=course.course_id,
                        course_name=course.course_name,
                        topics=[_to_learnable(topic) for topic in course.topics],
                    )
                    for course in area.courses
                ],
            )
            for area in areas
        ]
    )


@router.get(
    "/learnable-topics",
    response_model=list[LearnableTopicResponse],
    summary="Temas para aprender (base escolar CNEB u otro framework)",
)
def list_learnable_topics(
    framework: CurriculumFramework = Query(
        default=CurriculumFramework.CNEB_SECUNDARIA,
    ),
    limit: int = Query(default=300, ge=1, le=500),
    db: Session = Depends(get_db),
) -> list[LearnableTopicResponse]:
    items = CurriculumService(db).list_learnable_topics(framework=framework, limit=limit)
    return [_to_learnable(item) for item in items]


@router.get(
    "/learnable-topics/{subtopic_id}",
    response_model=LearnableTopicResponse,
    summary="Un tema con teoría detallada (para relectura)",
)
def get_learnable_topic(
    subtopic_id: int,
    framework: CurriculumFramework = Query(
        default=CurriculumFramework.CNEB_SECUNDARIA,
    ),
    db: Session = Depends(get_db),
) -> LearnableTopicResponse:
    item = CurriculumService(db).get_learnable_topic(
        subtopic_id, framework=framework
    )
    if item is None:
        raise not_found("Subtopic", subtopic_id)
    return _to_learnable(item)


@router.get(
    "/subtopics/{subtopic_id}",
    response_model=SubtopicCurriculumResponse,
    summary="Orígenes curriculares y teoría de un subtema",
)
def get_subtopic_curriculum(
    subtopic_id: int,
    db: Session = Depends(get_db),
) -> SubtopicCurriculumResponse:
    entity: Subtopic | None = SubtopicRepository(db).get_by_id(subtopic_id)
    if entity is None:
        raise not_found("Subtopic", subtopic_id)

    service = CurriculumService(db)
    learnable = service.get_learnable_topic(subtopic_id)
    mappings = service.list_for_subtopic(subtopic_id)
    responses = [
        CurriculumMappingResponse(
            id=m.id,
            subtopic_id=m.subtopic_id,
            framework=m.framework,
            external_code=m.external_code,
            external_label=m.external_label,
            origin_label=_origin_label(m.framework),
        )
        for m in mappings
    ]
    origins: list[str] = []
    seen: set[str] = set()
    for item in responses:
        if item.origin_label not in seen:
            seen.add(item.origin_label)
            origins.append(item.origin_label)

    return SubtopicCurriculumResponse(
        subtopic_id=subtopic_id,
        subtopic_name=(learnable.subtopic_name if learnable else entity.name),
        topic_name=learnable.topic_name if learnable else "",
        course_name=learnable.course_name if learnable else "",
        area_name=learnable.area_name if learnable else "",
        theory_text=(
            learnable.theory_text
            if learnable
            else (entity.theory_text or "")
        ),
        origins=origins,
        mappings=responses,
    )
