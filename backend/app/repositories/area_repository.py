from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.academic import Area
from app.repositories.base import BaseRepository


class AreaRepository(BaseRepository[Area]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, Area)

    def get_by_admission_process_and_name(
        self,
        admission_process_id: int,
        name: str,
    ) -> Area | None:
        stmt = select(Area).where(
            Area.admission_process_id == admission_process_id,
            Area.name == name,
        )
        return self._session.scalars(stmt).first()

    def list_by_admission_process_id(
        self,
        admission_process_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Area]:
        stmt = select(Area).where(Area.admission_process_id == admission_process_id)
        if active_only:
            stmt = stmt.where(Area.is_active.is_(True))
        stmt = stmt.order_by(Area.display_order, Area.id).offset(skip).limit(limit)
        return self._session.scalars(stmt).all()
