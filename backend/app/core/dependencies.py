from collections.abc import Callable, Generator

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.auth.auth_service import AuthService, AuthUser
from app.auth.exceptions import AuthError, InactiveUserError, UserNotFoundError
from app.auth.jwt_tokens import decode_access_token, is_token_error
from app.database.session import SessionLocal
from app.models.enums import UserRole
from app.models.exam import StudentExam

_bearer_scheme = HTTPBearer(auto_error=False)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
    db: Session = Depends(get_db),
) -> AuthUser:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "not_authenticated", "message": "Authentication required."},
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(credentials.credentials)
        user_id = int(payload["sub"])
    except (KeyError, ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "invalid_token", "message": "Invalid access token."},
            headers={"WWW-Authenticate": "Bearer"},
        ) from None
    except Exception as exc:
        if is_token_error(exc):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={"code": "invalid_token", "message": "Invalid or expired access token."},
                headers={"WWW-Authenticate": "Bearer"},
            ) from exc
        raise

    try:
        return AuthService(db).get_user_by_id(user_id)
    except (UserNotFoundError, InactiveUserError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": exc.code, "message": exc.message},
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
    except AuthError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": exc.code, "message": exc.message},
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


def get_optional_student_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
    db: Session = Depends(get_db),
) -> int | None:
    """Devuelve student_id si hay JWT válido; None si no hay sesión."""
    if credentials is None or credentials.scheme.lower() != "bearer":
        return None
    try:
        payload = decode_access_token(credentials.credentials)
        user_id = int(payload["sub"])
        user = AuthService(db).get_user_by_id(user_id)
        return user.student_id
    except Exception:
        return None


def get_current_student_id(current_user: AuthUser = Depends(get_current_user)) -> int:
    if current_user.student_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "student_profile_required", "message": "Student profile required."},
        )
    return current_user.student_id


def require_roles(*roles: UserRole) -> Callable[..., AuthUser]:
    """Dependencia: el usuario autenticado debe tener uno de los roles indicados."""

    allowed = tuple(roles)

    def _require(current_user: AuthUser = Depends(get_current_user)) -> AuthUser:
        if current_user.role not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "code": "insufficient_role",
                    "message": "You do not have permission to perform this action.",
                },
            )
        return current_user

    return _require


def get_owned_student_exam(
    student_exam_id: int,
    student_id: int = Depends(get_current_student_id),
    db: Session = Depends(get_db),
) -> StudentExam:
    """Carga un StudentExam y garantiza que pertenece al estudiante del JWT.

    - Inexistente → 404
    - Existe pero es de otro estudiante → 403
    """
    exam = db.get(StudentExam, student_exam_id)
    if exam is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "exam_not_found", "message": "Student exam not found"},
        )
    if exam.student_id != student_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "code": "forbidden",
                "message": "You do not have access to this student exam.",
            },
        )
    return exam


def assert_student_exam_owner(
    *,
    db: Session,
    student_exam_id: int,
    student_id: int,
) -> StudentExam:
    """Ownership check usable fuera de Depends (p. ej. body con student_exam_id)."""
    exam = db.get(StudentExam, student_exam_id)
    if exam is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "exam_not_found", "message": "Student exam not found"},
        )
    if exam.student_id != student_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "code": "forbidden",
                "message": "You do not have access to this student exam.",
            },
        )
    return exam
