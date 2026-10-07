"""Importa preguntas del banco Rubiños (HTML) a MySQL.

Uso (desde backend/):
    python -m scripts.seed.seed_rubinos_questions --section ingenierias
    python -m scripts.seed.seed_rubinos_questions --file solucionario.html --section ingenierias
    python -m scripts.seed.seed_rubinos_questions --section legacy --url https://matematicasn.blogspot.com/2016/01/...
"""

from __future__ import annotations

import argparse

from sqlalchemy import func, select

from app.database.session import SessionLocal
from app.models.academic import AdmissionProcess, Career, University
from app.models.enums import QuestionLevel
from app.models.exam import ExamTemplate, ExamTemplateQuestion
from app.models.question import Question, QuestionOption
from scripts.seed.rubinos_parser import load_parsed_questions
from scripts.seed.seed_academic import ensure_engineering_math_tree, resolve_subtopic_id

UNSA_SOLUCIONARIO_URL = (
    "https://matematicasn.blogspot.com/2019/03/examen-admision-unsa-solucionario-pdf.html"
)
FUNCIONES_URL = (
    "https://matematicasn.blogspot.com/2016/01/estudio-y-representacion-de-funciones.html"
)


def _resolve_sis_admission_id(db) -> int | None:
    stmt = (
        select(AdmissionProcess.id)
        .join(Career, AdmissionProcess.career_id == Career.id)
        .join(University, Career.university_id == University.id)
        .where(University.code == "UNSA", Career.code == "SIS")
        .order_by(AdmissionProcess.year.desc())
        .limit(1)
    )
    return db.scalar(stmt)


def _upsert_rubinos_question(db, slug_map: dict[str, int], parsed) -> Question | None:
    stmt = select(Question).where(Question.stem == parsed.stem)
    existing = db.scalars(stmt).first()
    subtopic_id = resolve_subtopic_id(slug_map, parsed.subtopic_key)

    if existing is not None:
        if not existing.explanation:
            existing.explanation = parsed.explanation
        return None

    question = Question(
        subtopic_id=subtopic_id,
        stem=parsed.stem,
        explanation=parsed.explanation,
        difficulty=3,
        level=QuestionLevel.INTERMEDIATE,
        is_active=True,
    )
    db.add(question)
    db.flush()

    for order, (label, text) in enumerate(parsed.options, start=1):
        db.add(
            QuestionOption(
                question_id=question.id,
                label=label,
                text=text,
                is_correct=label == parsed.correct_label,
                display_order=order,
            )
        )
    db.flush()
    return question


def _expand_template(db, admission_id: int, question_ids: list[int], *, max_questions: int = 30) -> None:
    stmt = select(ExamTemplate).where(
        ExamTemplate.admission_process_id == admission_id,
        ExamTemplate.name == "Simulacro Ingeniería de Sistemas",
    )
    template = db.scalars(stmt).first()
    if template is None:
        return

    existing_ids = {
        row.question_id
        for row in db.execute(
            select(ExamTemplateQuestion.question_id).where(
                ExamTemplateQuestion.exam_template_id == template.id
            )
        ).all()
    }

    order = len(existing_ids) + 1
    added = 0
    for question_id in question_ids:
        if question_id in existing_ids:
            continue
        if len(existing_ids) + added >= max_questions:
            break
        db.add(
            ExamTemplateQuestion(
                exam_template_id=template.id,
                question_id=question_id,
                display_order=order,
            )
        )
        order += 1
        added += 1

    if added:
        template.question_count = len(existing_ids) + added


def seed_rubinos_questions(
    *,
    url: str | None = None,
    file_path: str | None = None,
    limit: int | None = 50,
    section: str = "ingenierias",
    expand_template: bool = True,
) -> None:
    parsed_list = load_parsed_questions(
        url=url,
        file_path=file_path,
        limit=limit,
        section=section if section != "all" else "ingenierias",
    )
    if not parsed_list:
        print("No se encontraron preguntas válidas en el HTML.")
        return

    db = SessionLocal()
    try:
        admission_id = _resolve_sis_admission_id(db)
        if admission_id is None:
            print("Ejecuta primero: python -m scripts.seed.seed_demo")
            return

        slug_map = ensure_engineering_math_tree(db, admission_id)
        created_ids: list[int] = []
        created = 0
        skipped = 0

        for parsed in parsed_list:
            question = _upsert_rubinos_question(db, slug_map, parsed)
            if question is None:
                skipped += 1
                continue
            created += 1
            created_ids.append(question.id)

        if expand_template and created_ids:
            _expand_template(db, admission_id, created_ids)

        db.commit()
        total = db.scalar(select(func.count()).select_from(Question))
        print(f"Sección: {section}")
        print(f"Preguntas parseadas: {len(parsed_list)}")
        print(f"Nuevas en MySQL: {created}")
        print(f"Ya existían: {skipped}")
        print(f"Total banco: {total}")
        by_topic: dict[str, int] = {}
        for item in parsed_list:
            by_topic[item.subtopic_key] = by_topic.get(item.subtopic_key, 0) + 1
        print("Por subtema:", ", ".join(f"{k}={v}" for k, v in sorted(by_topic.items())))
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Importa preguntas Rubiños a MySQL")
    parser.add_argument("--url", help="URL del banco (HTML)")
    parser.add_argument("--file", help="Archivo HTML local")
    parser.add_argument(
        "--section",
        choices=("ingenierias", "biomedicas", "sociales", "legacy"),
        default="ingenierias",
        help="Sección del solucionario UNSA (default: ingenierias)",
    )
    parser.add_argument("--limit", type=int, default=50, help="Máximo de preguntas a importar")
    parser.add_argument(
        "--no-expand-template",
        action="store_true",
        help="No agregar preguntas a la plantilla de simulacro SIS",
    )
    args = parser.parse_args()

    url = args.url
    if not args.file and not url:
        url = FUNCIONES_URL if args.section == "legacy" else UNSA_SOLUCIONARIO_URL

    seed_rubinos_questions(
        url=url,
        file_path=args.file,
        limit=args.limit,
        section=args.section,
        expand_template=not args.no_expand_template,
    )


if __name__ == "__main__":
    main()
