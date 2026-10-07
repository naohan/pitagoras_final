from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.academic import Subtopic
from app.repositories.base import BaseRepository


class SubtopicRepository(BaseRepository[Subtopic]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, Subtopic)

    def get_by_topic_and_name(
        self,
        topic_id: int,
        name: str,
    ) -> Subtopic | None:
        stmt = select(Subtopic).where(
            Subtopic.topic_id == topic_id,
            Subtopic.name == name,
        )
        return self._session.scalars(stmt).first()

    def list_by_topic_id(
        self,
        topic_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Subtopic]:
        stmt = select(Subtopic).where(Subtopic.topic_id == topic_id)
        if active_only:
            stmt = stmt.where(Subtopic.is_active.is_(True))
        stmt = stmt.order_by(Subtopic.display_order, Subtopic.id).offset(skip).limit(limit)
        return self._session.scalars(stmt).all()
