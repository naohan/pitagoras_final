"""Excepciones de autenticación."""


class AuthError(Exception):
    def __init__(self, message: str, code: str = "auth_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class EmailAlreadyRegisteredError(AuthError):
    def __init__(self, email: str) -> None:
        super().__init__(f"Email {email} is already registered", "email_already_registered")


class InvalidCredentialsError(AuthError):
    def __init__(self) -> None:
        super().__init__("Invalid email or password", "invalid_credentials")


class InactiveUserError(AuthError):
    def __init__(self) -> None:
        super().__init__("User account is inactive", "inactive_user")


class UserNotFoundError(AuthError):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"User {user_id} not found", "user_not_found")


class InvalidRefreshTokenError(AuthError):
    def __init__(self) -> None:
        super().__init__("Invalid or expired refresh token", "invalid_refresh_token")
