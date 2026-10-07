from sqlalchemy.orm import Session

from app.models.result import (
    ExamResult,
    ExamResultArea,
    ExamResultComponent,
    ExamResultSubtopic,
    ExamResultTopic,
)
from app.repositories.base import BaseRepository


class ExamResultRepository(BaseRepository[ExamResult]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, ExamResult)

    def save_breakdown(
        self,
        result: ExamResult,
        areas: list[ExamResultArea],
        components: list[ExamResultComponent],
        topics: list[ExamResultTopic],
        subtopics: list[ExamResultSubtopic],
    ) -> ExamResult:
        self._session.add(result)
        self._session.flush()
        for row in areas + components + topics + subtopics:
            self._session.add(row)
        self._session.flush()
        self._session.refresh(result)
        return result
