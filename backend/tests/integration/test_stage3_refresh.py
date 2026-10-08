"""Etapa 3: refresh tokens — renovación, rotación y rechazo."""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi.testclient import TestClient
from sqlalchemy import select

from app.auth.refresh_tokens import hash_refresh_token
from app.database.session import SessionLocal
from app.main import app
from app.models.refresh_token import RefreshToken

client = TestClient(app)


def _register() -> dict:
    email = f"stage3_ref_{uuid.uuid4().hex[:10]}@example.com"
    r = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "Stage3Ref!234",
            "full_name": "Stage3 Refresh",
        },
    )
    assert r.status_code == 201, r.text
    return r.json()


class TestRefreshTokens:
    def test_refresh_rotates_and_invalidates_old(self):
        data = _register()
        old_access = data["access_token"]
        old_refresh = data["refresh_token"]
        assert old_refresh
        assert data["expires_in"] > 0

        r = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": old_refresh},
        )
        assert r.status_code == 200, r.text
        new_data = r.json()
        assert new_data["access_token"]
        assert new_data["refresh_token"]
        assert new_data["refresh_token"] != old_refresh
        assert new_data["user"]["email"] == data["user"]["email"]

        # Access anterior puede seguir válido hasta exp (stateless JWT);
        # el refresh viejo no.
        r2 = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": old_refresh},
        )
        assert r2.status_code == 401, r2.text
        assert r2.json()["detail"]["code"] == "invalid_refresh_token"

        # Nuevo refresh funciona
        r3 = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": new_data["refresh_token"]},
        )
        assert r3.status_code == 200, r3.text

        # Access nuevo autentica /me
        me = client.get(
            "/api/v1/auth/me",
            headers={"Authorization": f"Bearer {new_data['access_token']}"},
        )
        assert me.status_code == 200, me.text
        assert old_access  # emitido en login; no se invalida server-side

    def test_invalid_refresh_rejected(self):
        r = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": "totally-invalid-refresh-token-value"},
        )
        assert r.status_code == 401, r.text

    def test_expired_refresh_rejected(self):
        data = _register()
        raw = data["refresh_token"]
        token_hash = hash_refresh_token(raw)

        db = SessionLocal()
        try:
            stored = db.scalars(
                select(RefreshToken).where(RefreshToken.token_hash == token_hash)
            ).first()
            assert stored is not None
            stored.expires_at = datetime.now(timezone.utc).replace(tzinfo=None) - timedelta(seconds=1)
            db.commit()
        finally:
            db.close()

        r = client.post("/api/v1/auth/refresh", json={"refresh_token": raw})
        assert r.status_code == 401, r.text

    def test_logout_revokes_refresh(self):
        data = _register()
        raw = data["refresh_token"]
        r = client.post("/api/v1/auth/logout", json={"refresh_token": raw})
        assert r.status_code == 204, r.text

        r2 = client.post("/api/v1/auth/refresh", json={"refresh_token": raw})
        assert r2.status_code == 401, r2.text
