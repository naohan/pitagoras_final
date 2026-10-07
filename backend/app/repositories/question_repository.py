from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.academic import AdmissionProcess, Area, Career, Component, Subtopic, Topic
from app.models.question import Question
from app.repositories.base import BaseRepository


class QuestionRepository(BaseRepository[Question]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, Question)

    def get_by_id_with_options(self, question_id: int) -> Question | None:
        stmt = (
            select(Question)
            .where(Question.id == question_id)
            .options(selectinload(Question.options))
        )
        return self._session.scalars(stmt).first()

    def get_with_academic_context(self, question_id: int) -> Question | None:
        stmt = (
            select(Question)
            .where(Question.id == question_id)
            .options(
                selectinload(Question.options),
                selectinload(Question.subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area)
                .selectinload(Area.admission_process)
                .selectinload(AdmissionProcess.career)
                .selectinload(Career.university),
            )
        )
        return self._session.scalars(stmt).first()

    def list_by_subtopic_id(
        self,
        subtopic_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Question]:
        stmt = select(Question).where(Question.subtopic_id == subtopic_id)
        if active_only:
            stmt = stmt.where(Question.is_active.is_(True))
        stmt = stmt.order_by(Question.id).offset(skip).limit(limit)
        return self._session.scalars(stmt).all()

    def list_by_subtopic_id_with_options(
        self,
        subtopic_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Question]:
        stmt = (
            select(Question)
            .where(Question.subtopic_id == subtopic_id)
            .options(selectinload(Question.options))
        )
        if active_only:
            stmt = stmt.where(Question.is_active.is_(True))
        stmt = stmt.order_by(Question.id).offset(skip).limit(limit)
        return self._session.scalars(stmt).all()

    def list_by_difficulty(
        self,
        difficulty: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[Question]:
        stmt = select(Question).where(Question.difficulty == difficulty)
        if active_only:
            stmt = stmt.where(Question.is_active.is_(True))
        stmt = stmt.order_by(Question.id).offset(skip).limit(limit)
        return self._session.scalars(stmt).all()
