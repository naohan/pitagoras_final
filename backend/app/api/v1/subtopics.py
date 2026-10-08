from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.helpers import apply_update, not_found
from app.auth.auth_service import AuthUser
from app.core.dependencies import get_current_user, get_db, require_roles
from app.models.academic import Subtopic
from app.models.enums import UserRole
from app.repositories.subtopic_repository import SubtopicRepository
from app.schemas.subtopic import SubtopicCreate, SubtopicResponse, SubtopicUpdate

router = APIRouter(prefix="/subtopics", tags=["Subtopics"])


@router.get("", response_model=list[SubtopicResponse])
def list_subtopics(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    topic_id: int | None = None,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> list[Subtopic]:
    repo = SubtopicRepository(db)
    if topic_id is not None:
        return list(
            repo.list_by_topic_id(
                topic_id,
                skip=skip,
                limit=limit,
                active_only=active_only,
            )
        )
    return list(repo.list_all(skip=skip, limit=limit, active_only=active_only))


@router.get("/{subtopic_id}", response_model=SubtopicResponse)
def get_subtopic(
    subtopic_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> Subtopic:
    entity = SubtopicRepository(db).get_by_id(subtopic_id)
    if entity is None:
        raise not_found("Subtopic", subtopic_id)
    return entity


@router.post("", response_model=SubtopicResponse, status_code=status.HTTP_201_CREATED)
def create_subtopic(
    payload: SubtopicCreate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Subtopic:
    repo = SubtopicRepository(db)
    entity = Subtopic(**payload.model_dump())
    repo.create(entity)
    db.commit()
    db.refresh(entity)
    return entity


@router.put("/{subtopic_id}", response_model=SubtopicResponse)
def update_subtopic(
    subtopic_id: int,
    payload: SubtopicUpdate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Subtopic:
    repo = SubtopicRepository(db)
    entity = repo.get_by_id(subtopic_id)
    if entity is None:
        raise not_found("Subtopic", subtopic_id)
    apply_update(entity, payload.model_dump(exclude_unset=True))
    db.commit()
    db.refresh(entity)
    return entity


@router.delete("/{subtopic_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_subtopic(
    subtopic_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Response:
    repo = SubtopicRepository(db)
    if not repo.delete_by_id(subtopic_id):
        raise not_found("Subtopic", subtopic_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
