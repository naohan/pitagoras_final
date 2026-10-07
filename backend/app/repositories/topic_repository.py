from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.academic import Topic
from app.repositories.base import BaseRepository


class TopicRepository(BaseRepository[Topic]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, Topic)

    def get_by_component_and_name(
        self,
        component_id: int,
        name: str,
    ) -> Topic | None:
        stmt = select(Topic).where(
            Topic.component_id == component_id,
            Topic.name == name,
        )
        return self._session.scalars(stmt).first()

    def list_by_component_id(
        self,
        component_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Topic]:
        stmt = select(Topic).where(Topic.component_id == component_id)
        if active_only:
            stmt = stmt.where(Topic.is_active.is_(True))
        stmt = stmt.order_by(Topic.display_order, Topic.id).offset(skip).limit(limit)
        return self._session.scalars(stmt).all()
