"""
Crea/actualiza plantillas de simulacro alineadas a specs oficiales UNSA/UCSM.

Uso:
  cd backend
  .venv\\Scripts\\python.exe -m scripts.seed.seed_official_exam_templates

Nota: el banco actual puede tener < 80 preguntas. En ese caso se adjunta
el máximo disponible y question_count refleja ese máximo (el nombre de la
plantilla sigue indicando la modalidad oficial). Ampliar el banco después.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from sqlalchemy import select

from app.database.session import SessionLocal
from app.exams.admission_exam_specs import all_modality_specs, template_name
from app.models.academic import AdmissionProcess, Career, University
from app.models.exam import ExamTemplate, ExamTemplateQuestion
from app.models.question import Question


def _latest_process(session, career_id: int) -> AdmissionProcess | None:
    return session.scalars(
        select(AdmissionProcess)
        .where(AdmissionProcess.career_id == career_id, AdmissionProcess.is_active.is_(True))
        .order_by(AdmissionProcess.year.desc(), AdmissionProcess.id.desc())
    ).first()


def _active_question_ids(session, limit: int) -> list[int]:
    rows = session.scalars(
        select(Question.id)
        .where(Question.is_active.is_(True))
        .order_by(Question.id.asc())
        .limit(limit)
    ).all()
    return list(rows)


def _upsert_template(
    session,
    *,
    process: AdmissionProcess,
    name: str,
    question_count: int,
    duration_minutes: int,
    question_ids: list[int],
) -> ExamTemplate:
    existing = session.scalars(
        select(ExamTemplate).where(
            ExamTemplate.admission_process_id == process.id,
            ExamTemplate.name == name,
        )
    ).first()

    actual_count = min(question_count, len(question_ids))
    if actual_count == 0:
        raise RuntimeError("No hay preguntas activas en el banco para armar plantillas.")

    ids = question_ids[:actual_count]

    if existing is None:
        existing = ExamTemplate(
            admission_process_id=process.id,
            name=name,
            duration_minutes=duration_minutes,
            question_count=actual_count,
            is_active=True,
        )
        session.add(existing)
        session.flush()
    else:
        existing.duration_minutes = duration_minutes
        existing.question_count = actual_count
        existing.is_active = True
        for link in list(existing.template_questions):
            session.delete(link)
        session.flush()

    for order, qid in enumerate(ids, start=1):
        session.add(
            ExamTemplateQuestion(
                exam_template_id=existing.id,
                question_id=qid,
                display_order=order,
            )
        )
    return existing


def main() -> None:
    session = SessionLocal()
    try:
        question_ids = _active_question_ids(session, limit=200)
        bank_size = len(question_ids)
        print(f"Banco activo: {bank_size} preguntas")

        careers = session.scalars(
            select(Career)
            .join(University)
            .where(Career.is_active.is_(True), University.is_active.is_(True))
        ).all()

        created = 0
        for career in careers:
            uni = career.university
            process = _latest_process(session, career.id)
            if process is None:
                print(f"  skip {uni.code}/{career.code}: sin proceso de admisión")
                continue

            for spec in all_modality_specs():
                if spec.university_code != uni.code:
                    continue
                name = template_name(spec)
                tpl = _upsert_template(
                    session,
                    process=process,
                    name=name,
                    question_count=spec.question_count,
                    duration_minutes=spec.duration_minutes,
                    question_ids=question_ids,
                )
                flag = "" if tpl.question_count == spec.question_count else (
                    f" (parcial: banco={bank_size}, oficial={spec.question_count})"
                )
                print(
                    f"  OK {uni.code}/{career.code}: {tpl.name} -> "
                    f"{tpl.question_count}q / {tpl.duration_minutes}min{flag}"
                )
                created += 1

        session.commit()
        print(f"Listo: {created} plantillas oficiales upserted.")
        if bank_size < 80:
            print(
                "AVISO: el banco tiene menos de 80 preguntas. "
                "Amplía el seed de preguntas para cuadernillos completos."
            )
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


if __name__ == "__main__":
    main()
