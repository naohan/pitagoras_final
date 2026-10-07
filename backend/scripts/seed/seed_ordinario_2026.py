"""Examen demo UNSA Ordinario 2026-I — 20 preguntas variadas (hackathon).

Mezcla banco intermedio + ítems tipo solucionario UNSA ingenierías.
No repite las 5 del diagnóstico (seed_demo).

Uso (desde backend/ con venv):
    python -m scripts.seed.seed_demo
    python -m scripts.seed.seed_ordinario_2026

Opcional — indexar PDF oficial en RAG (si está en docs/data o Descargas):
    python -m scripts.seed.seed_ordinario_2026 --index-pdf
"""

from __future__ import annotations

import argparse
from pathlib import Path

from sqlalchemy import func, select

from app.database.session import SessionLocal
from app.exams.exam_engine_service import ExamEngineService
from app.models.academic import AdmissionProcess, Career, University
from app.models.enums import QuestionLevel
from app.models.exam import ExamTemplate, ExamTemplateQuestion
from app.models.question import Question, QuestionOption
from app.demo.constants import ORDINARIO_TEMPLATE_NAME
from scripts.seed.seed_academic import ensure_engineering_math_tree, resolve_subtopic_id

ORDINARIO_DURATION_MINUTES = 90

# 15 intermedias (variedad de subtemas) + 5 tipo examen UNSA (más exigentes)
ORDINARIO_2026_QUESTIONS: list[dict] = [
    {
        "stem": "Si 2x - 8 = 0, Â¿cuál es el valor de x?",
        "subtopic_key": "ecuaciones",
        "explanation": "2x = 8 â†’ x = 4. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [("A", "2", False), ("B", "4", True), ("C", "6", False), ("D", "8", False)],
    },
    {
        "stem": (
            "La sucesión 2 ; 5 ; 10 ; 17 ; 26 ; ... Â¿cuántos términos de 3 dígitos tiene?"
        ),
        "subtopic_key": "general",
        "explanation": (
            "Término general nÂ²+1. Los de 3 dígitos van de 100 a 999 â†’ 22 valores. Respuesta C."
        ),
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "21", False),
            ("B", "25", False),
            ("C", "22", True),
            ("D", "31", False),
            ("E", "17", False),
        ],
    },
    {
        "stem": "Si 5 obreros terminan una obra en 12 días, Â¿cuántos días tardarán 10 obreros?",
        "subtopic_key": "proporcionalidad",
        "explanation": "Proporción inversa: 5Ã—12 = 10Ã—d â†’ d = 6 días. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [("A", "24", False), ("B", "6", True), ("C", "10", False), ("D", "4", False)],
    },
    {
        "stem": (
            "El costo de producción C(x)=40 000+20x+xÂ² (x: unidades; C: soles). "
            "Cada unidad se vende a S/ 520 y el mercado absorbe toda la producción. "
            "Â¿Cuántas unidades maximizan el beneficio?"
        ),
        "subtopic_key": "funciones",
        "explanation": (
            "Beneficio B(x)=520xâˆ’C(x). Derivando e igualando a cero: x=250. Respuesta A."
        ),
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "250", True),
            ("B", "350", False),
            ("C", "400", False),
            ("D", "500", False),
            ("E", "200", False),
        ],
    },
    {
        "stem": "Un triángulo rectángulo tiene catetos 3 y 4. Â¿Cuánto mide la hipotenusa?",
        "subtopic_key": "geometria",
        "explanation": "Por Pitágoras: âˆš(3Â²+4Â²) = 5. Respuesta A.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [("A", "5", True), ("B", "6", False), ("C", "7", False), ("D", "12", False)],
    },
    {
        "stem": (
            "Sea f(x)=|x – a|+2 con a>0. Si el dominio de f es [–a; 2a], Â¿cuál es su rango?"
        ),
        "subtopic_key": "funciones",
        "explanation": "El mínimo de |xâˆ’a| en el intervalo es 0; el máximo en 2a es 2a. Rango [2; 2a+2]. Respuesta A.",
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "[2; 2a+2]", True),
            ("B", "[0; 2a+2]", False),
            ("C", "[2+a; 2a+2]", False),
            ("D", "[2; a+2]", False),
            ("E", "[0; a+2]", False),
        ],
    },
    {
        "stem": "Si un artículo cuesta S/ 80 y tiene 25% de descuento, Â¿cuál es el precio final?",
        "subtopic_key": "proporcionalidad",
        "explanation": "Descuento 25% de 80 = 20; precio final 60 soles. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [("A", "S/ 20", False), ("B", "S/ 60", True), ("C", "S/ 70", False), ("D", "S/ 55", False)],
    },
    {
        "stem": (
            "Un equipo de 16 analistas al 60% de capacidad, 12 días a 6 h/día, atiende 200 clientes. "
            "Â¿Cuántos analistas al 90% de capacidad, 8 días a 10 h/día, se necesitan para 250 clientes?"
        ),
        "subtopic_key": "proporcionalidad",
        "explanation": "Regla de tres compuesta: 12 analistas. Respuesta E.",
        "difficulty": 4,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "9", False),
            ("B", "7", False),
            ("C", "11", False),
            ("D", "8", False),
            ("E", "12", True),
        ],
    },
    {
        "stem": "Si logâ‚‚(8) = x, entonces x es igual a:",
        "subtopic_key": "operaciones_basicas",
        "explanation": "2Â³ = 8, entonces x = 3. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [("A", "2", False), ("B", "3", True), ("C", "4", False), ("D", "8", False)],
    },
    {
        "stem": "Â¿Cuál es el resultado de (x + 3)(x - 3)?",
        "subtopic_key": "operaciones_basicas",
        "explanation": "Producto notable: xÂ² âˆ’ 9. Respuesta A.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "xÂ² - 9", True),
            ("B", "xÂ² + 9", False),
            ("C", "xÂ² - 6", False),
            ("D", "xÂ² + 6x - 9", False),
        ],
    },
    {
        "stem": "Halle la cantidad de divisores compuestos de S = 24â´ Ã— 12Â² Ã— 15Â³.",
        "subtopic_key": "divisibilidad_analogias",
        "explanation": "Factorización prima y fórmula de divisores compuestos â†’ 676. Respuesta B.",
        "difficulty": 5,
        "level": QuestionLevel.ADVANCED,
        "options": [
            ("A", "680", False),
            ("B", "676", True),
            ("C", "685", False),
            ("D", "670", False),
            ("E", "684", False),
        ],
    },
    {
        "stem": "Si P(A) = 0.3 y P(B) = 0.5, y A y B son independientes, Â¿cuál es P(A âˆ© B)?",
        "subtopic_key": "probabilidad",
        "explanation": "P(Aâˆ©B) = P(A)Ã—P(B) = 0.15. Respuesta A.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [("A", "0.15", True), ("B", "0.8", False), ("C", "0.35", False), ("D", "0.2", False)],
    },
    {
        "stem": "Â¿Cuál es el área de un círculo de radio 5 cm? (use Ï€ â‰ˆ 3.14)",
        "subtopic_key": "geometria",
        "explanation": "A = Ï€rÂ² â‰ˆ 3.14Ã—25 = 78.5 cmÂ². Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "31.4 cmÂ²", False),
            ("B", "78.5 cmÂ²", True),
            ("C", "15.7 cmÂ²", False),
            ("D", "25 cmÂ²", False),
        ],
    },
    {
        "stem": "Si |x - 2| = 5, Â¿cuáles son los valores posibles de x?",
        "subtopic_key": "ecuaciones",
        "explanation": "x âˆ’ 2 = 5 o x âˆ’ 2 = âˆ’5 â†’ x = 7 o x = âˆ’3. Respuesta A.",
        "difficulty": 3,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "7 y -3", True),
            ("B", "7 y 3", False),
            ("C", "-7 y 3", False),
            ("D", "5 y -5", False),
        ],
    },
    {
        "stem": "Â¿Cuál es el término general de la progresión 2, 5, 8, 11, ...?",
        "subtopic_key": "general",
        "explanation": "Diferencia constante 3: aâ‚™ = 3n âˆ’ 1. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "n + 1", False),
            ("B", "3n - 1", True),
            ("C", "2n + 1", False),
            ("D", "nÂ²", False),
        ],
    },
    {
        "stem": "La ecuación de la recta que pasa por (0, 0) y (2, 4) es:",
        "subtopic_key": "funciones",
        "explanation": "Pendiente 4/2 = 2, pasa por origen: y = 2x. Respuesta A.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "y = 2x", True),
            ("B", "y = x + 2", False),
            ("C", "y = 4x", False),
            ("D", "y = x/2", False),
        ],
    },
    {
        "stem": "Â¿Cuál es el volumen de un cubo de arista 3 cm?",
        "subtopic_key": "geometria",
        "explanation": "V = 3Â³ = 27 cmÂ³. Respuesta C.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "9 cmÂ³", False),
            ("B", "18 cmÂ³", False),
            ("C", "27 cmÂ³", True),
            ("D", "36 cmÂ³", False),
        ],
    },
    {
        "stem": "En una función lineal f(x) = mx + b, si m < 0 la función es:",
        "subtopic_key": "funciones",
        "explanation": "Pendiente negativa â†’ función decreciente. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "Creciente", False),
            ("B", "Decreciente", True),
            ("C", "Constante", False),
            ("D", "Cuadrática", False),
        ],
    },
    {
        "stem": "Â¿Cuál es la probabilidad de obtener cara al lanzar una moneda justa?",
        "subtopic_key": "probabilidad",
        "explanation": "Un caso favorable de dos: 1/2. Respuesta B.",
        "difficulty": 1,
        "level": QuestionLevel.BASIC,
        "options": [("A", "1/4", False), ("B", "1/2", True), ("C", "1/3", False), ("D", "2/3", False)],
    },
    {
        "stem": "Resuelve: xÂ² = 49",
        "subtopic_key": "ecuaciones",
        "explanation": "x = Â±âˆš49 = Â±7. Respuesta B.",
        "difficulty": 2,
        "level": QuestionLevel.INTERMEDIATE,
        "options": [
            ("A", "x = 7", False),
            ("B", "x = Â±7", True),
            ("C", "x = 49", False),
            ("D", "x = Â±49", False),
        ],
    },
]


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


def _upsert_question(db, slug_map: dict[str, int], item: dict) -> Question:
    stmt = select(Question).where(Question.stem == item["stem"])
    existing = db.scalars(stmt).first()
    subtopic_id = resolve_subtopic_id(slug_map, item.get("subtopic_key", "general"))

    if existing is not None:
        if item.get("explanation"):
            existing.explanation = item["explanation"]
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


def _refresh_exam_template(db, template: ExamTemplate, question_ids: list[int]) -> ExamTemplate:
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


def _ensure_ordinario_template(db, admission_id: int, question_ids: list[int]) -> ExamTemplate:
    stmt = select(ExamTemplate).where(
        ExamTemplate.admission_process_id == admission_id,
        ExamTemplate.name == ORDINARIO_TEMPLATE_NAME,
    )
    existing = db.scalars(stmt).first()
    if existing is not None:
        existing.duration_minutes = ORDINARIO_DURATION_MINUTES
        existing.question_count = len(question_ids)
        return _refresh_exam_template(db, existing, question_ids)

    engine = ExamEngineService(db)
    return engine.create_exam_template(
        admission_process_id=admission_id,
        name=ORDINARIO_TEMPLATE_NAME,
        duration_minutes=ORDINARIO_DURATION_MINUTES,
        question_count=len(question_ids),
        auto_select_questions=False,
        question_ids=question_ids,
    )


def _resolve_pdf_path() -> Path | None:
    repo_root = Path(__file__).resolve().parents[2]
    candidates = [
        repo_root / "docs" / "data" / "examen-ordinario" / "INGENIERIAS-ORDINARIO-2026-I-FASE-pub.pdf",
        Path.home() / "Downloads" / "INGENIERIAS-ORDINARIO-2026-I-FASE-pub.pdf",
    ]
    for path in candidates:
        if path.is_file():
            return path
    return None


def _maybe_index_pdf() -> None:
    pdf_path = _resolve_pdf_path()
    if pdf_path is None:
        print("PDF no encontrado. Copia el archivo a:")
        print("  docs/data/examen-ordinario/INGENIERIAS-ORDINARIO-2026-I-FASE-pub.pdf")
        return

    from app.rag.exceptions import RAGError
    from app.rag.rag_service import RAGService

    print(f"Indexando RAG: {pdf_path.name} â€¦", end=" ", flush=True)
    try:
        result = RAGService().ingest_file(
            pdf_path,
            metadata={
                "title": "UNSA Ordinario 2026-I Ingenierías",
                "content_type": "examen_oficial",
                "area_name": "Ingenierías",
                "university": "UNSA",
                "canal": "ordinario_2026",
            },
        )
        print(f"OK ({result.chunks_indexed} fragmentos)")
    except RAGError as exc:
        print(f"ERROR: {exc.message}")


def seed_ordinario_2026(*, index_pdf: bool = False) -> None:
    db = SessionLocal()
    try:
        admission_id = _resolve_sis_admission_id(db)
        if admission_id is None:
            print("No hay admisión SIS. Ejecuta primero: python -m scripts.seed.seed_demo")
            return

        slug_map = ensure_engineering_math_tree(db, admission_id)
        questions = [_upsert_question(db, slug_map, item) for item in ORDINARIO_2026_QUESTIONS]
        template = _ensure_ordinario_template(
            db,
            admission_id,
            [question.id for question in questions],
        )
        db.commit()

        total = db.scalar(select(func.count()).select_from(Question))
        print("Ordinario 2026-I aplicado.")
        print(f"  Plantilla: id={template.id} — {template.name}")
        print(f"  Preguntas en examen: {len(questions)}")
        print(f"  Duración: {ORDINARIO_DURATION_MINUTES} min")
        print(f"  Total banco MySQL: {total}")
        print()
        print("Subtemas cubiertos: ecuaciones, funciones, geometría, probabilidad,")
        print("proporcionalidad, divisibilidad, operaciones, secuencias.")
        print()
        print("RAG: solucionario + Rubiños ya en ChromaDB (seed_rag_urls).")
        if index_pdf:
            _maybe_index_pdf()
        else:
            print("Para indexar el PDF oficial: python -m scripts.seed.seed_ordinario_2026 --index-pdf")
        print("Cuenta hackathon: python -m scripts.seed.seed_hackathon_demo")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed examen Ordinario 2026-I demo (20 preguntas)")
    parser.add_argument(
        "--index-pdf",
        action="store_true",
        help="Indexa el PDF oficial en ChromaDB si está en docs/data o Descargas",
    )
    args = parser.parse_args()
    seed_ordinario_2026(index_pdf=args.index_pdf)


if __name__ == "__main__":
    main()
