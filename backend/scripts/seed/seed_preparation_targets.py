"""Seed modalidades de postulación + cutoffs por carrera (diseño del frontend).

Uso:
    python -m scripts.migrate.migrate_preparation_profile
    python -m scripts.seed.seed_preparation_targets
"""

from __future__ import annotations

from decimal import Decimal

from sqlalchemy import select

from app.database.session import SessionLocal
from app.models.academic import Career, University
from app.models.admission_exam_target import AdmissionExamTarget

# university_code → list of targets
TARGETS: dict[str, list[dict]] = {
    "UNSA": [
        {
            "code": "quinto",
            "label": "Quinto UNSA",
            "short_label": "Quinto",
            "description": "Ingreso anticipado para estudiantes de quinto de secundaria.",
            "simulacro_focus": "Simulacros orientados al examen Quinto UNSA.",
            "display_order": 1,
        },
        {
            "code": "cepreunsa",
            "label": "CEPREUNSA",
            "short_label": "CEPREUNSA",
            "description": "Centro Preuniversitario de la UNSA — ruta de preparación intensiva.",
            "simulacro_focus": "Simulacros alineados al estilo CEPREUNSA.",
            "display_order": 2,
        },
        {
            "code": "ordinario",
            "label": "Ordinario UNSA",
            "short_label": "Ordinario",
            "description": "Examen de admisión ordinario para todas las carreras de ingeniería.",
            "simulacro_focus": "Simulacros tipo examen Ordinario UNSA (20 preguntas variadas).",
            "display_order": 3,
        },
    ],
    "UCSM": [
        {
            "code": "ordinario",
            "label": "Ordinario UCSM",
            "short_label": "Ordinario",
            "description": "Examen de admisión ordinario UCSM para aspirantes de colegio.",
            "simulacro_focus": "Simulacros alineados al prospecto / balotario UCSM.",
            "display_order": 1,
        },
        {
            "code": "cepre",
            "label": "Preuniversitario UCSM",
            "short_label": "CEPRE",
            "description": "Ruta de preparación preuniversitaria UCSM.",
            "simulacro_focus": "Simulacros estilo centro preuniversitario UCSM.",
            "display_order": 2,
        },
    ],
}

# career_code defaults by university (target / min / max)
CAREER_SCORES: dict[str, dict[str, tuple[str, str, str]]] = {
    "UNSA": {
        "SIS": ("72.50", "55.00", "85.00"),
        "CIV": ("70.00", "52.00", "82.00"),
    },
    "UCSM": {
        "SIS": ("68.00", "50.00", "80.00"),
    },
}


def _ensure_target(db, university_id: int, data: dict) -> None:
    stmt = select(AdmissionExamTarget).where(
        AdmissionExamTarget.university_id == university_id,
        AdmissionExamTarget.code == data["code"],
    )
    existing = db.scalars(stmt).first()
    if existing is None:
        db.add(
            AdmissionExamTarget(
                university_id=university_id,
                code=data["code"],
                label=data["label"],
                short_label=data["short_label"],
                description=data["description"],
                simulacro_focus=data["simulacro_focus"],
                display_order=data["display_order"],
                is_active=True,
            )
        )
        return
    existing.label = data["label"]
    existing.short_label = data["short_label"]
    existing.description = data["description"]
    existing.simulacro_focus = data["simulacro_focus"]
    existing.display_order = data["display_order"]
    existing.is_active = True


def seed() -> None:
    db = SessionLocal()
    try:
        universities = list(db.scalars(select(University)).all())
        by_code = {u.code.upper(): u for u in universities}

        for uni_code, targets in TARGETS.items():
            uni = by_code.get(uni_code)
            if uni is None:
                print(f"Universidad {uni_code} no encontrada, se omite.")
                continue
            for target in targets:
                _ensure_target(db, uni.id, target)
            print(f"  {uni_code}: {len(targets)} modalidades")

            scores = CAREER_SCORES.get(uni_code, {})
            careers = list(
                db.scalars(select(Career).where(Career.university_id == uni.id)).all()
            )
            for career in careers:
                values = scores.get(career.code)
                if not values:
                    continue
                target, lo, hi = values
                career.target_score = Decimal(target)
                career.score_min = Decimal(lo)
                career.score_max = Decimal(hi)

        db.commit()
        print("Seed preparation targets / cutoffs listo.")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed()
