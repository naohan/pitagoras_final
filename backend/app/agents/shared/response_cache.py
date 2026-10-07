"""Caché en memoria con TTL para respuestas de agentes (ahorra tokens repetidos)."""

from __future__ import annotations

import hashlib
import threading
import time
from dataclasses import dataclass
from typing import Any


@dataclass
class _CacheEntry:
    value: Any
    expires_at: float


class AgentResponseCache:
    """Caché thread-safe. Clave = agente + examen + mensaje opcional."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._store: dict[str, _CacheEntry] = {}

    def get(self, key: str) -> Any | None:
        with self._lock:
            entry = self._store.get(key)
            if entry is None:
                return None
            if entry.expires_at < time.monotonic():
                self._store.pop(key, None)
                return None
            return entry.value

    def set(self, key: str, value: Any, *, ttl_seconds: int) -> None:
        if ttl_seconds <= 0:
            return
        with self._lock:
            self._store[key] = _CacheEntry(
                value=value,
                expires_at=time.monotonic() + ttl_seconds,
            )
            if len(self._store) > 256:
                self._evict_expired_unlocked()

    def make_key(
        self,
        *,
        agent: str,
        student_exam_id: int,
        student_message: str | None = None,
        mode: str = "compact",
    ) -> str:
        msg = (student_message or "").strip().lower()
        digest = hashlib.sha1(msg.encode("utf-8")).hexdigest()[:12] if msg else "none"
        return f"{agent}:{student_exam_id}:{mode}:{digest}"

    def _evict_expired_unlocked(self) -> None:
        now = time.monotonic()
        expired = [key for key, entry in self._store.items() if entry.expires_at < now]
        for key in expired:
            self._store.pop(key, None)


agent_response_cache = AgentResponseCache()
