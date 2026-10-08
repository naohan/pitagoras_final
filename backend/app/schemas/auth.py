from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    full_name: str = Field(..., min_length=2, max_length=150)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=1, max_length=128)


class RefreshRequest(BaseModel):
    refresh_token: str = Field(..., min_length=20, max_length=512)


class LogoutRequest(BaseModel):
    refresh_token: str = Field(..., min_length=20, max_length=512)


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    role: str
    student_id: int | None = None
    full_name: str | None = None


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    expires_in: int
    refresh_token: str
    user: UserResponse
