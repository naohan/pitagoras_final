from typing import Generic, Sequence, TypeVar

from sqlalchemy import func, select
from sqlalchemy.orm import Session

ModelT = TypeVar("ModelT")


class BaseRepository(Generic[ModelT]):
    """Operaciones CRUD genéricas sobre un modelo SQLAlchemy."""

    def __init__(self, session: Session, model: type[ModelT]) -> None:
        self._session = session
        self._model = model

    def get_by_id(self, entity_id: int) -> ModelT | None:
        return self._session.get(self._model, entity_id)

    def list_all(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[ModelT]:
        stmt = select(self._model)
        if active_only and hasattr(self._model, "is_active"):
            stmt = stmt.where(self._model.is_active.is_(True))
        stmt = stmt.offset(skip).limit(limit)
        return self._session.scalars(stmt).all()

    def create(self, entity: ModelT) -> ModelT:
        self._session.add(entity)
        self._session.flush()
        self._session.refresh(entity)
        return entity

    def update(self, entity: ModelT) -> ModelT:
        merged = self._session.merge(entity)
        self._session.flush()
        self._session.refresh(merged)
        return merged

    def delete(self, entity: ModelT) -> None:
        self._session.delete(entity)
        self._session.flush()

    def delete_by_id(self, entity_id: int) -> bool:
        entity = self.get_by_id(entity_id)
        if entity is None:
            return False
        self.delete(entity)
        return True

    def count(self, *, active_only: bool = False) -> int:
        stmt = select(func.count()).select_from(self._model)
        if active_only and hasattr(self._model, "is_active"):
            stmt = stmt.where(self._model.is_active.is_(True))
        return self._session.scalar(stmt) or 0
