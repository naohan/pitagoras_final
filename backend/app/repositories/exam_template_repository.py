from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.exam import ExamTemplate, ExamTemplateQuestion
from app.models.question import Question
from app.repositories.base import BaseRepository


class ExamTemplateRepository(BaseRepository[ExamTemplate]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, ExamTemplate)

    def get_with_questions(self, template_id: int) -> ExamTemplate | None:
        stmt = (
            select(ExamTemplate)
            .where(ExamTemplate.id == template_id)
            .options(
                selectinload(ExamTemplate.template_questions)
                .selectinload(ExamTemplateQuestion.question)
                .selectinload(Question.options)
            )
        )
        return self._session.scalars(stmt).first()

    def list_by_admission_process_id(
        self,
        admission_process_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[ExamTemplate]:
        stmt = select(ExamTemplate).where(
            ExamTemplate.admission_process_id == admission_process_id
        )
        if active_only:
            stmt = stmt.where(ExamTemplate.is_active.is_(True))
        stmt = stmt.order_by(ExamTemplate.question_count.desc(), ExamTemplate.id.desc())
        stmt = stmt.offset(skip).limit(limit)
        return self._session.scalars(stmt).all()

    def list_by_career_id(
        self,
        career_id: int,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> Sequence[ExamTemplate]:
        from app.models.academic import AdmissionProcess

        stmt_ap = select(AdmissionProcess.id).where(
            AdmissionProcess.career_id == career_id
        )
        if active_only:
            stmt_ap = stmt_ap.where(AdmissionProcess.is_active.is_(True))
        stmt_ap = stmt_ap.order_by(AdmissionProcess.year.desc()).limit(1)
        admission_process_id = self._session.scalar(stmt_ap)
        if admission_process_id is None:
            return []
        return self.list_by_admission_process_id(
            admission_process_id,
            skip=skip,
            limit=limit,
            active_only=active_only,
        )
