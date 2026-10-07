from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.helpers import apply_update, not_found
from app.core.dependencies import get_db
from app.models.academic import Topic
from app.repositories.topic_repository import TopicRepository
from app.schemas.topic import TopicCreate, TopicResponse, TopicUpdate

router = APIRouter(prefix="/topics", tags=["Topics"])


@router.get("", response_model=list[TopicResponse])
def list_topics(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    component_id: int | None = None,
    db: Session = Depends(get_db),
) -> list[Topic]:
    repo = TopicRepository(db)
    if component_id is not None:
        return list(
            repo.list_by_component_id(
                component_id,
                skip=skip,
                limit=limit,
                active_only=active_only,
            )
        )
    return list(repo.list_all(skip=skip, limit=limit, active_only=active_only))


@router.get("/{topic_id}", response_model=TopicResponse)
def get_topic(
    topic_id: int,
    db: Session = Depends(get_db),
) -> Topic:
    entity = TopicRepository(db).get_by_id(topic_id)
    if entity is None:
        raise not_found("Topic", topic_id)
    return entity


@router.post("", response_model=TopicResponse, status_code=status.HTTP_201_CREATED)
def create_topic(
    payload: TopicCreate,
    db: Session = Depends(get_db),
) -> Topic:
    repo = TopicRepository(db)
    entity = Topic(**payload.model_dump())
    repo.create(entity)
    db.commit()
    db.refresh(entity)
    return entity


@router.put("/{topic_id}", response_model=TopicResponse)
def update_topic(
    topic_id: int,
    payload: TopicUpdate,
    db: Session = Depends(get_db),
) -> Topic:
    repo = TopicRepository(db)
    entity = repo.get_by_id(topic_id)
    if entity is None:
        raise not_found("Topic", topic_id)
    apply_update(entity, payload.model_dump(exclude_unset=True))
    db.commit()
    db.refresh(entity)
    return entity


@router.delete("/{topic_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_topic(
    topic_id: int,
    db: Session = Depends(get_db),
) -> Response:
    repo = TopicRepository(db)
    if not repo.delete_by_id(topic_id):
        raise not_found("Topic", topic_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
