"""Amplía el banco de preguntas del demo (más allá de las 5 del diagnóstico).

Uso (desde backend/):
    python -m scripts.seed.seed_extra_questions
"""

from __future__ import annotations

from sqlalchemy import func, select

from app.database.session import SessionLocal
from app.models.academic import AdmissionProcess, Career, University
from app.models.enums import QuestionLevel
from app.models.question import Question, QuestionOption
from scripts.seed.seed_academic import (
    classify_subtopic_key,
    ensure_engineering_math_tree,
    resolve_subtopic_id,
)

EXTRA_QUESTIONS: list[dict] = [
    {
        "stem": "Si 2x - 8 = 0, ¿cuál es el valor de x?",
        "explanation": "2x = 8 → x = 4. Respuesta B.",
        "options": [("A", "2", False), ("B", "4", True), ("C", "6", False), ("D", "8", False)],
    },
    {
        "stem": "¿Cuál es el perímetro de un cuadrado de lado 9 cm?",
        "explanation": "P = 4 × 9 = 36 cm. Respuesta C.",
        "options": [("A", "18 cm", False), ("B", "27 cm", False), ("C", "36 cm", True), ("D", "81 cm", False)],
    },
    {
        "stem": "Resuelve: x² = 49",
        "explanation": "x = ±√49 = ±7. Respuesta B.",
        "options": [("A", "x = 7", False), ("B", "x = ±7", True), ("C", "x = 49", False), ("D", "x = ±49", False)],
    },
    {
        "stem": "¿Cuál es el MCM de 6 y 8?",
        "explanation": "MCM(6,8) = 24. Respuesta B.",
        "options": [("A", "12", False), ("B", "24", True), ("C", "48", False), ("D", "2", False)],
    },
    {
        "stem": "Si un artículo cuesta S/ 80 y tiene 25% de descuento, ¿cuál es el precio final?",
        "explanation": "Descuento 25% de 80 = 20; precio final 60 soles. Respuesta B.",
        "options": [("A", "S/ 20", False), ("B", "S/ 60", True), ("C", "S/ 70", False), ("D", "S/ 55", False)],
    },
    {
        "stem": "¿Cuál es la pendiente de la recta y = 3x + 2?",
        "explanation": "En y = mx + b la pendiente es m = 3. Respuesta B.",
        "options": [("A", "2", False), ("B", "3", True), ("C", "5", False), ("D", "1/3", False)],
    },
    {
        "stem": "Un triángulo rectángulo tiene catetos 3 y 4. ¿Cuánto mide la hipotenusa?",
        "explanation": "Por Pitágoras: √(3²+4²) = 5. Respuesta A.",
        "options": [("A", "5", True), ("B", "6", False), ("C", "7", False), ("D", "12", False)],
    },
    {
        "stem": "¿Cuál es el resultado de (x + 3)(x - 3)?",
        "explanation": "Producto notable: x² − 9. Respuesta A.",
        "options": [("A", "x² - 9", True), ("B", "x² + 9", False), ("C", "x² - 6", False), ("D", "x² + 6x - 9", False)],
    },
    {
        "stem": "Si log₂(8) = x, entonces x es igual a:",
        "explanation": "2³ = 8, entonces x = 3. Respuesta B.",
        "options": [("A", "2", False), ("B", "3", True), ("C", "4", False), ("D", "8", False)],
    },
    {
        "stem": "¿Cuántos grados tiene la suma de los ángulos internos de un triángulo?",
        "explanation": "La suma de ángulos internos de un triángulo es 180°. Respuesta B.",
        "options": [("A", "90°", False), ("B", "180°", True), ("C", "270°", False), ("D", "360°", False)],
    },
    {
        "stem": "Si 5 obreros terminan una obra en 12 días, ¿cuántos días tardarán 10 obreros?",
        "explanation": "Proporción inversa: 5×12 = 10×d → d = 6 días. Respuesta B.",
        "options": [("A", "24", False), ("B", "6", True), ("C", "10", False), ("D", "4", False)],
    },
    {
        "stem": "¿Cuál es el valor de √144?",
        "explanation": "√144 = 12. Respuesta B.",
        "options": [("A", "11", False), ("B", "12", True), ("C", "14", False), ("D", "72", False)],
    },
    {
        "stem": "La ecuación de la recta que pasa por (0, 0) y (2, 4) es:",
        "explanation": "Pendiente 4/2 = 2, pasa por origen: y = 2x. Respuesta A.",
        "options": [("A", "y = 2x", True), ("B", "y = x + 2", False), ("C", "y = 4x", False), ("D", "y = x/2", False)],
    },
    {
        "stem": "¿Cuál es el volumen de un cubo de arista 3 cm?",
        "explanation": "V = 3³ = 27 cm³. Respuesta C.",
        "options": [("A", "9 cm³", False), ("B", "18 cm³", False), ("C", "27 cm³", True), ("D", "36 cm³", False)],
    },
    {
        "stem": "Si P(A) = 0.3 y P(B) = 0.5, y A y B son independientes, ¿cuál es P(A ∩ B)?",
        "explanation": "P(A∩B) = P(A)×P(B) = 0.15. Respuesta A.",
        "options": [("A", "0.15", True), ("B", "0.8", False), ("C", "0.35", False), ("D", "0.2", False)],
    },
    {
        "stem": "¿Cuál es el término general de la progresión 2, 5, 8, 11, ...?",
        "explanation": "Diferencia constante 3: aₙ = 3n − 1. Respuesta B.",
        "options": [("A", "n + 1", False), ("B", "3n - 1", True), ("C", "2n + 1", False), ("D", "n²", False)],
    },
    {
        "stem": "En una función lineal f(x) = mx + b, si m < 0 la función es:",
        "explanation": "Pendiente negativa → función decreciente. Respuesta B.",
        "options": [("A", "Creciente", False), ("B", "Decreciente", True), ("C", "Constante", False), ("D", "Cuadrática", False)],
    },
    {
        "stem": "¿Cuál es el área de un círculo de radio 5 cm? (use π ≈ 3.14)",
        "explanation": "A = πr² ≈ 3.14×25 = 78.5 cm². Respuesta B.",
        "options": [("A", "31.4 cm²", False), ("B", "78.5 cm²", True), ("C", "15.7 cm²", False), ("D", "25 cm²", False)],
    },
    {
        "stem": "Si |x - 2| = 5, ¿cuáles son los valores posibles de x?",
        "explanation": "x − 2 = 5 o x − 2 = −5 → x = 7 o x = −3. Respuesta A.",
        "options": [("A", "7 y -3", True), ("B", "7 y 3", False), ("C", "-7 y 3", False), ("D", "5 y -5", False)],
    },
    {
        "stem": "¿Cuál es la probabilidad de obtener cara al lanzar una moneda justa?",
        "explanation": "Un caso favorable de dos: 1/2. Respuesta B.",
        "options": [("A", "1/4", False), ("B", "1/2", True), ("C", "1/3", False), ("D", "2/3", False)],
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


def seed_extra_questions() -> None:
    db = SessionLocal()
    try:
        admission_id = _resolve_sis_admission_id(db)
        if admission_id is None:
            print("No hay admisión SIS. Ejecuta primero: python -m scripts.seed.seed_demo")
            return

        slug_map = ensure_engineering_math_tree(db, admission_id)
        existing_stems = {row[0] for row in db.execute(select(Question.stem)).all()}

        created = 0
        for item in EXTRA_QUESTIONS:
            if item["stem"] in existing_stems:
                continue
            subtopic_key = item.get("subtopic_key") or classify_subtopic_key(item["stem"])
            subtopic_id = resolve_subtopic_id(slug_map, subtopic_key)
            question = Question(
                subtopic_id=subtopic_id,
                stem=item["stem"],
                explanation=item.get("explanation"),
                difficulty=2,
                level=QuestionLevel.INTERMEDIATE,
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
            created += 1

        db.commit()
        total = db.scalar(select(func.count()).select_from(Question))
        print(f"Preguntas nuevas: {created}")
        print(f"Total en banco: {total}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_extra_questions()
