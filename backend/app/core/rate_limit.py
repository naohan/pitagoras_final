"""Rate limiting para endpoints de autenticación (slowapi)."""

from __future__ import annotations

from slowapi import Limiter
from slowapi.util import get_remote_address

from app.core.config import settings

limiter = Limiter(
    key_func=get_remote_address,
    enabled=settings.auth_rate_limit_enabled,
    default_limits=[],
)


def limit_auth(func):  # noqa: ANN001 — decorador genérico
    """Aplica el límite configurado en AUTH_RATE_LIMIT a login/register."""
    return limiter.limit(settings.auth_rate_limit)(func)
