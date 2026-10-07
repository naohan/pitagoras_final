"""Perfil pÃºblico de la cuenta demo hackathon (sin contraseÃ±a)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.academic import AdmissionProcess, Career, University
from app.models.enums import StudentExamStatus
from app.models.exam import ExamTemplate, StudentExam
from app.models.student import Student
from app.models.user import User
from app.schemas.demo import HackathonProfileResponse
from app.demo.constants import (
    DIAGNOSTIC_TEMPLATE_NAME,
    HACKATHON_EMAIL,
    HACKATHON_FULL_NAME,
    ORDINARIO_TEMPLATE_NAME,
)

router = APIRouter(prefix="/demo", tags=["Demo hackathon"])


def _find_completed_exam(
    db: Session,
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


def _resolve_sis_context(db: Session) -> tuple[University, Career, AdmissionProcess]:
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
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Datos UNSA/SIS no encontrados. Ejecuta seed_demo.",
        )
    return row[0], row[1], row[2]


@router.get(
    "/hackathon-profile",
    response_model=HackathonProfileResponse,
    summary="Datos de sesiÃ³n para la cuenta demo hackathon",
)
def get_hackathon_profile(db: Session = Depends(get_db)) -> HackathonProfileResponse:
    student = db.scalars(
        select(Student)
        .join(User, Student.user_id == User.id)
        .where(User.email == HACKATHON_EMAIL)
    ).first()
    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cuenta demo no configurada. Ejecuta: python -m scripts.seed.seed_hackathon_demo",
        )

    university, career, admission = _resolve_sis_context(db)

    diagnostic_exam = _find_completed_exam(db, student.id, DIAGNOSTIC_TEMPLATE_NAME)
    ordinario_exam = _find_completed_exam(db, student.id, ORDINARIO_TEMPLATE_NAME)
    if diagnostic_exam is None or ordinario_exam is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ExÃ¡menes demo incompletos. Ejecuta: python -m scripts.seed.seed_hackathon_demo",
        )

    ordinario_template = db.scalars(
        select(ExamTemplate).where(ExamTemplate.id == ordinario_exam.exam_template_id)
    ).first()

    return HackathonProfileResponse(
        email=HACKATHON_EMAIL,
        full_name=HACKATHON_FULL_NAME,
        student_id=student.id,
        university_id=university.id,
        university_name=university.name,
        career_id=career.id,
        career_name=career.name,
        admission_process_id=admission.id,
        ordinario_template_id=ordinario_template.id if ordinario_template else None,
        diagnostic_student_exam_id=diagnostic_exam.id,
        last_student_exam_id=ordinario_exam.id,
        diagnostic_completed=True,
    )
