from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.auth.exceptions import (
    EmailAlreadyRegisteredError,
    InactiveUserError,
    InvalidCredentialsError,
    InvalidRefreshTokenError,
    UserNotFoundError,
)
from app.auth.jwt_tokens import create_access_token
from app.auth.password import hash_password, verify_password
from app.auth.refresh_tokens import generate_refresh_token, hash_refresh_token
from app.core.config import settings
from app.models.enums import UserRole
from app.models.refresh_token import RefreshToken
from app.models.student import Student
from app.models.user import User
from app.repositories.student_repository import StudentRepository
from app.repositories.user_repository import UserRepository


@dataclass
class AuthUser:
    id: int
    email: str
    role: UserRole
    student_id: int | None = None
    full_name: str | None = None


@dataclass
class AuthToken:
    access_token: str
    token_type: str
    expires_in: int
    refresh_token: str
    user: AuthUser


class AuthService:
    def __init__(self, session: Session) -> None:
        self._session = session
        self._users = UserRepository(session)
        self._students = StudentRepository(session)

    def register_student(self, *, email: str, password: str, full_name: str) -> AuthToken:
        normalized_email = email.strip().lower()
        if self._users.get_by_email(normalized_email) is not None:
            raise EmailAlreadyRegisteredError(normalized_email)

        user = User(
            email=normalized_email,
            password_hash=hash_password(password),
            role=UserRole.STUDENT,
            is_active=True,
        )
        self._users.create(user)

        student = Student(
            user_id=user.id,
            email=normalized_email,
            full_name=full_name.strip(),
            is_active=True,
        )
        self._students.create(student)
        self._session.commit()

        return self._issue_tokens(user, student)

    def login(self, *, email: str, password: str) -> AuthToken:
        normalized_email = email.strip().lower()
        user = self._users.get_by_email(normalized_email)
        if user is None or not verify_password(password, user.password_hash):
            raise InvalidCredentialsError()
        if not user.is_active:
            raise InactiveUserError()

        student = self._students.get_by_user_id(user.id) if user.role == UserRole.STUDENT else None
        return self._issue_tokens(user, student)

    def refresh(self, *, raw_refresh_token: str) -> AuthToken:
        token_hash = hash_refresh_token(raw_refresh_token)
        stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        stored = self._session.scalars(stmt).first()
        if stored is None or stored.revoked_at is not None:
            raise InvalidRefreshTokenError()

        now = datetime.now(timezone.utc).replace(tzinfo=None)
        if stored.expires_at < now:
            stored.revoked_at = now
            self._session.commit()
            raise InvalidRefreshTokenError()

        user = self._users.get_by_id(stored.user_id)
        if user is None or not user.is_active:
            stored.revoked_at = now
            self._session.commit()
            raise InvalidRefreshTokenError()

        # Rotación: revoca el refresh usado
        stored.revoked_at = now
        self._session.flush()

        student = self._students.get_by_user_id(user.id) if user.role == UserRole.STUDENT else None
        return self._issue_tokens(user, student)

    def revoke_refresh_token(self, *, raw_refresh_token: str) -> None:
        token_hash = hash_refresh_token(raw_refresh_token)
        stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        stored = self._session.scalars(stmt).first()
        if stored is None:
            return
        if stored.revoked_at is None:
            stored.revoked_at = datetime.now(timezone.utc).replace(tzinfo=None)
            self._session.commit()

    def get_user_by_id(self, user_id: int) -> AuthUser:
        user = self._users.get_by_id(user_id)
        if user is None:
            raise UserNotFoundError(user_id)
        if not user.is_active:
            raise InactiveUserError()

        student = self._students.get_by_user_id(user.id) if user.role == UserRole.STUDENT else None
        return self._to_auth_user(user, student)

    def _issue_tokens(self, user: User, student: Student | None) -> AuthToken:
        claims: dict[str, str | int] = {"role": user.role.value}
        if student is not None:
            claims["student_id"] = student.id

        access = create_access_token(subject=str(user.id), claims=claims)
        raw_refresh = generate_refresh_token()
        expires_at = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(
            days=settings.jwt_refresh_expire_days
        )
        self._session.add(
            RefreshToken(
                user_id=user.id,
                token_hash=hash_refresh_token(raw_refresh),
                expires_at=expires_at,
            )
        )
        self._session.commit()

        return AuthToken(
            access_token=access,
            token_type="bearer",
            expires_in=settings.jwt_expire_minutes * 60,
            refresh_token=raw_refresh,
            user=self._to_auth_user(user, student),
        )

    @staticmethod
    def _to_auth_user(user: User, student: Student | None) -> AuthUser:
        return AuthUser(
            id=user.id,
            email=user.email,
            role=user.role,
            student_id=student.id if student else None,
            full_name=student.full_name if student else None,
        )
