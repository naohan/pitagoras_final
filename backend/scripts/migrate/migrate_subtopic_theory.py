"""Migración: teoría pedagógica por subtema (subtopics.theory_text)."""

from __future__ import annotations

from sqlalchemy import text

from app.database.session import SessionLocal

SQL = """
ALTER TABLE subtopics
  ADD COLUMN theory_text MEDIUMTEXT NULL
  AFTER name
"""


def migrate() -> None:
    db = SessionLocal()
    try:
        cols = {
            row[0]
            for row in db.execute(text("SHOW COLUMNS FROM subtopics")).all()
        }
        if "theory_text" in cols:
            print("OK: subtopics.theory_text ya existe")
            return
        db.execute(text(SQL))
        db.commit()
        print("OK: agregada subtopics.theory_text")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    migrate()
