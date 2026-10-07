-- Pitágoras — DDL de referencia (MySQL 8.x)
-- Diseño relacional Etapa 0.2. No ejecutar en producción sin revisar con Alembic.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------------
-- Catálogo académico (KGAA Nivel 1)
-- ---------------------------------------------------------------------------

CREATE TABLE universities (
    id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code        VARCHAR(20)     NOT NULL,
    name        VARCHAR(150)    NOT NULL,
    country     VARCHAR(60)     NOT NULL DEFAULT 'PE',
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_universities_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE careers (
    id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    university_id  BIGINT UNSIGNED NOT NULL,
    code           VARCHAR(30)     NOT NULL,
    name           VARCHAR(150)    NOT NULL,
    is_active      BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_careers_university_code (university_id, code),
    KEY idx_careers_university_id (university_id),
    CONSTRAINT fk_careers_university
        FOREIGN KEY (university_id) REFERENCES universities (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admission_processes (
    id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    career_id   BIGINT UNSIGNED NOT NULL,
    name        VARCHAR(100)    NOT NULL,
    year        SMALLINT UNSIGNED NOT NULL,
    description TEXT            NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_admission_processes_career_year (career_id, year),
    KEY idx_admission_processes_career_id (career_id),
    CONSTRAINT fk_admission_processes_career
        FOREIGN KEY (career_id) REFERENCES careers (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE areas (
    id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_process_id  BIGINT UNSIGNED NOT NULL,
    name                  VARCHAR(100)    NOT NULL,
    weight_percent        DECIMAL(5,2)    NOT NULL,
    display_order         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    is_active             BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_areas_process_name (admission_process_id, name),
    KEY idx_areas_admission_process_id (admission_process_id),
    CONSTRAINT fk_areas_admission_process
        FOREIGN KEY (admission_process_id) REFERENCES admission_processes (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_areas_weight_percent
        CHECK (weight_percent >= 0 AND weight_percent <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE components (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    area_id       BIGINT UNSIGNED NOT NULL,
    name          VARCHAR(100)    NOT NULL,
    display_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_components_area_name (area_id, name),
    KEY idx_components_area_id (area_id),
    CONSTRAINT fk_components_area
        FOREIGN KEY (area_id) REFERENCES areas (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE topics (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    component_id  BIGINT UNSIGNED NOT NULL,
    name          VARCHAR(100)    NOT NULL,
    display_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_topics_component_name (component_id, name),
    KEY idx_topics_component_id (component_id),
    CONSTRAINT fk_topics_component
        FOREIGN KEY (component_id) REFERENCES components (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subtopics (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    topic_id      BIGINT UNSIGNED NOT NULL,
    name          VARCHAR(100)    NOT NULL,
    display_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_subtopics_topic_name (topic_id, name),
    KEY idx_subtopics_topic_id (topic_id),
    CONSTRAINT fk_subtopics_topic
        FOREIGN KEY (topic_id) REFERENCES topics (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Banco de preguntas
-- ---------------------------------------------------------------------------

CREATE TABLE questions (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subtopic_id      BIGINT UNSIGNED NOT NULL,
    stem             TEXT            NOT NULL,
    explanation      TEXT            NULL,
    difficulty       TINYINT UNSIGNED NOT NULL DEFAULT 3,
    level            ENUM('basic','intermediate','advanced') NOT NULL DEFAULT 'intermediate',
    avg_time_seconds SMALLINT UNSIGNED NULL,
    tags             JSON            NULL,
    is_active        BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_questions_subtopic_active (subtopic_id, is_active),
    KEY idx_questions_difficulty (difficulty),
    CONSTRAINT fk_questions_subtopic
        FOREIGN KEY (subtopic_id) REFERENCES subtopics (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_questions_difficulty
        CHECK (difficulty BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_options (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    question_id   BIGINT UNSIGNED NOT NULL,
    label         CHAR(1)         NOT NULL,
    text          TEXT            NOT NULL,
    is_correct    BOOLEAN         NOT NULL DEFAULT FALSE,
    display_order TINYINT UNSIGNED NOT NULL DEFAULT 0,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_question_options_question_label (question_id, label),
    KEY idx_question_options_question_id (question_id),
    CONSTRAINT fk_question_options_question
        FOREIGN KEY (question_id) REFERENCES questions (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Identidad / autenticación (CU-01)
-- ---------------------------------------------------------------------------

CREATE TABLE users (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    email         VARCHAR(255)    NOT NULL,
    password_hash VARCHAR(255)    NOT NULL,
    role          ENUM('student', 'parent') NOT NULL DEFAULT 'student',
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Estudiantes (soporte para exámenes; vinculados a users en CU-01)
-- ---------------------------------------------------------------------------

CREATE TABLE students (
    id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id    BIGINT UNSIGNED NULL,
    email      VARCHAR(255)    NOT NULL,
    full_name  VARCHAR(150)    NOT NULL,
    is_active  BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_students_email (email),
    UNIQUE KEY uq_students_user_id (user_id),
    KEY idx_students_user_id (user_id),
    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Exámenes
-- ---------------------------------------------------------------------------

CREATE TABLE exam_templates (
    id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_process_id  BIGINT UNSIGNED NOT NULL,
    name                  VARCHAR(150)    NOT NULL,
    duration_minutes      SMALLINT UNSIGNED NOT NULL,
    question_count        SMALLINT UNSIGNED NOT NULL,
    is_active             BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_exam_templates_admission_process_id (admission_process_id),
    CONSTRAINT fk_exam_templates_admission_process
        FOREIGN KEY (admission_process_id) REFERENCES admission_processes (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exam_template_questions (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    exam_template_id BIGINT UNSIGNED NOT NULL,
    question_id      BIGINT UNSIGNED NOT NULL,
    display_order    SMALLINT UNSIGNED NOT NULL,
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_etq_template_question (exam_template_id, question_id),
    UNIQUE KEY uq_etq_template_order (exam_template_id, display_order),
    KEY idx_etq_template_order (exam_template_id, display_order),
    CONSTRAINT fk_etq_exam_template
        FOREIGN KEY (exam_template_id) REFERENCES exam_templates (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_etq_question
        FOREIGN KEY (question_id) REFERENCES questions (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE student_exams (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id       BIGINT UNSIGNED NOT NULL,
    exam_template_id BIGINT UNSIGNED NOT NULL,
    status           ENUM('pending','in_progress','completed','expired') NOT NULL DEFAULT 'pending',
    started_at       DATETIME        NULL,
    finished_at      DATETIME        NULL,
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_student_exams_student_status (student_id, status),
    KEY idx_student_exams_template_id (exam_template_id),
    CONSTRAINT fk_student_exams_student
        FOREIGN KEY (student_id) REFERENCES students (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_student_exams_template
        FOREIGN KEY (exam_template_id) REFERENCES exam_templates (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Respuestas y resultados
-- ---------------------------------------------------------------------------

CREATE TABLE student_answers (
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_exam_id     BIGINT UNSIGNED NOT NULL,
    question_id         BIGINT UNSIGNED NOT NULL,
    selected_option_id  BIGINT UNSIGNED NULL,
    is_correct          BOOLEAN         NULL,
    is_saved            BOOLEAN         NOT NULL DEFAULT FALSE,
    time_seconds        SMALLINT UNSIGNED NULL,
    answered_at         DATETIME        NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_student_answers_exam_question (student_exam_id, question_id),
    KEY idx_student_answers_exam_id (student_exam_id),
    KEY idx_student_answers_question_id (question_id),
    CONSTRAINT fk_student_answers_exam
        FOREIGN KEY (student_exam_id) REFERENCES student_exams (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_student_answers_question
        FOREIGN KEY (question_id) REFERENCES questions (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_student_answers_option
        FOREIGN KEY (selected_option_id) REFERENCES question_options (id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exam_results (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_exam_id  BIGINT UNSIGNED NOT NULL,
    total_questions  SMALLINT UNSIGNED NOT NULL,
    correct_answers  SMALLINT UNSIGNED NOT NULL,
    score_percent    DECIMAL(5,2)    NOT NULL,
    duration_seconds INT UNSIGNED    NULL,
    calculated_at    DATETIME        NOT NULL,
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_exam_results_student_exam (student_exam_id),
    CONSTRAINT fk_exam_results_student_exam
        FOREIGN KEY (student_exam_id) REFERENCES student_exams (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exam_result_areas (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_exam_id  BIGINT UNSIGNED NOT NULL,
    area_id          BIGINT UNSIGNED NOT NULL,
    total_questions  SMALLINT UNSIGNED NOT NULL,
    correct_answers  SMALLINT UNSIGNED NOT NULL,
    score_percent    DECIMAL(5,2)    NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_era_exam_area (student_exam_id, area_id),
    KEY idx_era_student_exam_id (student_exam_id),
    CONSTRAINT fk_era_student_exam
        FOREIGN KEY (student_exam_id) REFERENCES student_exams (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_era_area
        FOREIGN KEY (area_id) REFERENCES areas (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exam_result_components (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_exam_id  BIGINT UNSIGNED NOT NULL,
    component_id     BIGINT UNSIGNED NOT NULL,
    total_questions  SMALLINT UNSIGNED NOT NULL,
    correct_answers  SMALLINT UNSIGNED NOT NULL,
    score_percent    DECIMAL(5,2)    NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_erc_exam_component (student_exam_id, component_id),
    KEY idx_erc_student_exam_id (student_exam_id),
    CONSTRAINT fk_erc_student_exam
        FOREIGN KEY (student_exam_id) REFERENCES student_exams (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_erc_component
        FOREIGN KEY (component_id) REFERENCES components (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exam_result_topics (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_exam_id  BIGINT UNSIGNED NOT NULL,
    topic_id         BIGINT UNSIGNED NOT NULL,
    total_questions  SMALLINT UNSIGNED NOT NULL,
    correct_answers  SMALLINT UNSIGNED NOT NULL,
    score_percent    DECIMAL(5,2)    NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ert_exam_topic (student_exam_id, topic_id),
    KEY idx_ert_student_exam_id (student_exam_id),
    CONSTRAINT fk_ert_student_exam
        FOREIGN KEY (student_exam_id) REFERENCES student_exams (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ert_topic
        FOREIGN KEY (topic_id) REFERENCES topics (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exam_result_subtopics (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_exam_id  BIGINT UNSIGNED NOT NULL,
    subtopic_id      BIGINT UNSIGNED NOT NULL,
    total_questions  SMALLINT UNSIGNED NOT NULL,
    correct_answers  SMALLINT UNSIGNED NOT NULL,
    score_percent    DECIMAL(5,2)    NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_erst_exam_subtopic (student_exam_id, subtopic_id),
    KEY idx_erst_student_exam_id (student_exam_id),
    CONSTRAINT fk_erst_student_exam
        FOREIGN KEY (student_exam_id) REFERENCES student_exams (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_erst_subtopic
        FOREIGN KEY (subtopic_id) REFERENCES subtopics (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
