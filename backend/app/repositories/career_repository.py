from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.academic import Career
from app.repositories.base import BaseRepository


class CareerRepository(BaseRepository[Career]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, Career)

    def get_by_university_and_code(
        self,
        university_id: int,
        code: str,
    ) -> Career | None:
        stmt = select(Career).where(
            Career.university_id == university_id,
            Career.code == code,
        )
        return self._session.scalars(stmt).first()

    def list_by_university_id(
        self,
        university_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Career]:
        stmt = select(Career).where(Career.university_id == university_id)
        if active_only:
            stmt = stmt.where(Career.is_active.is_(True))
        stmt = stmt.offset(skip).limit(limit)
        return self._session.scalars(stmt).all()
