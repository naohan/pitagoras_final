"""Carga datos demo para probar el flujo completo con el frontend.

Uso (desde backend/ con el venv activo):
    python -m scripts.seed.seed_demo
"""

from __future__ import annotations

from sqlalchemy import select

from app.database.session import SessionLocal
from app.exams.exam_engine_service import ExamEngineService
from app.models.academic import AdmissionProcess, Career, University
from app.models.enums import QuestionLevel
from app.models.exam import ExamTemplate, ExamTemplateQuestion
from app.models.question import Question, QuestionOption
from app.repositories.university_repository import UniversityRepository
from scripts.seed.seed_academic import ensure_engineering_math_tree, resolve_subtopic_id

DEMO_QUESTIONS: list[dict] = [
    {
        "stem": (
            "La media y la varianza de dos números son 3 y 1,5 respectivamente. "
            "Si se agrega el número 6, ¿cuál será la varianza de los tres números?"
        ),
        "subtopic_key": "estadistica",
        "explanation": (
            "Con dos datos: media 3 y varianza 1,5. Al agregar 6 la nueva media es 5. "
            "Aplicando la fórmula de varianza poblacional se obtiene 3. Respuesta E."
        ),
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "3,2", False),
            ("B", "2,5", False),
            ("C", "2,6", False),
            ("D", "2,8", False),
            ("E", "3", True),
        ],
    },
    {
        "stem": (
            "La edad de Roberto es el doble de la edad de Elizabeth. Hace 6 años, "
            "la suma de sus edades era igual al promedio de sus edades actuales. "
            "¿Cuánto sumarán sus edades dentro de 14 años?"
        ),
        "subtopic_key": "ecuaciones",
        "explanation": (
            "Sea E la edad de Elizabeth: Roberto = 2E. Hace 6 años: (2E−6)+(E−6) = (2E+E)/2. "
            "Resolviendo E=8, Roberto=16. En 14 años: 22+30=52. Respuesta D."
        ),
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "60", False),
            ("B", "42", False),
            ("C", "40", False),
            ("D", "52", True),
            ("E", "62", False),
        ],
    },
    {
        "stem": (
            "Julián deposita S/1000 hoy, después de 2 meses hará otro depósito de S/500. "
            "Determine el monto que retirará dentro de 6 meses, si la entidad bancaria "
            "le paga 1,5 % de interés simple mensual."
        ),
        "subtopic_key": "proporcionalidad",
        "explanation": (
            "S/1000 al 1,5% simple por 6 meses + S/500 al 1,5% simple por 4 meses. "
            "Total ≈ S/1620. Respuesta A."
        ),
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "S/1620", True),
            ("B", "S/1590", False),
            ("C", "S/135", False),
            ("D", "S/120", False),
            ("E", "S/1635", False),
        ],
    },
    {
        "stem": (
            "Si Fabián depositó los 4/5 de su capital a una tasa del 2% mensual durante "
            "dos meses y el resto a una tasa del 4% trimestral, durante seis meses. "
            "Calcule el capital de Fabián si en total recibió S/104 864, sabiendo que "
            "se aplica un interés compuesto."
        ),
        "subtopic_key": "proporcionalidad",
        "explanation": (
            "Sea C el capital. (4C/5)(1,02)² + (C/5)(1,04)² = 104864 con interés compuesto "
            "en cada tramo. Resolviendo C = S/100 000. Respuesta E."
        ),
        "difficulty": 5,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "S/120 000", False),
            ("B", "S/200 000", False),
            ("C", "S/90 000", False),
            ("D", "S/180 000", False),
            ("E", "S/100 000", True),
        ],
    },
    {
        "stem": (
            "Un grupo de 5 varones y 4 mujeres, donde Nancy y Martín son pareja al igual "
            "que Magaly y Leo, van al cine y se sientan en una fila de 9 asientos. "
            "Si las parejas deben sentarse en los extremos, ¿de cuántas maneras pueden hacerlo?"
        ),
        "subtopic_key": "probabilidad",
        "explanation": (
            "2 formas de ubicar las parejas en extremos × 2! orden interno por pareja × "
            "5! permutaciones del resto = 960. Respuesta D."
        ),
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "1020", False),
            ("B", "480", False),
            ("C", "1000", False),
            ("D", "960", True),
            ("E", "720", False),
        ],
    },
]


def _get_or_create_university(db, code: str, name: str) -> University:
    repo = UniversityRepository(db)
    existing = repo.get_by_code(code)
    if existing is not None:
        return existing
    entity = University(code=code, name=name, country="PE", is_active=True)
    repo.create(entity)
    db.flush()
    return entity


def _get_or_create_career(db, university_id: int, code: str, name: str) -> Career:
    stmt = select(Career).where(
        Career.university_id == university_id,
        Career.code == code,
    )
    existing = db.scalars(stmt).first()
    if existing is not None:
        return existing
    entity = Career(university_id=university_id, code=code, name=name, is_active=True)
    db.add(entity)
    db.flush()
    return entity


def _get_or_create_admission_process(db, career_id: int, year: int) -> AdmissionProcess:
    stmt = select(AdmissionProcess).where(
        AdmissionProcess.career_id == career_id,
        AdmissionProcess.year == year,
    )
    existing = db.scalars(stmt).first()
    if existing is not None:
        return existing
    entity = AdmissionProcess(
        career_id=career_id,
        name=f"Admisión {year}",
        year=year,
        description="Proceso demo Pitágoras",
        is_active=True,
    )
    db.add(entity)
    db.flush()
    return entity


def _upsert_question(db, slug_map: dict[str, int], item: dict) -> Question:
    stmt = select(Question).where(Question.stem == item["stem"])
    existing = db.scalars(stmt).first()
    subtopic_id = resolve_subtopic_id(slug_map, item.get("subtopic_key", "general"))

    if existing is not None:
        if not existing.explanation and item.get("explanation"):
            existing.explanation = item["explanation"]
        if existing.subtopic_id != subtopic_id:
            existing.subtopic_id = subtopic_id
        if item.get("difficulty"):
            existing.difficulty = item["difficulty"]
        if item.get("level"):
            existing.level = item["level"]
        return existing

    question = Question(
        subtopic_id=subtopic_id,
        stem=item["stem"],
        explanation=item.get("explanation"),
        difficulty=item.get("difficulty", 2),
        level=item.get("level", QuestionLevel.INTERMEDIATE),
        is_active=True,
    )
    db.add(question)
    db.flush()

    for order, (label, text, is_correct) in enumerate(item["options"], start=1):
        db.add(
            QuestionOption(
                question_id=question.id,
                label=label,
                text=text,
                is_correct=is_correct,
                display_order=order,
            )
        )
    db.flush()
    return question


def _ensure_questions(db, slug_map: dict[str, int]) -> list[Question]:
    return [_upsert_question(db, slug_map, item) for item in DEMO_QUESTIONS]


def _refresh_exam_template(
    db,
    template: ExamTemplate,
    question_ids: list[int],
) -> ExamTemplate:
    for link in list(template.template_questions):
        db.delete(link)
    db.flush()
    for order, question_id in enumerate(question_ids, start=1):
        db.add(
            ExamTemplateQuestion(
                exam_template_id=template.id,
                question_id=question_id,
                display_order=order,
            )
        )
    db.flush()
    db.refresh(template)
    return template


def _ensure_exam_template(
    db,
    *,
    admission_process_id: int,
    question_ids: list[int],
    name: str,
) -> ExamTemplate:
    stmt = select(ExamTemplate).where(
        ExamTemplate.admission_process_id == admission_process_id,
        ExamTemplate.name == name,
    )
    existing = db.scalars(stmt).first()
    if existing is not None:
        return _refresh_exam_template(db, existing, question_ids)

    engine = ExamEngineService(db)
    return engine.create_exam_template(
        admission_process_id=admission_process_id,
        name=name,
        duration_minutes=90,
        question_count=len(question_ids),
        auto_select_questions=False,
        question_ids=question_ids,
    )


def _seed_career_demo(
    db,
    *,
    career: Career,
    template_name: str,
) -> ExamTemplate:
    admission = _get_or_create_admission_process(db, career.id, 2026)
    slug_map = ensure_engineering_math_tree(db, admission.id)
    questions = _ensure_questions(db, slug_map)
    return _ensure_exam_template(
        db,
        admission_process_id=admission.id,
        question_ids=[q.id for q in questions],
        name=template_name,
    )


def seed_demo() -> None:
    db = SessionLocal()
    try:
        unsa = _get_or_create_university(
            db,
            "UNSA",
            "Universidad Nacional de San Agustín",
        )
        _get_or_create_university(
            db,
            "UCSM",
            "Universidad Católica de Santa María",
        )

        sis_career = _get_or_create_career(
            db,
            unsa.id,
            "SIS",
            "Ingeniería de Sistemas",
        )
        civil_career = _get_or_create_career(
            db,
            unsa.id,
            "CIV",
            "Ingeniería Civil",
        )

        sis_template = _seed_career_demo(
            db,
            career=sis_career,
            template_name="Simulacro Ingeniería de Sistemas",
        )
        civil_template = _seed_career_demo(
            db,
            career=civil_career,
            template_name="Simulacro Ingeniería Civil",
        )

        db.commit()

        print("Seed demo aplicado correctamente.")
        print(f"  Universidades: UNSA (id={unsa.id}), UCSM")
        print(f"  Plantilla SIS: id={sis_template.id} — {sis_template.name}")
        print(f"  Plantilla CIV: id={civil_template.id} — {civil_template.name}")
        print(f"  Preguntas demo: {len(DEMO_QUESTIONS)} (con explicación)")
        print()
        print("Siguiente:")
        print("  python -m scripts.seed.seed_extra_questions")
        print("  python -m scripts.seed.seed_ordinario_2026")
        print("  python -m scripts.seed.seed_hackathon_demo")
        print("  python -m scripts.seed.seed_rubinos_questions --file <html>")
        print("  python -m scripts.seed.seed_rag_urls --url https://matematicasn.blogspot.com/...")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_demo()
