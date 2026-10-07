from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.academic import University
from app.repositories.base import BaseRepository


class UniversityRepository(BaseRepository[University]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, University)

    def get_by_code(self, code: str) -> University | None:
        stmt = select(University).where(University.code == code)
        return self._session.scalars(stmt).first()

    def list_by_country(
        self,
        country: str,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[University]:
        stmt = select(University).where(University.country == country)
        if active_only:
            stmt = stmt.where(University.is_active.is_(True))
        stmt = stmt.offset(skip).limit(limit)
        return self._session.scalars(stmt).all()
