"""Completa el banco según matriz UNSA Ingenierías (preguntas originales).

Uso (desde backend/):
  .venv\\Scripts\\python.exe -m scripts.seed.seed_ingenierias_matrix_fill
"""

from __future__ import annotations

from sqlalchemy import func, select, text

from app.database.session import SessionLocal
from app.exams.admission_exam_specs import UNSA_MATRIX_INGENIERIAS
from app.models.academic import AdmissionProcess, Career, Subtopic, Topic, University
from app.models.enums import QuestionLevel
from app.models.question import Question, QuestionOption
from scripts.seed.seed_academic import (
    classify_subtopic_key,
    ensure_engineering_math_tree,
    resolve_subtopic_id,
)

# Preguntas originales por clave de matriz.
FILL: list[dict] = [
    # razonamiento_verbal
    {
        "matrix": "razonamiento_verbal",
        "hint": "Inferencia",
        "stem": "Sinónimo contextual de «efímero» en: «El éxito efímero no construye carrera»:",
        "explanation": "Efímero ≈ pasajero / breve.",
        "options": [("A", "Duradero", False), ("B", "Pasajero", True), ("C", "Costoso", False), ("D", "Oculto", False)],
    },
    {
        "matrix": "razonamiento_verbal",
        "hint": "Inferencia",
        "stem": "Antónimo de «abundante»:",
        "explanation": "Abundante ↔ escaso.",
        "options": [("A", "Numeroso", False), ("B", "Escaso", True), ("C", "Completo", False), ("D", "Variado", False)],
    },
    {
        "matrix": "razonamiento_verbal",
        "hint": "Inferencia",
        "stem": "Analogía: Libro es a lector como partitura es a…",
        "explanation": "Quien interpreta la partitura es el músico.",
        "options": [("A", "Autor", False), ("B", "Músico", True), ("C", "Público", False), ("D", "Escenario", False)],
    },
    {
        "matrix": "razonamiento_verbal",
        "hint": "oraciones",
        "stem": "El término excluido del grupo: mesa, silla, sofá, cama, lámpara es:",
        "explanation": "Lámpara no es mueble de asiento/descanso como el resto del grupo de mobiliario de uso corporal directo; el mejor excluido funcional suele ser lámpara (no se «usa» igual). Alternativa pedagógica: no es asiento.",
        "options": [("A", "Mesa", False), ("B", "Silla", False), ("C", "Lámpara", True), ("D", "Cama", False)],
    },
    # comprension_lectora
    {
        "matrix": "comprension_lectora",
        "hint": "Inferencia",
        "stem": "Texto: «Aunque llovía, el partido se jugó». La idea principal es:",
        "explanation": "Se jugó a pesar de la lluvia.",
        "options": [
            ("A", "Cancelaron el partido", False),
            ("B", "El partido se disputó pese a la lluvia", True),
            ("C", "No había público", False),
            ("D", "La lluvia fue intensa todo el mes", False),
        ],
    },
    {
        "matrix": "comprension_lectora",
        "hint": "Inferencia",
        "stem": "«María estudió toda la noche; por eso llegó cansada al examen». La relación entre oraciones es de:",
        "explanation": "Causa → efecto (consecuencia).",
        "options": [("A", "Oposición", False), ("B", "Causa-efecto", True), ("C", "Enumeración", False), ("D", "Comparación", False)],
    },
    {
        "matrix": "comprension_lectora",
        "hint": "argumentativos",
        "stem": "En un texto argumentativo, la tesis es:",
        "explanation": "La tesis es la idea o posición que se defiende.",
        "options": [
            ("A", "Un ejemplo aislado", False),
            ("B", "La posición que se defiende", True),
            ("C", "Solo la conclusión literaria", False),
            ("D", "El título del autor", False),
        ],
    },
    {
        "matrix": "comprension_lectora",
        "hint": "Inferencia",
        "stem": "Si un párrafo dice «sin embargo», lo más probable es que introduzca:",
        "explanation": "«Sin embargo» marca contraste/oposición.",
        "options": [("A", "Una ejemplificación", False), ("B", "Un contraste", True), ("C", "Una fecha", False), ("D", "Una definición", False)],
    },
    {
        "matrix": "comprension_lectora",
        "hint": "Inferencia",
        "stem": "Idea secundaria de un texto suele ser:",
        "explanation": "Detalles o ejemplos que apoyan la idea principal.",
        "options": [
            ("A", "El título oficial del libro", False),
            ("B", "Un detalle o ejemplo de apoyo", True),
            ("C", "La biografía del autor", False),
            ("D", "El índice completo", False),
        ],
    },
    # aritmetica / geometria / trigonometria (completar cupos)
    {
        "matrix": "aritmetica",
        "hint": "operaciones_basicas",
        "stem": "El 40% de 250 es:",
        "explanation": "0,4 × 250 = 100.",
        "options": [("A", "40", False), ("B", "100", True), ("C", "125", False), ("D", "150", False)],
    },
    {
        "matrix": "aritmetica",
        "hint": "operaciones_basicas",
        "stem": "¿Cuánto es 3/4 de 48?",
        "explanation": "(3×48)/4 = 36.",
        "options": [("A", "12", False), ("B", "24", False), ("C", "36", True), ("D", "44", False)],
    },
    {
        "matrix": "geometria",
        "hint": "geometria",
        "stem": "Un triángulo equilátero tiene perímetro 36 cm. ¿Cuánto mide cada lado?",
        "explanation": "36/3 = 12 cm.",
        "options": [("A", "9 cm", False), ("B", "12 cm", True), ("C", "18 cm", False), ("D", "36 cm", False)],
    },
    {
        "matrix": "geometria",
        "hint": "geometria",
        "stem": "El área de un cuadrado de diagonal 10√2 cm es:",
        "explanation": "d = l√2 → l = 10; A = 100.",
        "options": [("A", "50", False), ("B", "100", True), ("C", "200", False), ("D", "10", False)],
    },
    {
        "matrix": "geometria",
        "hint": "geometria",
        "stem": "En un círculo de radio 7, el diámetro mide:",
        "explanation": "Diámetro = 2r = 14.",
        "options": [("A", "7", False), ("B", "14", True), ("C", "21", False), ("D", "49", False)],
    },
    {
        "matrix": "trigonometria",
        "hint": "trigonometria",
        "stem": "cos 60° es igual a:",
        "explanation": "cos 60° = 1/2.",
        "options": [("A", "0", False), ("B", "1/2", True), ("C", "√2/2", False), ("D", "√3/2", False)],
    },
    {
        "matrix": "razonamiento_logico",
        "hint": "operaciones_basicas",
        "stem": "Si todos los A son B y algunos B son C, entonces:",
        "explanation": "No se concluye necesariamente que todos los A sean C.",
        "options": [
            ("A", "Todos los A son C", False),
            ("B", "Ningún A es C", False),
            ("C", "No se puede afirmar que todos los A sean C", True),
            ("D", "Todos los C son A", False),
        ],
    },
    {
        "matrix": "razonamiento_logico",
        "hint": "operaciones_basicas",
        "stem": "Serie: 1, 1, 2, 3, 5, 8, … El siguiente número es:",
        "explanation": "Fibonacci: 5+8=13.",
        "options": [("A", "10", False), ("B", "11", False), ("C", "13", True), ("D", "15", False)],
    },
    # historia
    {
        "matrix": "historia",
        "hint": "prehispánicas",
        "stem": "Caral es conocida como una de las civilizaciones más antiguas de:",
        "explanation": "Caral se ubica en el Perú (costa central).",
        "options": [("A", "México", False), ("B", "Perú", True), ("C", "Chile", False), ("D", "Brasil", False)],
    },
    {
        "matrix": "historia",
        "hint": "Independencia",
        "stem": "La Independencia del Perú se proclamó en Lima en el año:",
        "explanation": "1821 (proclamación de San Martín).",
        "options": [("A", "1780", False), ("B", "1821", True), ("C", "1879", False), ("D", "1924", False)],
    },
    {
        "matrix": "historia",
        "hint": "Contemporánea",
        "stem": "La Primera Guerra Mundial ocurrió principalmente entre:",
        "explanation": "1914–1918.",
        "options": [("A", "1808-1815", False), ("B", "1914-1918", True), ("C", "1939-1945", False), ("D", "2001-2003", False)],
    },
    {
        "matrix": "historia",
        "hint": "Virreinato",
        "stem": "Durante el Virreinato, Lima fue capital del:",
        "explanation": "Virreinato del Perú.",
        "options": [
            ("A", "Virreinato de Nueva España", False),
            ("B", "Virreinato del Perú", True),
            ("C", "Virreinato del Río de la Plata únicamente desde 1500", False),
            ("D", "Imperio azteca", False),
        ],
    },
    # geografia
    {
        "matrix": "geografia",
        "hint": "Relieve",
        "stem": "Las tres regiones naturales clásicas del Perú son:",
        "explanation": "Costa, sierra y selva.",
        "options": [
            ("A", "Norte, centro y sur", False),
            ("B", "Costa, sierra y selva", True),
            ("C", "Andes, Amazonas y Pacífico solo como países", False),
            ("D", "Valle, puna y desierto únicamente", False),
        ],
    },
    {
        "matrix": "geografia",
        "hint": "Relieve",
        "stem": "El río Amazonas nace en territorio asociado principalmente a:",
        "explanation": "Nace en el Perú (sistema andino / Amazonas).",
        "options": [("A", "Brasil únicamente", False), ("B", "Perú", True), ("C", "Chile", False), ("D", "Ecuador sin relación andina", False)],
    },
    {
        "matrix": "geografia",
        "hint": "Relieve",
        "stem": "Arequipa se ubica predominantemente en la región:",
        "explanation": "Arequipa es ciudad andina/sur andino (sierra).",
        "options": [("A", "Selva baja", False), ("B", "Sierra", True), ("C", "Costa norte", False), ("D", "Antártida", False)],
    },
    {
        "matrix": "geografia",
        "hint": "Relieve",
        "stem": "El clima de la costa central peruana se caracteriza, en general, por:",
        "explanation": "Influencia del Pacífico: templado/desértico costero, poca lluvia.",
        "options": [
            ("A", "Lluvias tropicales todo el año", False),
            ("B", "Escasas precipitaciones y influencia marina", True),
            ("C", "Nevadas permanentes en Lima", False),
            ("D", "Monzones asiáticos", False),
        ],
    },
    # biologia
    {
        "matrix": "biologia",
        "hint": "Celular",
        "stem": "La organela encargada de la respiración celular en eucariotas es:",
        "explanation": "Mitocondria.",
        "options": [("A", "Ribosoma", False), ("B", "Mitocondria", True), ("C", "Cloroplasto", False), ("D", "Vacuola", False)],
    },
    {
        "matrix": "biologia",
        "hint": "Fotosíntesis",
        "stem": "La fotosíntesis ocurre principalmente en:",
        "explanation": "Cloroplastos de células vegetales.",
        "options": [("A", "Mitocondrias animales", False), ("B", "Cloroplastos", True), ("C", "Lisosomas", False), ("D", "Centriolos", False)],
    },
    {
        "matrix": "biologia",
        "hint": "Ecosistemas",
        "stem": "En una cadena trófica, los productores son generalmente:",
        "explanation": "Plantas / organismos fotosintéticos.",
        "options": [("A", "Herbívoros", False), ("B", "Plantas", True), ("C", "Carnívoros", False), ("D", "Descomponedores solo", False)],
    },
    {
        "matrix": "biologia",
        "hint": "Celular",
        "stem": "El material genético en la célula eucariota se encuentra principalmente en:",
        "explanation": "Núcleo.",
        "options": [("A", "Citoplasma libre siempre", False), ("B", "Núcleo", True), ("C", "Pared celular", False), ("D", "Flagelo", False)],
    },
    {
        "matrix": "biologia",
        "hint": "Ecosistemas",
        "stem": "La biodiversidad se refiere a:",
        "explanation": "Variedad de seres vivos en un ecosistema/planeta.",
        "options": [
            ("A", "Solo el número de minerales", False),
            ("B", "La variedad de formas de vida", True),
            ("C", "La temperatura media", False),
            ("D", "La altitud del lugar", False),
        ],
    },
    # filosofia
    {
        "matrix": "filosofia",
        "hint": "Inferencia",
        "stem": "La ética se ocupa principalmente de:",
        "explanation": "El bien, la moral y la conducta humana.",
        "options": [
            ("A", "Solo la meteorología", False),
            ("B", "El estudio de lo correcto y lo incorrecto en la conducta", True),
            ("C", "La medición de longitudes", False),
            ("D", "La clasificación de rocas", False),
        ],
    },
    {
        "matrix": "filosofia",
        "hint": "Inferencia",
        "stem": "«Pienso, luego existo» se asocia históricamente a:",
        "explanation": "René Descartes.",
        "options": [("A", "Aristóteles", False), ("B", "Descartes", True), ("C", "Newton", False), ("D", "Darwin", False)],
    },
    {
        "matrix": "filosofia",
        "hint": "Inferencia",
        "stem": "La lógica estudia principalmente:",
        "explanation": "Reglas del razonamiento válido.",
        "options": [
            ("A", "Los climas del planeta", False),
            ("B", "La validez de los razonamientos", True),
            ("C", "Las corrientes oceánicas", False),
            ("D", "La tabla periódica", False),
        ],
    },
    # psicologia
    {
        "matrix": "psicologia",
        "hint": "Inferencia",
        "stem": "La memoria a corto plazo se caracteriza por:",
        "explanation": "Almacenar información de forma temporal y limitada.",
        "options": [
            ("A", "Guardar recuerdos de toda la vida sin límite", False),
            ("B", "Retener temporalmente poca información", True),
            ("C", "Solo controlar los reflejos", False),
            ("D", "Producir hormonas", False),
        ],
    },
    {
        "matrix": "psicologia",
        "hint": "Inferencia",
        "stem": "Un estímulo que provoca una respuesta automática innata se relaciona con:",
        "explanation": "Reflejo / condicionamiento clásico básico (estímulo incondicionado).",
        "options": [
            ("A", "Solo el olvido", False),
            ("B", "Un reflejo o respuesta innata", True),
            ("C", "La fotosíntesis", False),
            ("D", "La erosión", False),
        ],
    },
    {
        "matrix": "psicologia",
        "hint": "Inferencia",
        "stem": "La motivación extrínseca depende principalmente de:",
        "explanation": "Recompensas o castigos externos.",
        "options": [
            ("A", "Solo el ADN", False),
            ("B", "Incentivos externos", True),
            ("C", "La presión atmosférica", False),
            ("D", "El color de los ojos", False),
        ],
    },
    {
        "matrix": "psicologia",
        "hint": "Inferencia",
        "stem": "La atención selectiva consiste en:",
        "explanation": "Enfocarse en un estímulo e ignorar otros.",
        "options": [
            ("A", "Dormir sin estímulos", False),
            ("B", "Concentrarse en un estímulo relevante", True),
            ("C", "Olvidar todo al instante", False),
            ("D", "Repetir movimientos involuntarios", False),
        ],
    },
    # educacion civica
    {
        "matrix": "educacion_civica",
        "hint": "Normas",
        "stem": "En un Estado de derecho, las autoridades deben:",
        "explanation": "Respetar la Constitución y las leyes.",
        "options": [
            ("A", "Actuar solo por costumbre familiar", False),
            ("B", "Sujetarse a la Constitución y las leyes", True),
            ("C", "Ignorar los derechos ciudadanos", False),
            ("D", "Gobernar sin normas", False),
        ],
    },
    {
        "matrix": "educacion_civica",
        "hint": "Normas",
        "stem": "El DNI es un documento que acredita principalmente:",
        "explanation": "Identidad de la persona.",
        "options": [
            ("A", "La propiedad de un vehículo", False),
            ("B", "La identidad ciudadana", True),
            ("C", "Un título universitario", False),
            ("D", "Una licencia de caza", False),
        ],
    },
    {
        "matrix": "educacion_civica",
        "hint": "Normas",
        "stem": "La democracia se basa, entre otros principios, en:",
        "explanation": "Participación ciudadana y elección de representantes.",
        "options": [
            ("A", "La herencia obligatoria del poder", False),
            ("B", "La participación ciudadana", True),
            ("C", "La censura total de opiniones", False),
            ("D", "La eliminación del voto", False),
        ],
    },
    # lenguaje
    {
        "matrix": "lenguaje",
        "hint": "gramaticales",
        "stem": "En la oración «Los estudiantes leen el informe», el sujeto es:",
        "explanation": "«Los estudiantes».",
        "options": [("A", "leen", False), ("B", "Los estudiantes", True), ("C", "el informe", False), ("D", "Los", False)],
    },
    {
        "matrix": "lenguaje",
        "hint": "gramaticales",
        "stem": "La palabra «rápidamente» funciona como:",
        "explanation": "Adverbio (modifica al verbo).",
        "options": [("A", "Sustantivo", False), ("B", "Adjetivo", False), ("C", "Adverbio", True), ("D", "Preposición", False)],
    },
    {
        "matrix": "lenguaje",
        "hint": "gramaticales",
        "stem": "Se escribe con tilde la palabra:",
        "explanation": "«cáncer» es palabra grave terminada en consonante distinta de n/s; lleva tilde.",
        "options": [("A", "cancer (sin tilde)", False), ("B", "cáncer", True), ("C", "cancér", False), ("D", "càncer", False)],
    },
    {
        "matrix": "lenguaje",
        "hint": "gramaticales",
        "stem": "El plural de «el lápiz» es:",
        "explanation": "Los lápices.",
        "options": [("A", "Los lápizs", False), ("B", "Los lápices", True), ("C", "Los lápizes", False), ("D", "Los lapiz", False)],
    },
    # literatura
    {
        "matrix": "literatura",
        "hint": "Literatura",
        "stem": "«Los ríos profundos» es una novela asociada a:",
        "explanation": "José María Arguedas.",
        "options": [("A", "Vargas Llosa", False), ("B", "José María Arguedas", True), ("C", "Cervantes", False), ("D", "Neruda", False)],
    },
    {
        "matrix": "literatura",
        "hint": "Literatura",
        "stem": "El género literario de «Romeo y Julieta» es principalmente:",
        "explanation": "Drama / teatro.",
        "options": [("A", "Ensayo científico", False), ("B", "Drama teatral", True), ("C", "Crónica deportiva", False), ("D", "Manual técnico", False)],
    },
    {
        "matrix": "literatura",
        "hint": "Literatura",
        "stem": "Un soneto clásico suele tener:",
        "explanation": "14 versos.",
        "options": [("A", "8 versos", False), ("B", "14 versos", True), ("C", "20 versos", False), ("D", "3 versos", False)],
    },
    # ingles
    {
        "matrix": "lengua_extranjera_lectura",
        "hint": "Short texts",
        "stem": "Read: «The library opens at 8 a.m.» The library opens:",
        "explanation": "At 8 in the morning.",
        "options": [("A", "At night", False), ("B", "At 8 a.m.", True), ("C", "At noon only", False), ("D", "Never", False)],
    },
    {
        "matrix": "lengua_extranjera_lectura",
        "hint": "Short texts",
        "stem": "«She is a doctor» means she:",
        "explanation": "Works as a doctor / is a physician.",
        "options": [("A", "Is a student only", False), ("B", "Works as a doctor", True), ("C", "Is a building", False), ("D", "Is sleeping", False)],
    },
    {
        "matrix": "lengua_extranjera_gramatica",
        "hint": "Short texts",
        "stem": "Choose the correct form: «They ___ students.»",
        "explanation": "Plural → are.",
        "options": [("A", "is", False), ("B", "are", True), ("C", "am", False), ("D", "be", False)],
    },
    {
        "matrix": "lengua_extranjera_gramatica",
        "hint": "Short texts",
        "stem": "Past of «go» is:",
        "explanation": "went.",
        "options": [("A", "goed", False), ("B", "went", True), ("C", "goneed", False), ("D", "going", False)],
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


def _find_subtopic(db, hint: str) -> int | None:
    hint_l = hint.lower()
    return db.scalar(
        select(Subtopic.id)
        .join(Topic)
        .where(Subtopic.is_active.is_(True))
        .where((Subtopic.name.ilike(f"%{hint_l}%")) | (Topic.name.ilike(f"%{hint_l}%")))
        .limit(1)
    )


def _matrix_counts(db) -> dict[str, int]:
    rows = db.execute(
        text(
            """
            SELECT JSON_UNQUOTE(JSON_EXTRACT(tags, '$.matrix')) AS m, COUNT(*) AS c
            FROM questions
            WHERE is_active = 1 AND tags IS NOT NULL
              AND JSON_EXTRACT(tags, '$.matrix') IS NOT NULL
            GROUP BY m
            """
        )
    ).all()
    return {str(m): int(c) for m, c in rows if m}


def seed_matrix_fill() -> None:
    db = SessionLocal()
    try:
        admission_id = _resolve_sis_admission_id(db)
        if admission_id is None:
            print("No hay admisión SIS.")
            return

        slug_map = ensure_engineering_math_tree(db, admission_id)
        existing = {row[0] for row in db.execute(select(Question.stem)).all()}
        counts = _matrix_counts(db)

        created = 0
        skipped_enough = 0
        for item in FILL:
            matrix = item["matrix"]
            target = UNSA_MATRIX_INGENIERIAS.get(matrix)
            # Para claves no exactas en matriz (p.ej. aritmetica), no limitar por cupo estricto.
            if target is not None and counts.get(matrix, 0) >= target + 2:
                skipped_enough += 1
                continue
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
                subtopic_id = _find_subtopic(db, hint)
                if subtopic_id is None:
                    subtopic_id = resolve_subtopic_id(
                        slug_map, classify_subtopic_key(item["stem"])
                    )

            q = Question(
                subtopic_id=subtopic_id,
                stem=item["stem"],
                explanation=item.get("explanation"),
                difficulty=3,
                level=QuestionLevel.INTERMEDIATE,
                avg_time_seconds=90,
                tags={
                    "matrix": matrix,
                    "area": "ingenierias",
                    "source": "original_pitagoras",
                },
                is_active=True,
            )
            db.add(q)
            db.flush()
            for order, (label, text_opt, ok) in enumerate(item["options"], start=1):
                db.add(
                    QuestionOption(
                        question_id=q.id,
                        label=label,
                        text=text_opt,
                        is_correct=ok,
                        display_order=order,
                    )
                )
            created += 1
            existing.add(item["stem"])
            counts[matrix] = counts.get(matrix, 0) + 1

        db.commit()
        total = db.scalar(
            select(func.count()).select_from(Question).where(Question.is_active.is_(True))
        )
        print(f"Nuevas: {created} | omitidas por cupo: {skipped_enough}")
        print(f"Total activas: {total}")
        print("Cobertura matriz (tags):")
        for key, need in UNSA_MATRIX_INGENIERIAS.items():
            have = counts.get(key, 0)
            mark = "OK" if have >= need else f"falta {need - have}"
            print(f"  {key}: {have}/{need} {mark}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_matrix_fill()
