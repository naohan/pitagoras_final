from typing import Sequence

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.academic import Area, Component, Subtopic, Topic
from app.models.question import Question


class QuestionSelectionRepository:
    """Consultas de selección de preguntas para plantillas de examen."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def list_active_by_area_id(
        self,
        area_id: int,
        *,
        limit: int,
        exclude_ids: set[int] | None = None,
    ) -> Sequence[Question]:
        stmt = (
            select(Question)
            .join(Subtopic, Question.subtopic_id == Subtopic.id)
            .join(Topic, Subtopic.topic_id == Topic.id)
            .join(Component, Topic.component_id == Component.id)
            .where(
                Component.area_id == area_id,
                Question.is_active.is_(True),
            )
        )
        if exclude_ids:
            stmt = stmt.where(Question.id.not_in(exclude_ids))
        stmt = stmt.order_by(func.rand()).limit(limit)
        return self._session.scalars(stmt).all()

    def list_active_by_admission_process(
        self,
        admission_process_id: int,
        *,
        limit: int,
        exclude_ids: set[int] | None = None,
    ) -> Sequence[Question]:
        stmt = (
            select(Question)
            .join(Subtopic, Question.subtopic_id == Subtopic.id)
            .join(Topic, Subtopic.topic_id == Topic.id)
            .join(Component, Topic.component_id == Component.id)
            .join(Area, Component.area_id == Area.id)
            .where(
                Area.admission_process_id == admission_process_id,
                Question.is_active.is_(True),
            )
        )
        if exclude_ids:
            stmt = stmt.where(Question.id.not_in(exclude_ids))
        stmt = stmt.order_by(func.rand()).limit(limit)
        return self._session.scalars(stmt).all()

    def list_active_by_subtopic_id(
        self,
        subtopic_id: int,
        *,
        limit: int,
        exclude_ids: set[int] | None = None,
    ) -> Sequence[Question]:
        stmt = select(Question).where(
            Question.subtopic_id == subtopic_id,
            Question.is_active.is_(True),
        )
        if exclude_ids:
            stmt = stmt.where(Question.id.not_in(exclude_ids))
        stmt = stmt.order_by(func.rand()).limit(limit)
        return self._session.scalars(stmt).all()
