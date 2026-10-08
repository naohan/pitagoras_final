"""Etapa 3: ADMIN real en MySQL — escritura de catálogo."""

from __future__ import annotations

import uuid

import pytest
from fastapi.testclient import TestClient

from app.auth.password import hash_password
from app.database.session import SessionLocal
from app.main import app
from app.models.enums import UserRole
from app.models.user import User
from app.repositories.user_repository import UserRepository

client = TestClient(app)


def _register_student() -> dict[str, str]:
    email = f"stage3_stu_{uuid.uuid4().hex[:10]}@example.com"
    r = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "Stage3Test!234",
            "full_name": "Stage3 Student",
        },
    )
    assert r.status_code in (200, 201), r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


def _ensure_admin() -> tuple[str, str]:
    """Crea admin en BD y hace login. Retorna (email, password)."""
    email = f"stage3_admin_{uuid.uuid4().hex[:10]}@example.com"
    password = "Stage3Admin!234"
    db = SessionLocal()
    try:
        users = UserRepository(db)
        user = User(
            email=email,
            password_hash=hash_password(password),
            role=UserRole.ADMIN,
            is_active=True,
        )
        users.create(user)
        db.commit()
    finally:
        db.close()
    return email, password


class TestAdminCatalogWrites:
    def test_admin_can_create_university_student_forbidden(self):
        # Student → 403
        student_headers = _register_student()
        code = f"S3{uuid.uuid4().hex[:6].upper()}"
        r = client.post(
            "/api/v1/universities",
            headers=student_headers,
            json={"code": code, "name": "Student Hack Uni", "country": "PE"},
        )
        assert r.status_code == 403, r.text
        assert r.json()["detail"]["code"] == "insufficient_role"

        # Admin → 201
        email, password = _ensure_admin()
        login = client.post(
            "/api/v1/auth/login",
            json={"email": email, "password": password},
        )
        assert login.status_code == 200, login.text
        data = login.json()
        assert data["user"]["role"] == "admin"
        assert data["user"]["student_id"] is None
        admin_headers = {"Authorization": f"Bearer {data['access_token']}"}

        admin_code = f"A3{uuid.uuid4().hex[:6].upper()}"
        r = client.post(
            "/api/v1/universities",
            headers=admin_headers,
            json={"code": admin_code, "name": "Stage3 Admin Uni", "country": "PE"},
        )
        assert r.status_code == 201, r.text
        body = r.json()
        assert body["code"] == admin_code
        assert body["name"] == "Stage3 Admin Uni"

        # Cleanup university created by admin (best-effort)
        uni_id = body["id"]
        client.delete(f"/api/v1/universities/{uni_id}", headers=admin_headers)

    def test_create_admin_script_env(self, monkeypatch: pytest.MonkeyPatch):
        """Smoke: el módulo create_admin exige env y crea admin."""
        from scripts.seed import create_admin

        email = f"stage3_seed_{uuid.uuid4().hex[:10]}@example.com"
        password = "Stage3Seed!234"
        monkeypatch.setenv("ADMIN_EMAIL", email)
        monkeypatch.setenv("ADMIN_PASSWORD", password)
        monkeypatch.delenv("ADMIN_FORCE", raising=False)

        rc = create_admin.main()
        assert rc == 0

        # Idempotente sin FORCE
        rc2 = create_admin.main()
        assert rc2 == 0

        login = client.post(
            "/api/v1/auth/login",
            json={"email": email, "password": password},
        )
        assert login.status_code == 200, login.text
        assert login.json()["user"]["role"] == "admin"
