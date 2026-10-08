"""Tests unitarios de dependencias de seguridad (Etapa 2)."""

from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from fastapi import HTTPException

from app.auth.auth_service import AuthUser
from app.core.dependencies import assert_student_exam_owner, require_roles
from app.models.enums import UserRole


def test_require_roles_allows_matching_role() -> None:
    dependency = require_roles(UserRole.ADMIN)
    user = AuthUser(id=1, email="a@b.c", role=UserRole.ADMIN, student_id=None)
    assert dependency(current_user=user) is user


def test_require_roles_rejects_student_for_admin() -> None:
    dependency = require_roles(UserRole.ADMIN)
    user = AuthUser(id=2, email="s@b.c", role=UserRole.STUDENT, student_id=10)
    with pytest.raises(HTTPException) as exc_info:
        dependency(current_user=user)
    assert exc_info.value.status_code == 403
    assert exc_info.value.detail["code"] == "insufficient_role"


def test_assert_student_exam_owner_not_found() -> None:
    db = MagicMock()
    db.get.return_value = None
    with pytest.raises(HTTPException) as exc_info:
        assert_student_exam_owner(db=db, student_exam_id=99, student_id=1)
    assert exc_info.value.status_code == 404
    assert exc_info.value.detail["code"] == "exam_not_found"


def test_assert_student_exam_owner_forbidden_for_other_student() -> None:
    db = MagicMock()
    db.get.return_value = SimpleNamespace(id=5, student_id=2)
    with pytest.raises(HTTPException) as exc_info:
        assert_student_exam_owner(db=db, student_exam_id=5, student_id=1)
    assert exc_info.value.status_code == 403
    assert exc_info.value.detail["code"] == "forbidden"


def test_assert_student_exam_owner_ok() -> None:
    exam = SimpleNamespace(id=5, student_id=1)
    db = MagicMock()
    db.get.return_value = exam
    result = assert_student_exam_owner(db=db, student_exam_id=5, student_id=1)
    assert result is exam
