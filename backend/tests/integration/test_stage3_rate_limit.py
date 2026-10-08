"""Etapa 3: rate limiting en login/register."""

from __future__ import annotations

import uuid

from fastapi.testclient import TestClient

from app.core.rate_limit import limiter
from app.main import app

client = TestClient(app)


class TestAuthRateLimit:
    def test_login_rate_limited_when_enabled(self):
        # Activar solo para este test; la suite global lo deja en false.
        was_enabled = limiter.enabled
        limiter.enabled = True
        try:
            email = f"stage3_rl_{uuid.uuid4().hex[:10]}@example.com"
            # Registrar una vez (también cuenta si el límite aplica a register;
            # usamos login fallido repetido para agotar el bucket de login).
            client.post(
                "/api/v1/auth/register",
                json={
                    "email": email,
                    "password": "Stage3Rl!23456",
                    "full_name": "Rate Limit",
                },
            )

            statuses = []
            for _ in range(15):
                r = client.post(
                    "/api/v1/auth/login",
                    json={"email": email, "password": "wrong-password-xx"},
                )
                statuses.append(r.status_code)

            assert 429 in statuses, f"expected 429 in {statuses}"
            assert any(s == 401 for s in statuses), f"expected some 401 in {statuses}"
        finally:
            limiter.enabled = was_enabled
            # Limpia contadores in-memory para no contaminar otros tests
            try:
                limiter.reset()
            except Exception:  # noqa: BLE001
                pass
