"""Asegura que cada carrera activa tenga al menos un simulacro.

Si una carrera (p.ej. duplicado por universidad) no tiene plantillas,
clona las de otra carrera con el mismo código, incluyendo sus preguntas.
"""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.database.session import SessionLocal
from app.models.academic import AdmissionProcess, Career
from app.models.exam import ExamTemplate, ExamTemplateQuestion


def main() -> None:
    db = SessionLocal()
    try:
        careers = list(db.scalars(select(Career).where(Career.is_active.is_(True))).all())
        created = 0
        for career in careers:
            process = db.scalars(
                select(AdmissionProcess).where(
                    AdmissionProcess.career_id == career.id,
                    AdmissionProcess.is_active.is_(True),
                )
            ).first()
            if process is None:
                print(f"skip career={career.id} {career.name}: sin proceso")
                continue

            existing = list(
                db.scalars(
                    select(ExamTemplate).where(
                        ExamTemplate.admission_process_id == process.id,
                        ExamTemplate.is_active.is_(True),
                    )
                ).all()
            )
            if existing:
                print(f"ok career={career.id} {career.name}: {len(existing)} plantillas")
                continue

            donor_career = next(
                (c for c in careers if c.id != career.id and c.code == career.code),
                None,
            )
            if donor_career is None:
                print(f"fail career={career.id} {career.name}: sin donante")
                continue

            donor_process = db.scalars(
                select(AdmissionProcess).where(
                    AdmissionProcess.career_id == donor_career.id,
                    AdmissionProcess.is_active.is_(True),
                )
            ).first()
            if donor_process is None:
                print(f"fail career={career.id}: donante sin proceso")
                continue

            donors = list(
                db.scalars(
                    select(ExamTemplate)
                    .where(
                        ExamTemplate.admission_process_id == donor_process.id,
                        ExamTemplate.is_active.is_(True),
                    )
                    .options(selectinload(ExamTemplate.template_questions))
                ).all()
            )
            if not donors:
                print(f"fail career={career.id}: donante sin plantillas")
                continue

            for donor in donors:
                clone = ExamTemplate(
                    admission_process_id=process.id,
                    name=donor.name,
                    duration_minutes=donor.duration_minutes,
                    question_count=donor.question_count,
                    is_active=True,
                )
                db.add(clone)
                db.flush()
                for link in donor.template_questions:
                    db.add(
                        ExamTemplateQuestion(
                            exam_template_id=clone.id,
                            question_id=link.question_id,
                            display_order=link.display_order,
                        )
                    )
                created += 1
                print(
                    f"  + '{donor.name}' -> process {process.id} "
                    f"(career {career.id}, {len(donor.template_questions)} preguntas)"
                )

        db.commit()
        print(f"Listo. Plantillas creadas: {created}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()
