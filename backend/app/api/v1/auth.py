from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth.auth_service import AuthService, AuthUser
from app.auth.exceptions import AuthError
from app.core.dependencies import get_current_user, get_db
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["Auth"])


def get_auth_service(db: Session = Depends(get_db)) -> AuthService:
    return AuthService(db)


def _handle_auth_error(exc: AuthError) -> HTTPException:
    status_code = status.HTTP_400_BAD_REQUEST
    if exc.code == "email_already_registered":
        status_code = status.HTTP_409_CONFLICT
    elif exc.code == "invalid_credentials":
        status_code = status.HTTP_401_UNAUTHORIZED
    elif exc.code == "inactive_user":
        status_code = status.HTTP_403_FORBIDDEN
    elif exc.code == "user_not_found":
        status_code = status.HTTP_404_NOT_FOUND
    return HTTPException(status_code=status_code, detail={"code": exc.code, "message": exc.message})


def _to_user_response(user: AuthUser) -> UserResponse:
    return UserResponse(
        id=user.id,
        email=user.email,
        role=user.role.value,
        student_id=user.student_id,
        full_name=user.full_name,
    )


def _to_token_response(result) -> TokenResponse:
    return TokenResponse(
        access_token=result.access_token,
        token_type=result.token_type,
        expires_in=result.expires_in,
        user=_to_user_response(result.user),
    )


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar estudiante",
)
def register(
    payload: RegisterRequest,
    service: AuthService = Depends(get_auth_service),
) -> TokenResponse:
    try:
        result = service.register_student(
            email=str(payload.email),
            password=payload.password,
            full_name=payload.full_name,
        )
        return _to_token_response(result)
    except AuthError as exc:
        raise _handle_auth_error(exc) from exc


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Iniciar sesión",
)
def login(
    payload: LoginRequest,
    service: AuthService = Depends(get_auth_service),
) -> TokenResponse:
    try:
        result = service.login(email=str(payload.email), password=payload.password)
        return _to_token_response(result)
    except AuthError as exc:
        raise _handle_auth_error(exc) from exc


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Perfil del usuario autenticado",
)
def me(current_user: AuthUser = Depends(get_current_user)) -> UserResponse:
    return _to_user_response(current_user)
