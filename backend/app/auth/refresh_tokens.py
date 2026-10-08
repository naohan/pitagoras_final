"""Utilidades para refresh tokens opacos (hash SHA-256)."""

from __future__ import annotations

import hashlib
import secrets


def generate_refresh_token() -> str:
    return secrets.token_urlsafe(48)


def hash_refresh_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
