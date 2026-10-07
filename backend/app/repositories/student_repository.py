from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.student import Student
from app.repositories.base import BaseRepository


class StudentRepository(BaseRepository[Student]):
    def __init__(self, session: Session) -> None:
        super().__init__(session, Student)

    def get_by_email(self, email: str) -> Student | None:
        stmt = select(Student).where(Student.email == email)
        return self._session.scalars(stmt).first()

    def get_by_user_id(self, user_id: int) -> Student | None:
        stmt = select(Student).where(Student.user_id == user_id)
        return self._session.scalars(stmt).first()
