"""Banco original para área Ingenierías (temario/matriz, sin clonar exámenes).

Prioridad: Física, Química, Raz. matemático / aritmética, Álgebra.
Uso (desde backend/):
  .venv\\Scripts\\python.exe -m scripts.seed.seed_ingenierias_bank
"""

from __future__ import annotations

from sqlalchemy import func, select

from app.database.session import SessionLocal
from app.models.academic import AdmissionProcess, Career, Subtopic, Topic, University
from app.models.enums import QuestionLevel
from app.models.question import Question, QuestionOption
from scripts.seed.seed_academic import (
    classify_subtopic_key,
    ensure_engineering_math_tree,
    resolve_subtopic_id,
)

# (stem, explanation, options, matrix_tag, subtopic_hint)
# subtopic_hint: slug math tree OR topic keyword for science lookup
BANK: list[dict] = [
    # --- Física (MRU / MRUV / fuerzas) ---
    {
        "matrix": "fisica",
        "hint": "MRU",
        "stem": "Un móvil se desplaza en línea recta a 12 m/s constantes. ¿Qué distancia recorre en 5 s?",
        "explanation": "MRU: d = v·t = 12×5 = 60 m.",
        "options": [("A", "17 m", False), ("B", "60 m", True), ("C", "2,4 m", False), ("D", "120 m", False)],
    },
    {
        "matrix": "fisica",
        "hint": "MRUV",
        "stem": "Un auto parte del reposo con aceleración constante de 2 m/s². ¿Cuál es su velocidad a los 4 s?",
        "explanation": "v = v0 + a·t = 0 + 2×4 = 8 m/s.",
        "options": [("A", "4 m/s", False), ("B", "6 m/s", False), ("C", "8 m/s", True), ("D", "16 m/s", False)],
    },
    {
        "matrix": "fisica",
        "hint": "MRUV",
        "stem": "Un cuerpo cae libremente desde el reposo. Si g = 10 m/s², ¿cuánto cae en los primeros 3 s? (sin resistencia del aire)",
        "explanation": "d = (1/2)gt² = 0,5×10×9 = 45 m.",
        "options": [("A", "15 m", False), ("B", "30 m", False), ("C", "45 m", True), ("D", "90 m", False)],
    },
    {
        "matrix": "fisica",
        "hint": "fuerzas",
        "stem": "Sobre un bloque de 5 kg actúa una fuerza neta horizontal de 20 N. ¿Cuál es su aceleración? (ignora fricción)",
        "explanation": "a = F/m = 20/5 = 4 m/s².",
        "options": [("A", "0,25 m/s²", False), ("B", "4 m/s²", True), ("C", "100 m/s²", False), ("D", "25 m/s²", False)],
    },
    {
        "matrix": "fisica",
        "hint": "fuerzas",
        "stem": "El peso de un cuerpo de 8 kg en la Tierra (g = 10 m/s²) es aproximadamente:",
        "explanation": "P = m·g = 8×10 = 80 N.",
        "options": [("A", "8 N", False), ("B", "18 N", False), ("C", "80 N", True), ("D", "800 N", False)],
    },
    {
        "matrix": "fisica",
        "hint": "MRU",
        "stem": "Dos ciclistas parten juntos: uno a 6 m/s y otro a 8 m/s en la misma dirección. ¿Cuánto se separan en 10 s?",
        "explanation": "Separación = (8−6)×10 = 20 m.",
        "options": [("A", "14 m", False), ("B", "20 m", True), ("C", "80 m", False), ("D", "2 m", False)],
    },
    {
        "matrix": "fisica",
        "hint": "MRUV",
        "stem": "Un móvil pasa de 10 m/s a 22 m/s en 4 s con aceleración constante. ¿Cuál es esa aceleración?",
        "explanation": "a = (22−10)/4 = 3 m/s².",
        "options": [("A", "2 m/s²", False), ("B", "3 m/s²", True), ("C", "4 m/s²", False), ("D", "12 m/s²", False)],
    },
    {
        "matrix": "fisica",
        "hint": "fuerzas",
        "stem": "Si la fuerza neta sobre un cuerpo se triplica y la masa se mantiene, la aceleración:",
        "explanation": "a = F/m → si F×3, a×3.",
        "options": [("A", "Se divide entre 3", False), ("B", "Se mantiene", False), ("C", "Se triplica", True), ("D", "Se eleva al cubo", False)],
    },
    # --- Química ---
    {
        "matrix": "quimica",
        "hint": "átomo",
        "stem": "Un átomo neutro tiene 11 protones. ¿Cuántos electrones tiene?",
        "explanation": "En un átomo neutro: electrones = protones = 11.",
        "options": [("A", "1", False), ("B", "11", True), ("C", "12", False), ("D", "22", False)],
    },
    {
        "matrix": "quimica",
        "hint": "átomo",
        "stem": "El número másico de un isótopo es 23 y tiene 11 protones. ¿Cuántos neutrones tiene?",
        "explanation": "Neutrones = A − Z = 23 − 11 = 12.",
        "options": [("A", "11", False), ("B", "12", True), ("C", "23", False), ("D", "34", False)],
    },
    {
        "matrix": "quimica",
        "hint": "enlace",
        "stem": "El enlace que se forma por transferencia de electrones entre un metal y un no metal se denomina:",
        "explanation": "Transferencia de electrones → enlace iónico.",
        "options": [("A", "Covalente", False), ("B", "Metálico", False), ("C", "Iónico", True), ("D", "Puente de hidrógeno", False)],
    },
    {
        "matrix": "quimica",
        "hint": "pH",
        "stem": "Una solución acuosa con pH = 3 se clasifica como:",
        "explanation": "pH < 7 → ácida.",
        "options": [("A", "Neutra", False), ("B", "Básica", False), ("C", "Ácida", True), ("D", "Salina únicamente", False)],
    },
    {
        "matrix": "quimica",
        "hint": "átomo",
        "stem": "En la tabla periódica, los elementos de un mismo grupo suelen compartir:",
        "explanation": "Mismo grupo → propiedades químicas similares (misma familia).",
        "options": [
            ("A", "El mismo número de neutrones", False),
            ("B", "Propiedades químicas similares", True),
            ("C", "El mismo número másico", False),
            ("D", "La misma densidad", False),
        ],
    },
    {
        "matrix": "quimica",
        "hint": "enlace",
        "stem": "La molécula de agua (H₂O) se forma principalmente por enlace:",
        "explanation": "H y O son no metales: enlace covalente.",
        "options": [("A", "Iónico", False), ("B", "Covalente", True), ("C", "Metálico", False), ("D", "Iónico puro de sodio", False)],
    },
    {
        "matrix": "quimica",
        "hint": "pH",
        "stem": "Si el pH de una solución pasa de 5 a 7, la acidez:",
        "explanation": "Sube el pH hacia 7 → disminuye la acidez (se vuelve menos ácida / neutra).",
        "options": [("A", "Aumenta", False), ("B", "Disminuye", True), ("C", "No cambia", False), ("D", "Se duplica necesariamente", False)],
    },
    {
        "matrix": "quimica",
        "hint": "átomo",
        "stem": "¿Cuál es la partícula subatómica con carga negativa?",
        "explanation": "El electrón tiene carga negativa.",
        "options": [("A", "Protón", False), ("B", "Neutrón", False), ("C", "Electrón", True), ("D", "Núcleo completo", False)],
    },
    # --- Álgebra ---
    {
        "matrix": "algebra",
        "hint": "ecuaciones",
        "stem": "Resuelve: 3x − 7 = 8",
        "explanation": "3x = 15 → x = 5.",
        "options": [("A", "x = 3", False), ("B", "x = 5", True), ("C", "x = 15", False), ("D", "x = −5", False)],
    },
    {
        "matrix": "algebra",
        "hint": "ecuaciones",
        "stem": "El sistema {x + y = 10 ; x − y = 2} tiene solución:",
        "explanation": "Sumando: 2x = 12 → x = 6; y = 4.",
        "options": [("A", "(5, 5)", False), ("B", "(6, 4)", True), ("C", "(8, 2)", False), ("D", "(4, 6)", False)],
    },
    {
        "matrix": "algebra",
        "hint": "funciones",
        "stem": "Si f(x) = 2x − 1, entonces f(4) es:",
        "explanation": "f(4) = 8 − 1 = 7.",
        "options": [("A", "6", False), ("B", "7", True), ("C", "8", False), ("D", "9", False)],
    },
    {
        "matrix": "algebra",
        "hint": "ecuaciones",
        "stem": "Factoriza: x² − 16",
        "explanation": "Diferencia de cuadrados: (x − 4)(x + 4).",
        "options": [("A", "(x − 8)(x + 2)", False), ("B", "(x − 4)(x + 4)", True), ("C", "(x − 4)²", False), ("D", "x(x − 16)", False)],
    },
    {
        "matrix": "algebra",
        "hint": "ecuaciones",
        "stem": "La solución de 2(x + 3) = x + 9 es:",
        "explanation": "2x + 6 = x + 9 → x = 3.",
        "options": [("A", "x = 1", False), ("B", "x = 3", True), ("C", "x = 6", False), ("D", "x = 9", False)],
    },
    {
        "matrix": "algebra",
        "hint": "funciones",
        "stem": "La función f(x) = −x + 5 es:",
        "explanation": "Pendiente negativa → decreciente.",
        "options": [("A", "Creciente", False), ("B", "Decreciente", True), ("C", "Constante", False), ("D", "Cuadrática", False)],
    },
    {
        "matrix": "algebra",
        "hint": "ecuaciones",
        "stem": "Si 5x = 2x + 18, entonces x vale:",
        "explanation": "3x = 18 → x = 6.",
        "options": [("A", "3", False), ("B", "6", True), ("C", "9", False), ("D", "18", False)],
    },
    {
        "matrix": "algebra",
        "hint": "ecuaciones",
        "stem": "La inecuación 2x + 1 > 7 se cumple para:",
        "explanation": "2x > 6 → x > 3.",
        "options": [("A", "x < 3", False), ("B", "x > 3", True), ("C", "x = 3", False), ("D", "x ≤ 3", False)],
    },
    # --- Razonamiento matemático / aritmética ---
    {
        "matrix": "razonamiento_matematico",
        "hint": "proporcionalidad",
        "stem": "Si 4 cuadernos cuestan S/ 28, ¿cuánto cuestan 7 cuadernos al mismo precio unitario?",
        "explanation": "Unitario 7 soles; 7×7 = 49.",
        "options": [("A", "S/ 42", False), ("B", "S/ 49", True), ("C", "S/ 56", False), ("D", "S/ 35", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "proporcionalidad",
        "stem": "Un producto de S/ 200 tiene 15% de descuento. ¿Cuál es el precio final?",
        "explanation": "15% de 200 = 30; final = 170.",
        "options": [("A", "S/ 150", False), ("B", "S/ 170", True), ("C", "S/ 185", False), ("D", "S/ 215", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "operaciones_basicas",
        "stem": "El siguiente término de la sucesión 3, 6, 12, 24, … es:",
        "explanation": "Cada término se multiplica por 2 → 48.",
        "options": [("A", "36", False), ("B", "48", True), ("C", "30", False), ("D", "42", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "divisibilidad_analogias",
        "stem": "¿Cuál es el MCD de 18 y 24?",
        "explanation": "MCD(18,24) = 6.",
        "options": [("A", "3", False), ("B", "6", True), ("C", "12", False), ("D", "72", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "operaciones_basicas",
        "stem": "Calcula: 15% de 80 + 10% de 50",
        "explanation": "12 + 5 = 17.",
        "options": [("A", "15", False), ("B", "17", True), ("C", "20", False), ("D", "25", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "proporcionalidad",
        "stem": "Una cisterna se llena en 6 horas con 2 llaves iguales. ¿Cuántas horas tardaría 3 llaves iguales?",
        "explanation": "Trabajo inverso: 2×6 = 3×t → t = 4 h.",
        "options": [("A", "3 h", False), ("B", "4 h", True), ("C", "9 h", False), ("D", "2 h", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "operaciones_basicas",
        "stem": "Si hoy es jueves, ¿qué día será dentro de 100 días?",
        "explanation": "100 ≡ 2 (mód 7) → sábado.",
        "options": [("A", "Viernes", False), ("B", "Sábado", True), ("C", "Domingo", False), ("D", "Lunes", False)],
    },
    {
        "matrix": "razonamiento_matematico",
        "hint": "geometria",
        "stem": "Un rectángulo mide 8 m de largo y 5 m de ancho. ¿Cuál es su área?",
        "explanation": "A = 8×5 = 40 m².",
        "options": [("A", "13 m²", False), ("B", "26 m²", False), ("C", "40 m²", True), ("D", "80 m²", False)],
    },
    {
        "matrix": "razonamiento_logico",
        "hint": "divisibilidad_analogias",
        "stem": "Completa la analogía: 2 es a 8 como 3 es a …",
        "explanation": "2³ = 8; 3³ = 27.",
        "options": [("A", "9", False), ("B", "12", False), ("C", "27", True), ("D", "6", False)],
    },
    {
        "matrix": "razonamiento_logico",
        "hint": "operaciones_basicas",
        "stem": "En una fila, Ana es la 4.ª desde adelante y la 7.ª desde atrás. ¿Cuántas personas hay?",
        "explanation": "4 + 7 − 1 = 10.",
        "options": [("A", "10", True), ("B", "11", False), ("C", "12", False), ("D", "9", False)],
    },
    {
        "matrix": "trigonometria",
        "hint": "trigonometria",
        "stem": "En un triángulo rectángulo, si un cateto mide 3 y la hipotenusa 5, el otro cateto mide:",
        "explanation": "√(25−9) = 4.",
        "options": [("A", "2", False), ("B", "4", True), ("C", "6", False), ("D", "8", False)],
    },
    {
        "matrix": "trigonometria",
        "hint": "trigonometria",
        "stem": "sen 30° es igual a:",
        "explanation": "sen 30° = 1/2.",
        "options": [("A", "0", False), ("B", "1/2", True), ("C", "√2/2", False), ("D", "√3/2", False)],
    },
    {
        "matrix": "geometria",
        "hint": "geometria",
        "stem": "La suma de los ángulos internos de un cuadrilátero convexo es:",
        "explanation": "(4−2)×180° = 360°.",
        "options": [("A", "180°", False), ("B", "270°", False), ("C", "360°", True), ("D", "540°", False)],
    },
    {
        "matrix": "aritmetica",
        "hint": "operaciones_basicas",
        "stem": "¿Cuál es el valor de 2⁴ − 3²?",
        "explanation": "16 − 9 = 7.",
        "options": [("A", "5", False), ("B", "7", True), ("C", "10", False), ("D", "13", False)],
    },
    {
        "matrix": "aritmetica",
        "hint": "operaciones_basicas",
        "stem": "Simplifica: √(81/9)",
        "explanation": "√9 = 3.",
        "options": [("A", "3", True), ("B", "9", False), ("C", "27", False), ("D", "1/3", False)],
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


def _find_science_subtopic(db, hint: str) -> int | None:
    hint_l = hint.lower()
    stmt = (
        select(Subtopic.id)
        .join(Topic)
        .where(Subtopic.is_active.is_(True))
        .where(
            (Subtopic.name.ilike(f"%{hint_l}%"))
            | (Topic.name.ilike(f"%{hint_l}%"))
        )
        .limit(1)
    )
    return db.scalar(stmt)


def seed_ingenierias_bank() -> None:
    db = SessionLocal()
    try:
        admission_id = _resolve_sis_admission_id(db)
        if admission_id is None:
            print("No hay admisión SIS. Ejecuta seed_demo primero.")
            return

        slug_map = ensure_engineering_math_tree(db, admission_id)
        existing = {row[0] for row in db.execute(select(Question.stem)).all()}

        created = 0
        for item in BANK:
            if item["stem"] in existing:
                continue

            hint = item.get("hint") or ""
            math_keys = {
                "ecuaciones",
                "funciones",
                "proporcionalidad",
                "operaciones_basicas",
                "divisibilidad_analogias",
                "geometria",
                "trigonometria",
                "probabilidad",
                "estadistica",
                "general",
            }
            if hint in math_keys:
                subtopic_id = resolve_subtopic_id(slug_map, hint)
            else:
                science_id = _find_science_subtopic(db, hint)
                if science_id is not None:
                    subtopic_id = science_id
                else:
                    key = classify_subtopic_key(item["stem"])
                    subtopic_id = resolve_subtopic_id(slug_map, key)

            question = Question(
                subtopic_id=subtopic_id,
                stem=item["stem"],
                explanation=item.get("explanation"),
                difficulty=3,
                level=QuestionLevel.INTERMEDIATE,
                avg_time_seconds=90,
                tags={
                    "matrix": item["matrix"],
                    "area": "ingenierias",
                    "source": "original_pitagoras",
                },
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
            existing.add(item["stem"])

        db.commit()
        total = db.scalar(select(func.count()).select_from(Question).where(Question.is_active.is_(True)))
        print(f"Preguntas nuevas: {created}")
        print(f"Total activas: {total}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_ingenierias_bank()
