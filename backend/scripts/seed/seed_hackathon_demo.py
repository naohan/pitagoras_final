"""Cuenta demo precargada para hackathon (diagnóstico + ordinario 2026 resueltos).

Uso (desde backend/ con venv):
    python -m scripts.seed.seed_demo
    python -m scripts.seed.seed_ordinario_2026
    python -m scripts.seed.seed_hackathon_demo

Credenciales:
    Email:    demo@pitagoras.hack
    Password: Pitagoras2026
"""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.auth.password import hash_password
from app.database.session import SessionLocal
from app.exams.exam_engine_service import ExamEngineService
from app.models.academic import AdmissionProcess, Career, University
from app.models.enums import StudentExamStatus, UserRole
from app.models.exam import ExamTemplate, ExamTemplateQuestion, StudentExam
from app.models.user import User
from app.models.student import Student
from app.models.question import Question
from app.repositories.student_repository import StudentRepository
from app.repositories.user_repository import UserRepository
from app.demo.constants import (
    DIAGNOSTIC_TEMPLATE_NAME,
    DIAGNOSTIC_WRONG_ORDERS,
    HACKATHON_EMAIL,
    HACKATHON_FULL_NAME,
    HACKATHON_PASSWORD,
    ORDINARIO_SAVED_ORDERS,
    ORDINARIO_TEMPLATE_NAME,
    ORDINARIO_WRONG_ORDERS,
)
from scripts.seed.seed_demo import DEMO_QUESTIONS


def _get_template(db, admission_id: int, name: str) -> ExamTemplate | None:
    stmt = (
        select(ExamTemplate)
        .where(
            ExamTemplate.admission_process_id == admission_id,
            ExamTemplate.name == name,
        )
        .options(
            selectinload(ExamTemplate.template_questions)
            .selectinload(ExamTemplateQuestion.question)
            .selectinload(Question.options),
        )
    )
    return db.scalars(stmt).first()


def _find_completed_exam(
    db,
    student_id: int,
    template_name: str,
) -> StudentExam | None:
    stmt = (
        select(StudentExam)
        .join(ExamTemplate, StudentExam.exam_template_id == ExamTemplate.id)
        .where(
            StudentExam.student_id == student_id,
            ExamTemplate.name == template_name,
            StudentExam.status == StudentExamStatus.COMPLETED,
        )
        .order_by(StudentExam.id.desc())
        .limit(1)
    )
    return db.scalars(stmt).first()


def _ensure_demo_user(db) -> Student:
    users = UserRepository(db)
    students = StudentRepository(db)
    existing_user = users.get_by_email(HACKATHON_EMAIL)
    if existing_user is not None:
        student = students.get_by_user_id(existing_user.id)
        if student is None:
            raise RuntimeError("Usuario demo sin perfil de estudiante")
        existing_user.password_hash = hash_password(HACKATHON_PASSWORD)
        existing_user.is_active = True
        student.full_name = HACKATHON_FULL_NAME
        db.flush()
        return student

    user = User(
        email=HACKATHON_EMAIL,
        password_hash=hash_password(HACKATHON_PASSWORD),
        role=UserRole.STUDENT,
        is_active=True,
    )
    users.create(user)
    student = Student(
        user_id=user.id,
        email=HACKATHON_EMAIL,
        full_name=HACKATHON_FULL_NAME,
        is_active=True,
    )
    students.create(student)
    db.flush()
    return student


def _complete_exam(
    engine: ExamEngineService,
    db: Session,
    *,
    student_id: int,
    template: ExamTemplate,
    wrong_display_orders: set[int],
    saved_display_orders: set[int] | None = None,
) -> StudentExam:
    student_exam = engine.start_student_exam(
        student_id=student_id,
        exam_template_id=template.id,
    )
    items = sorted(template.template_questions, key=lambda item: item.display_order)
    for item in items:
        question = item.question
        if question is None:
            continue
        options = sorted(question.options, key=lambda opt: opt.display_order)
        correct = next(opt for opt in options if opt.is_correct)
        wrong = next(opt for opt in options if not opt.is_correct)
        selected = wrong if item.display_order in wrong_display_orders else correct
        engine.submit_answer(
            student_exam_id=student_exam.id,
            question_id=question.id,
            selected_option_id=selected.id,
            time_seconds=75,
        )
        if saved_display_orders and item.display_order in saved_display_orders:
            engine.toggle_save_answer(
                student_exam_id=student_exam.id,
                question_id=question.id,
                is_saved=True,
            )
    return engine.finish_exam(student_exam.id)


def _resolve_sis_context(db) -> tuple[University, Career, AdmissionProcess]:
    stmt = (
        select(University, Career, AdmissionProcess)
        .join(Career, Career.university_id == University.id)
        .join(AdmissionProcess, AdmissionProcess.career_id == Career.id)
        .where(University.code == "UNSA", Career.code == "SIS")
        .order_by(AdmissionProcess.year.desc())
        .limit(1)
    )
    row = db.execute(stmt).first()
    if row is None:
        raise RuntimeError("Ejecuta primero: python -m scripts.seed.seed_demo")
    return row[0], row[1], row[2]


def seed_hackathon_demo() -> None:
    db = SessionLocal()
    try:
        university, career, admission = _resolve_sis_context(db)
        student = _ensure_demo_user(db)
        engine = ExamEngineService(db)

        diagnostic_template = _get_template(db, admission.id, DIAGNOSTIC_TEMPLATE_NAME)
        ordinario_template = _get_template(db, admission.id, ORDINARIO_TEMPLATE_NAME)
        if diagnostic_template is None:
            raise RuntimeError(f"Plantilla no encontrada: {DIAGNOSTIC_TEMPLATE_NAME}")
        if ordinario_template is None:
            raise RuntimeError(
                f"Plantilla no encontrada: {ORDINARIO_TEMPLATE_NAME}. "
                "Ejecuta: python -m scripts.seed.seed_ordinario_2026"
            )

        diagnostic_exam = _find_completed_exam(db, student.id, DIAGNOSTIC_TEMPLATE_NAME)
        if diagnostic_exam is None:
            diagnostic_exam = _complete_exam(
                engine,
                db,
                student_id=student.id,
                template=diagnostic_template,
                wrong_display_orders=DIAGNOSTIC_WRONG_ORDERS,
            )

        ordinario_exam = _find_completed_exam(db, student.id, ORDINARIO_TEMPLATE_NAME)
        if ordinario_exam is None:
            ordinario_exam = _complete_exam(
                engine,
                db,
                student_id=student.id,
                template=ordinario_template,
                wrong_display_orders=ORDINARIO_WRONG_ORDERS,
                saved_display_orders=ORDINARIO_SAVED_ORDERS,
            )

        db.commit()

        diag_score = diagnostic_exam.result.score_percent if diagnostic_exam.result else "—"
        ord_score = ordinario_exam.result.score_percent if ordinario_exam.result else "—"

        print("Cuenta hackathon lista.")
        print()
        print("  Login app:")
        print(f"    Email:    {HACKATHON_EMAIL}")
        print(f"    Password: {HACKATHON_PASSWORD}")
        print("    (o botón «Demo hackathon» en la pantalla de login)")
        print()
        print(f"  Estudiante id={student.id} — {HACKATHON_FULL_NAME}")
        print(f"  Universidad: {university.name} (id={university.id})")
        print(f"  Carrera: {career.name} (id={career.id})")
        print()
        print(f"  Diagnóstico: student_exam_id={diagnostic_exam.id} — puntaje {diag_score}%")
        print(f"  Ordinario 2026: student_exam_id={ordinario_exam.id} — puntaje {ord_score}%")
        print(f"  Plantilla ordinario id={ordinario_template.id}")
        print()
        print(f"  Diagnóstico: {len(DEMO_QUESTIONS) - len(DIAGNOSTIC_WRONG_ORDERS)}/"
              f"{len(DEMO_QUESTIONS)} correctas")
        print(f"  Ordinario: {ordinario_template.question_count - len(ORDINARIO_WRONG_ORDERS)}/"
              f"{ordinario_template.question_count} correctas")
        print(f"  Respuestas guardadas en ordinario: {len(ORDINARIO_SAVED_ORDERS)}")
        print()
        print("  Perfil API: GET /api/v1/demo/hackathon-profile")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_hackathon_demo()
