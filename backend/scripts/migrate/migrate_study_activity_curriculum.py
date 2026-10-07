"""Crea tablas study_activities y curriculum_mappings.

Uso (desde backend/):
    python -m scripts.migrate.migrate_study_activity_curriculum
"""

from sqlalchemy import text

from app.database.session import SessionLocal


STUDY_ACTIVITIES_SQL = """
CREATE TABLE IF NOT EXISTS study_activities (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    activity_type ENUM('exam','flashcards','pomodoro','material','motivator') NOT NULL,
    activity_date DATE NOT NULL,
    ref_id VARCHAR(64) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_study_activities_student_type_date_ref
        (student_id, activity_type, activity_date, ref_id),
    KEY idx_study_activities_student_date (student_id, activity_date),
    CONSTRAINT fk_study_activities_student
        FOREIGN KEY (student_id) REFERENCES students (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
"""

CURRICULUM_MAPPINGS_SQL = """
CREATE TABLE IF NOT EXISTS curriculum_mappings (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subtopic_id BIGINT UNSIGNED NOT NULL,
    framework ENUM('admission_temario','cneb_secundaria') NOT NULL,
    external_code VARCHAR(64) NOT NULL,
    external_label VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_curriculum_mappings_subtopic_framework_code
        (subtopic_id, framework, external_code),
    KEY idx_curriculum_mappings_subtopic_id (subtopic_id),
    KEY idx_curriculum_mappings_framework (framework),
    CONSTRAINT fk_curriculum_mappings_subtopic
        FOREIGN KEY (subtopic_id) REFERENCES subtopics (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
"""


def migrate() -> None:
    db = SessionLocal()
    try:
        db.execute(text(STUDY_ACTIVITIES_SQL))
        db.execute(text(CURRICULUM_MAPPINGS_SQL))
        db.commit()
        print("Tablas study_activities y curriculum_mappings listas.")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    migrate()
