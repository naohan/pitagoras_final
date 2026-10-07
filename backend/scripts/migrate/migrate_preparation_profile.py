"""Migra perfil de preparación, cutoffs de carrera y modalidades de examen.

Uso (desde backend/):
    python -m scripts.migrate.migrate_preparation_profile
"""

from sqlalchemy import text

from app.database.session import SessionLocal

STATEMENTS = [
    """
    ALTER TABLE careers
      ADD COLUMN target_score DECIMAL(5,2) NULL,
      ADD COLUMN score_min DECIMAL(5,2) NULL,
      ADD COLUMN score_max DECIMAL(5,2) NULL
    """,
    """
    ALTER TABLE students
      ADD COLUMN university_id BIGINT UNSIGNED NULL,
      ADD COLUMN career_id BIGINT UNSIGNED NULL,
      ADD COLUMN admission_process_id BIGINT UNSIGNED NULL,
      ADD COLUMN exam_target_code VARCHAR(40) NULL
    """,
    """
    CREATE TABLE IF NOT EXISTS admission_exam_targets (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      university_id BIGINT UNSIGNED NOT NULL,
      code VARCHAR(40) NOT NULL,
      label VARCHAR(100) NOT NULL,
      short_label VARCHAR(40) NOT NULL,
      description TEXT NOT NULL,
      simulacro_focus TEXT NOT NULL,
      display_order SMALLINT NOT NULL DEFAULT 0,
      is_active TINYINT(1) NOT NULL DEFAULT 1,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uq_admission_exam_targets_uni_code (university_id, code),
      KEY idx_admission_exam_targets_university_id (university_id),
      CONSTRAINT fk_admission_exam_targets_university
        FOREIGN KEY (university_id) REFERENCES universities (id)
        ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """,
    """
    ALTER TABLE students
      ADD CONSTRAINT fk_students_university
        FOREIGN KEY (university_id) REFERENCES universities (id)
        ON DELETE SET NULL ON UPDATE CASCADE
    """,
    """
    ALTER TABLE students
      ADD CONSTRAINT fk_students_career
        FOREIGN KEY (career_id) REFERENCES careers (id)
        ON DELETE SET NULL ON UPDATE CASCADE
    """,
    """
    ALTER TABLE students
      ADD CONSTRAINT fk_students_admission_process
        FOREIGN KEY (admission_process_id) REFERENCES admission_processes (id)
        ON DELETE SET NULL ON UPDATE CASCADE
    """,
]


def _run(db, sql: str) -> None:
    try:
        db.execute(text(sql))
        db.commit()
        print("OK:", sql.strip().splitlines()[0][:80])
    except Exception as exc:
        db.rollback()
        msg = str(exc)
        if any(code in msg for code in ("1060", "1061", "1091", "1826", "Duplicate", "exists")):
            print("SKIP (ya existe):", sql.strip().splitlines()[0][:80])
            return
        raise


def migrate() -> None:
    db = SessionLocal()
    try:
        for stmt in STATEMENTS:
            _run(db, stmt)
        print("Migración preparation_profile lista.")
    finally:
        db.close()


if __name__ == "__main__":
    migrate()
