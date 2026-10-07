"""Agrega columna is_saved a student_answers (guardar para repasar).

Uso (desde backend/):
    python -m scripts.migrate.migrate_add_is_saved
"""

from sqlalchemy import text

from app.database.session import SessionLocal


def migrate() -> None:
    db = SessionLocal()
    try:
        db.execute(
            text(
                "ALTER TABLE student_answers "
                "ADD COLUMN is_saved BOOLEAN NOT NULL DEFAULT FALSE"
            )
        )
        db.commit()
        print("Columna is_saved lista en student_answers.")
    except Exception as exc:
        db.rollback()
        # MySQL < 8 no soporta IF NOT EXISTS en ADD COLUMN
        if "Duplicate column" in str(exc) or "1060" in str(exc):
            print("Columna is_saved ya existe.")
            return
        raise
    finally:
        db.close()


if __name__ == "__main__":
    migrate()
