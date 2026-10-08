"""Configuración global de tests — desactiva rate limit salvo tests dedicados."""

from __future__ import annotations

import os

# Forzar desactivado: evita 429 en la suite al registrar/login muchos usuarios.
os.environ["AUTH_RATE_LIMIT_ENABLED"] = "false"
