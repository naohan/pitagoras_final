"""Agrega purpose y focus_subtopic_id al estudiante.

Uso:
    python -m scripts.migrate.migrate_study_purpose
"""

from sqlalchemy import text

from app.database.session import SessionLocal

STATEMENTS = [
    "ALTER TABLE students ADD COLUMN purpose VARCHAR(32) NULL",
    "ALTER TABLE students ADD COLUMN focus_subtopic_id BIGINT UNSIGNED NULL",
    """
    ALTER TABLE students
      ADD CONSTRAINT fk_students_focus_subtopic
        FOREIGN KEY (focus_subtopic_id) REFERENCES subtopics (id)
        ON DELETE SET NULL ON UPDATE CASCADE
    """,
]


def _run(db, sql: str) -> None:
    try:
        db.execute(text(sql))
        db.commit()
        print("OK:", sql.strip().splitlines()[0][:90])
    except Exception as exc:
        db.rollback()
        msg = str(exc)
        if any(x in msg for x in ("1060", "1061", "1826", "Duplicate", "exists")):
            print("SKIP:", sql.strip().splitlines()[0][:90])
            return
        raise


def migrate() -> None:
    db = SessionLocal()
    try:
        for stmt in STATEMENTS:
            _run(db, stmt)
        print("Migración study_purpose lista.")
    finally:
        db.close()


if __name__ == "__main__":
    migrate()
