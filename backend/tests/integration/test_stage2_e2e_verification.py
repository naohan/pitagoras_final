"""Verificación E2E de Etapa 2 (auth + ownership). Usa la BD real vía TestClient."""

from __future__ import annotations

import time
import uuid

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text

from app.database.session import SessionLocal
from app.main import app

client = TestClient(app)


def _register(suffix: str) -> tuple[str, int, dict[str, str]]:
    email = f"stage2_{suffix}_{uuid.uuid4().hex[:10]}@example.com"
    password = "Stage2Test!234"
    r = client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": password, "full_name": f"Stage2 {suffix}"},
    )
    assert r.status_code in (200, 201), r.text
    data = r.json()
    token = data["access_token"]
    student_id = data["user"]["student_id"]
    assert student_id is not None
    headers = {"Authorization": f"Bearer {token}"}
    return token, int(student_id), headers


@pytest.fixture(scope="module")
def students():
    a = _register("A")
    b = _register("B")
    return {"A": a, "B": b}


class TestCatalogAuth:
    def test_catalog_get_without_jwt_is_401(self):
        paths = [
            "/api/v1/universities",
            "/api/v1/careers",
            "/api/v1/areas",
            "/api/v1/topics",
            "/api/v1/subtopics",
            "/api/v1/questions",
            "/api/v1/questions/1",
            "/api/v1/exam-templates?career_id=1",
            "/api/v1/exam-templates/1",
        ]
        for path in paths:
            r = client.get(path)
            assert r.status_code == 401, f"{path} -> {r.status_code} {r.text}"

    def test_catalog_get_with_student_jwt_allowed(self, students):
        _, _, headers = students["A"]
        r = client.get("/api/v1/universities?active_only=true", headers=headers)
        assert r.status_code == 200, r.text
        unis = r.json()
        assert isinstance(unis, list) and len(unis) >= 1
        uni_id = unis[0]["id"]

        r = client.get(
            f"/api/v1/careers?university_id={uni_id}&active_only=true",
            headers=headers,
        )
        assert r.status_code == 200, r.text
        careers = r.json()
        assert len(careers) >= 1
        career_id = careers[0]["id"]

        r = client.get("/api/v1/areas?active_only=true", headers=headers)
        assert r.status_code == 200, r.text
        r = client.get("/api/v1/topics?active_only=true", headers=headers)
        assert r.status_code == 200, r.text
        r = client.get("/api/v1/subtopics?active_only=true", headers=headers)
        assert r.status_code == 200, r.text
        r = client.get("/api/v1/questions?limit=1", headers=headers)
        assert r.status_code == 200, r.text
        questions = r.json()
        if questions:
            r = client.get(f"/api/v1/questions/{questions[0]['id']}", headers=headers)
            assert r.status_code == 200, r.text

        r = client.get(
            f"/api/v1/exam-templates?career_id={career_id}&active_only=true",
            headers=headers,
        )
        assert r.status_code == 200, r.text
        templates = r.json()
        assert len(templates) >= 1
        r = client.get(f"/api/v1/exam-templates/{templates[0]['id']}", headers=headers)
        assert r.status_code == 200, r.text

    def test_catalog_writes_forbidden_for_student(self, students):
        _, _, headers = students["A"]
        cases = [
            ("post", "/api/v1/universities", {"code": "X", "name": "Hack Uni"}),
            ("post", "/api/v1/careers", {"university_id": 1, "code": "X", "name": "Hack"}),
            ("post", "/api/v1/areas", {"admission_process_id": 1, "name": "Hack", "code": "H"}),
            ("post", "/api/v1/topics", {"component_id": 1, "name": "Hack"}),
            ("post", "/api/v1/subtopics", {"topic_id": 1, "name": "Hack"}),
            (
                "post",
                "/api/v1/questions",
                {
                    "subtopic_id": 1,
                    "stem": "hack?",
                    "difficulty": 1,
                    "options": [
                        {"label": "A", "text": "1", "is_correct": True, "display_order": 1}
                    ],
                },
            ),
            (
                "post",
                "/api/v1/exam-templates",
                {
                    "admission_process_id": 1,
                    "name": "Hack Template",
                    "duration_minutes": 10,
                    "question_count": 1,
                    "auto_select_questions": True,
                },
            ),
        ]
        for method, path, body in cases:
            r = getattr(client, method)(path, headers=headers, json=body)
            assert r.status_code == 403, f"{method.upper()} {path} -> {r.status_code} {r.text}"
            assert r.json()["detail"]["code"] == "insufficient_role"

        # PUT/DELETE sample on universities
        r = client.put("/api/v1/universities/1", headers=headers, json={"name": "Nope"})
        assert r.status_code == 403, r.text
        r = client.delete("/api/v1/universities/1", headers=headers)
        assert r.status_code == 403, r.text


class TestOwnershipAndSpoofing:
    def test_student_id_spoofing_creates_exam_for_jwt_owner(self, students):
        _, student_a, headers_a = students["A"]
        _, student_b, _ = students["B"]

        r = client.get("/api/v1/universities?active_only=true", headers=headers_a)
        uni_id = r.json()[0]["id"]
        r = client.get(
            f"/api/v1/careers?university_id={uni_id}&active_only=true",
            headers=headers_a,
        )
        career_id = r.json()[0]["id"]
        r = client.get(
            f"/api/v1/exam-templates?career_id={career_id}&active_only=true",
            headers=headers_a,
        )
        templates = r.json()
        assert templates, "Se necesitan plantillas seed"
        template_id = templates[0]["id"]

        # Spoof: body dice B, JWT es A
        r = client.post(
            "/api/v1/student-exams",
            headers=headers_a,
            json={"student_id": student_b, "exam_template_id": template_id},
        )
        assert r.status_code == 201, r.text
        exam = r.json()
        exam_id = exam["id"]
        assert exam["student_id"] == student_a

        db = SessionLocal()
        try:
            row = db.execute(
                text("SELECT student_id FROM student_exams WHERE id = :id"),
                {"id": exam_id},
            ).one()
            assert int(row[0]) == student_a
            assert int(row[0]) != student_b
        finally:
            db.close()

        # Adaptive spoof: primero completar un diagnóstico mínimo si hace falta
        # Usamos el mismo exam como based_on solo si COMPLETED; si no, creamos otro start
        # y verificamos spoof en adaptive cuando hay base válida.
        finish = client.post(f"/api/v1/student-exams/{exam_id}/finish", headers=headers_a)
        # Puede fallar si engine exige algo; intentamos adaptive con spoof si finish OK
        if finish.status_code == 200:
            r = client.post(
                "/api/v1/student-exams/adaptive",
                headers=headers_a,
                json={
                    "student_id": student_b,
                    "based_on_student_exam_id": exam_id,
                    "question_count": 5,
                },
            )
            if r.status_code == 201:
                adaptive = r.json()
                assert adaptive["student_id"] == student_a
                db = SessionLocal()
                try:
                    row = db.execute(
                        text("SELECT student_id FROM student_exams WHERE id = :id"),
                        {"id": adaptive["id"]},
                    ).one()
                    assert int(row[0]) == student_a
                finally:
                    db.close()

        students["A_exam_id"] = exam_id
        students["A_template_id"] = template_id
        students["A_exam_status_after"] = finish.status_code

    def test_b_cannot_access_a_exam_routes(self, students):
        _, student_a, headers_a = students["A"]
        _, _, headers_b = students["B"]

        # Crear exam fresco de A para ownership (sin finish previo)
        template_id = students.get("A_template_id")
        if not template_id:
            r = client.get("/api/v1/universities?active_only=true", headers=headers_a)
            uni_id = r.json()[0]["id"]
            r = client.get(
                f"/api/v1/careers?university_id={uni_id}&active_only=true",
                headers=headers_a,
            )
            career_id = r.json()[0]["id"]
            r = client.get(
                f"/api/v1/exam-templates?career_id={career_id}&active_only=true",
                headers=headers_a,
            )
            template_id = r.json()[0]["id"]

        r = client.post(
            "/api/v1/student-exams",
            headers=headers_a,
            json={"student_id": student_a, "exam_template_id": template_id},
        )
        assert r.status_code == 201, r.text
        exam = r.json()
        exam_id = exam["id"]
        questions = exam.get("questions") or []
        qid = questions[0]["id"] if questions else 1
        opt = None
        if questions and questions[0].get("options"):
            opt = questions[0]["options"][0]["id"]

        db = SessionLocal()
        try:
            before = db.execute(
                text(
                    "SELECT status, updated_at, "
                    "(SELECT COUNT(*) FROM student_answers sa WHERE sa.student_exam_id = se.id) AS answers "
                    "FROM student_exams se WHERE se.id = :id"
                ),
                {"id": exam_id},
            ).one()
            before_status, before_updated, before_answers = before[0], str(before[1]), int(before[2])
        finally:
            db.close()

        forbidden_gets = [
            f"/api/v1/student-exams/{exam_id}",
            f"/api/v1/student-exams/{exam_id}/time",
            f"/api/v1/student-exams/{exam_id}/results",
            f"/api/v1/student-exams/{exam_id}/review",
            f"/api/v1/diagnostics/student-exams/{exam_id}",
            f"/api/v1/diagnostics/student-exams/{exam_id}/areas",
            f"/api/v1/recommendations/student-exams/{exam_id}",
            f"/api/v1/study-tools/student-exams/{exam_id}/flashcards",
            f"/api/v1/study-tools/student-exams/{exam_id}/concept-map",
        ]
        for path in forbidden_gets:
            r = client.get(path, headers=headers_b)
            assert r.status_code == 403, f"GET {path} -> {r.status_code} {r.text}"

        r = client.post(
            f"/api/v1/student-exams/{exam_id}/answers",
            headers=headers_b,
            json={"question_id": qid, "selected_option_id": opt, "time_seconds": 1},
        )
        assert r.status_code == 403, r.text

        r = client.patch(
            f"/api/v1/student-exams/{exam_id}/answers/{qid}/save",
            headers=headers_b,
            json={"is_saved": True},
        )
        assert r.status_code == 403, r.text

        r = client.post(f"/api/v1/student-exams/{exam_id}/finish", headers=headers_b)
        assert r.status_code == 403, r.text

        for path in (
            "/api/v1/agents/diagnostic/analyze",
            "/api/v1/agents/motivator/encourage",
            "/api/v1/agents/parents/report",
        ):
            r = client.post(path, headers=headers_b, json={"student_exam_id": exam_id})
            assert r.status_code == 403, f"POST {path} -> {r.status_code} {r.text}"

        # Exam A no modificado por intentos de B
        db = SessionLocal()
        try:
            after = db.execute(
                text(
                    "SELECT status, updated_at, "
                    "(SELECT COUNT(*) FROM student_answers sa WHERE sa.student_exam_id = se.id) AS answers "
                    "FROM student_exams se WHERE se.id = :id"
                ),
                {"id": exam_id},
            ).one()
            assert after[0] == before_status
            assert str(after[1]) == before_updated
            assert int(after[2]) == before_answers
            assert int(
                db.execute(
                    text("SELECT student_id FROM student_exams WHERE id = :id"),
                    {"id": exam_id},
                ).scalar()
            ) == student_a
        finally:
            db.close()

        students["ownership_exam_id"] = exam_id


class TestSavedAnswers:
    def test_saved_answers_auth_and_isolation(self, students):
        _, student_a, headers_a = students["A"]
        _, student_b, headers_b = students["B"]

        r = client.get("/api/v1/students/me/saved-answers", headers=headers_a)
        assert r.status_code == 200, r.text
        assert isinstance(r.json(), list)

        r = client.get(f"/api/v1/students/{student_b}/saved-answers", headers=headers_a)
        assert r.status_code == 403, r.text

        r = client.get(f"/api/v1/students/{student_a}/saved-answers", headers=headers_a)
        assert r.status_code == 200, r.text

        r = client.get("/api/v1/students/me/saved-answers")
        assert r.status_code == 401


class TestRagTutorAgentsUnauth:
    def test_rag_without_jwt_401(self):
        cases = [
            ("post", "/api/v1/rag/ingest/text", {"text": "hola", "source": "t"}),
            ("post", "/api/v1/rag/search", {"query": "x", "top_k": 1}),
            ("post", "/api/v1/rag/diagram", {"title": "t"}),
            ("get", "/api/v1/rag/stats", None),
            ("get", "/api/v1/rag/context?career_id=1", None),
        ]
        for method, path, body in cases:
            if method == "get":
                r = client.get(path)
            else:
                r = client.post(path, json=body)
            assert r.status_code == 401, f"{method} {path} -> {r.status_code}"

        # file ingest
        r = client.post(
            "/api/v1/rag/ingest/file",
            files={"file": ("x.txt", b"hello", "text/plain")},
        )
        assert r.status_code == 401, r.text

    def test_rag_with_jwt_passes_auth(self, students):
        _, student_a, headers = students["A"]
        r = client.get("/api/v1/rag/stats", headers=headers)
        # 200 o 500 de chroma; no 401/403
        assert r.status_code != 401
        assert r.status_code != 403

        r = client.get("/api/v1/rag/context?career_id=1", headers=headers)
        assert r.status_code in (200, 404, 422)

        r = client.post(
            "/api/v1/rag/ingest/text",
            headers=headers,
            json={
                "text": f"stage2 verification {time.time()}",
                "source": "stage2_test",
                "title": "stage2",
            },
        )
        # Auth OK; puede fallar RAG por infra pero no 401/403
        assert r.status_code not in (401, 403), r.text
        if r.status_code in (200, 201):
            # student_id en metadata no lo expone la response; se validó vía Depends JWT
            pass

        r = client.post(
            "/api/v1/rag/search",
            headers=headers,
            json={"query": "stage2", "top_k": 1},
        )
        assert r.status_code not in (401, 403), r.text

        r = client.post(
            "/api/v1/rag/diagram",
            headers=headers,
            json={"title": "stage2"},
        )
        assert r.status_code not in (401, 403), r.text

    def test_tutor_agents_without_jwt_401(self):
        r = client.post("/api/v1/tutor/explain", json={"question_id": 1})
        assert r.status_code == 401
        r = client.post("/api/v1/tutor/hint", json={"question_id": 1})
        assert r.status_code == 401
        for path in (
            "/api/v1/agents/diagnostic/analyze",
            "/api/v1/agents/motivator/encourage",
            "/api/v1/agents/parents/report",
        ):
            r = client.post(path, json={"student_exam_id": 1})
            assert r.status_code == 401, path

    def test_tutor_with_jwt_passes_auth(self, students):
        _, _, headers = students["A"]
        r = client.post("/api/v1/tutor/explain", headers=headers, json={"question_id": 1})
        # 200/404/502/503 según datos/LLM; no 401
        assert r.status_code != 401
        r = client.post("/api/v1/tutor/hint", headers=headers, json={"question_id": 1})
        assert r.status_code != 401
