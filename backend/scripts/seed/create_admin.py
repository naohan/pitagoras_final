"""Crea o actualiza un usuario ADMIN (sin perfil student).

Uso (desde backend/ con venv y migración 002 aplicada):

    set ADMIN_EMAIL=admin@example.com
    set ADMIN_PASSWORD=ChangeMeStrong!234
    python -m scripts.seed.create_admin

Variables de entorno obligatorias:
    ADMIN_EMAIL
    ADMIN_PASSWORD  (mínimo 8 caracteres)

Opcional:
    ADMIN_FORCE=1   actualiza password y role si el email ya existe
"""

from __future__ import annotations

import os
import sys

from app.auth.password import hash_password
from app.database.session import SessionLocal
from app.models.enums import UserRole
from app.models.user import User
from app.repositories.user_repository import UserRepository


def main() -> int:
    email = (os.environ.get("ADMIN_EMAIL") or "").strip().lower()
    password = os.environ.get("ADMIN_PASSWORD") or ""
    force = (os.environ.get("ADMIN_FORCE") or "").strip() in {"1", "true", "TRUE", "yes"}

    if not email or "@" not in email:
        print("ERROR: ADMIN_EMAIL es obligatorio y debe ser un email válido.", file=sys.stderr)
        return 1
    if len(password) < 8:
        print("ERROR: ADMIN_PASSWORD es obligatorio (mínimo 8 caracteres).", file=sys.stderr)
        return 1

    db = SessionLocal()
    try:
        users = UserRepository(db)
        existing = users.get_by_email(email)
        if existing is not None:
            if existing.role == UserRole.ADMIN and not force:
                print(f"OK: admin ya existe id={existing.id} email={existing.email}")
                return 0
            if not force:
                print(
                    f"ERROR: el email {email} ya existe con role={existing.role.value}. "
                    "Usa ADMIN_FORCE=1 para promover/actualizar.",
                    file=sys.stderr,
                )
                return 1
            existing.role = UserRole.ADMIN
            existing.password_hash = hash_password(password)
            existing.is_active = True
            db.commit()
            print(f"OK: admin actualizado id={existing.id} email={existing.email}")
            return 0

        user = User(
            email=email,
            password_hash=hash_password(password),
            role=UserRole.ADMIN,
            is_active=True,
        )
        users.create(user)
        db.commit()
        print(f"OK: admin creado id={user.id} email={user.email}")
        return 0
    except Exception as exc:  # noqa: BLE001 — CLI reporta y sale
        db.rollback()
        print(f"ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
