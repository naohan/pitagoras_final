# Modelo relacional — Pitágoras

Diseño de base de datos MySQL para el KGAA (Nivel 1) y el ciclo de examen. Sin endpoints ni código de aplicación.

**Motor:** MySQL 8.x · **Charset:** `utf8mb4` · **Collation:** `utf8mb4_unicode_ci`

---

## 1. Diagrama entidad-relación

```
┌─────────────┐
│ universities│
└──────┬──────┘
       │ 1:N
┌──────▼──────┐
│  careers    │
└──────┬──────┘
       │ 1:N
┌──────▼──────────────┐
│ admission_processes │
└──────┬──────────────┘
       │ 1:N
┌──────▼──────┐       ┌─────────────────┐
│    areas    │       │  exam_templates │
└──────┬──────┘       └────────┬────────┘
       │ 1:N                   │ 1:N
┌──────▼──────┐       ┌────────▼──────────────────┐
│ components  │       │ exam_template_questions   │
└──────┬──────┘       └────────┬──────────────────┘
       │ 1:N                   │ N:1
┌──────▼──────┐       ┌────────▼────────┐
│   topics    │       │    questions    │◄────┐
└──────┬──────┘       └────────┬────────┘     │
       │ 1:N                   │ 1:N          │
┌──────▼──────┐       ┌────────▼────────┐     │
│  subtopics  │──────►│ question_options│     │
└─────────────┘  1:N  └─────────────────┘     │
                                              │
┌──────────┐    ┌──────────────┐    ┌─────────┴────────┐
│ students │───►│ student_exams │───►│ student_answers  │
└──────────┘    └──────┬───────┘    └──────────────────┘
                       │ 1:1
                ┌──────▼───────┐
                │ exam_results │
                └──────┬───────┘
                       │ 1:N (desglose por nivel)
        ┌──────────────┼──────────────┬──────────────────┐
        ▼              ▼              ▼                  ▼
 exam_result_    exam_result_   exam_result_    exam_result_
    areas        components       topics          subtopics
```

---

## 2. Entidades

### 2.1 Catálogo académico (KGAA Nivel 1)

#### `universities`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | Identificador interno |
| `code` | `VARCHAR(20)` | NOT NULL, UNIQUE | Código corto (ej. `UNSA`) |
| `name` | `VARCHAR(150)` | NOT NULL | Nombre oficial |
| `country` | `VARCHAR(60)` | NOT NULL, DEFAULT `'PE'` | País |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | Habilitada en la plataforma |
| `created_at` | `DATETIME` | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Alta |
| `updated_at` | `DATETIME` | NOT NULL, ON UPDATE CURRENT_TIMESTAMP | Última modificación |

#### `careers`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `university_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `universities.id` | Universidad dueña |
| `code` | `VARCHAR(30)` | NOT NULL | Código interno (ej. `ING`) |
| `name` | `VARCHAR(150)` | NOT NULL | Nombre (ej. `Ingeniería`) |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(university_id, code)`

#### `admission_processes`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `career_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `careers.id` | Carrera asociada |
| `name` | `VARCHAR(100)` | NOT NULL | Ej. `Admisión 2026` |
| `year` | `SMALLINT UNSIGNED` | NOT NULL | Año del proceso |
| `description` | `TEXT` | NULL | Notas administrativas |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | Proceso vigente |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(career_id, year)`

#### `areas`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `admission_process_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `admission_processes.id` | Proceso de admisión |
| `name` | `VARCHAR(100)` | NOT NULL | Ej. `Matemática` |
| `weight_percent` | `DECIMAL(5,2)` | NOT NULL | Peso en el examen (ej. `15.00`) |
| `display_order` | `SMALLINT UNSIGNED` | NOT NULL, DEFAULT 0 | Orden de presentación |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(admission_process_id, name)`  
**CHECK:** `weight_percent >= 0 AND weight_percent <= 100`

#### `components`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `area_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `areas.id` | Área padre |
| `name` | `VARCHAR(100)` | NOT NULL | Ej. `Razonamiento Matemático` |
| `display_order` | `SMALLINT UNSIGNED` | NOT NULL, DEFAULT 0 | |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(area_id, name)`

#### `topics`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `component_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `components.id` | Componente padre |
| `name` | `VARCHAR(100)` | NOT NULL | Ej. `Fracciones` |
| `display_order` | `SMALLINT UNSIGNED` | NOT NULL, DEFAULT 0 | |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(component_id, name)`

#### `subtopics`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `topic_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `topics.id` | Tema padre |
| `name` | `VARCHAR(100)` | NOT NULL | Ej. `Suma de fracciones` |
| `display_order` | `SMALLINT UNSIGNED` | NOT NULL, DEFAULT 0 | |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(topic_id, name)`

---

### 2.2 Banco de preguntas

#### `questions`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `subtopic_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `subtopics.id` | Contexto académico |
| `stem` | `TEXT` | NOT NULL | Enunciado |
| `explanation` | `TEXT` | NULL | Explicación de la respuesta correcta |
| `difficulty` | `TINYINT UNSIGNED` | NOT NULL, DEFAULT 3 | Escala 1–5 |
| `level` | `ENUM('basic','intermediate','advanced')` | NOT NULL, DEFAULT `'intermediate'` | Nivel pedagógico |
| `avg_time_seconds` | `SMALLINT UNSIGNED` | NULL | Tiempo promedio esperado |
| `tags` | `JSON` | NULL | Etiquetas libres (ej. `["admisión","UNSA"]`) |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | Visible en bancos/simulacros |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

#### `question_options`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `question_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `questions.id` | Pregunta dueña |
| `label` | `CHAR(1)` | NOT NULL | Letra (A, B, C, D…) |
| `text` | `TEXT` | NOT NULL | Texto de la alternativa |
| `is_correct` | `BOOLEAN` | NOT NULL, DEFAULT FALSE | Marca la respuesta correcta |
| `display_order` | `TINYINT UNSIGNED` | NOT NULL, DEFAULT 0 | Orden de visualización |
| `created_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(question_id, label)`

---

### 2.3 Exámenes

#### `students` *(entidad de soporte)*

Requerida por `student_exams` y `student_answers`. Se ampliará en Etapa 1 con autenticación.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `email` | `VARCHAR(255)` | NOT NULL, UNIQUE | Identificador del estudiante |
| `full_name` | `VARCHAR(150)` | NOT NULL | |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

#### `exam_templates` *(plantilla de examen)*

Define **qué** se evalúa. No es la sesión del estudiante.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `admission_process_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `admission_processes.id` | Proceso de admisión |
| `name` | `VARCHAR(150)` | NOT NULL | Ej. `Simulacro UNSA Ingeniería #1` |
| `duration_minutes` | `SMALLINT UNSIGNED` | NOT NULL | Tiempo límite |
| `question_count` | `SMALLINT UNSIGNED` | NOT NULL | Cantidad de preguntas |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT TRUE | |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

#### `exam_template_questions`

Relación N:M entre plantilla y preguntas, con orden fijo.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `exam_template_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `exam_templates.id` | Plantilla |
| `question_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `questions.id` | Pregunta incluida |
| `display_order` | `SMALLINT UNSIGNED` | NOT NULL | Posición en el examen |
| `created_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(exam_template_id, question_id)`  
**UNIQUE:** `(exam_template_id, display_order)`

#### `student_exams` *(sesión de examen)*

Instancia concreta: un estudiante rindiendo una plantilla.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `student_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `students.id` | Quién rinde |
| `exam_template_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `exam_templates.id` | Plantilla usada |
| `status` | `ENUM('pending','in_progress','completed','expired')` | NOT NULL, DEFAULT `'pending'` | Estado de la sesión |
| `started_at` | `DATETIME` | NULL | Inicio real |
| `finished_at` | `DATETIME` | NULL | Fin real |
| `created_at` | `DATETIME` | NOT NULL | |
| `updated_at` | `DATETIME` | NOT NULL | |

---

### 2.4 Respuestas y resultados

#### `student_answers`

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `student_exam_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `student_exams.id` | Sesión de examen |
| `question_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `questions.id` | Pregunta respondida |
| `selected_option_id` | `BIGINT UNSIGNED` | NULL, FK → `question_options.id` | Opción elegida (NULL = sin responder) |
| `is_correct` | `BOOLEAN` | NULL | Resultado tras calificar |
| `time_seconds` | `SMALLINT UNSIGNED` | NULL | Tiempo empleado |
| `answered_at` | `DATETIME` | NULL | Momento de la respuesta |
| `created_at` | `DATETIME` | NOT NULL | |

**UNIQUE:** `(student_exam_id, question_id)`

#### `exam_results` *(resultado global)*

Snapshot 1:1 al finalizar el examen.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `student_exam_id` | `BIGINT UNSIGNED` | NOT NULL, UNIQUE, FK → `student_exams.id` | Sesión calificada |
| `total_questions` | `SMALLINT UNSIGNED` | NOT NULL | Total de preguntas |
| `correct_answers` | `SMALLINT UNSIGNED` | NOT NULL | Aciertos |
| `score_percent` | `DECIMAL(5,2)` | NOT NULL | Porcentaje global |
| `duration_seconds` | `INT UNSIGNED` | NULL | Duración total |
| `calculated_at` | `DATETIME` | NOT NULL | Momento del cálculo |
| `created_at` | `DATETIME` | NOT NULL | |

#### Tablas de desglose (diagnóstico por nivel)

Materializan la matriz área → subtema sin recalcular en cada consulta.

**`exam_result_areas`**

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| `id` | `BIGINT UNSIGNED` | PK |
| `student_exam_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `student_exams.id` |
| `area_id` | `BIGINT UNSIGNED` | NOT NULL, FK → `areas.id` |
| `total_questions` | `SMALLINT UNSIGNED` | NOT NULL |
| `correct_answers` | `SMALLINT UNSIGNED` | NOT NULL |
| `score_percent` | `DECIMAL(5,2)` | NOT NULL |

**UNIQUE:** `(student_exam_id, area_id)`

**`exam_result_components`** — misma estructura con `component_id` FK → `components.id`  
**`exam_result_topics`** — con `topic_id` FK → `topics.id`  
**`exam_result_subtopics`** — con `subtopic_id` FK → `subtopics.id`

Cada una con **UNIQUE** `(student_exam_id, <entity>_id)`.

---

## 3. Relaciones y claves foráneas

| Tabla hijo | Columna FK | Tabla padre | ON DELETE | ON UPDATE |
|------------|------------|-------------|-----------|-----------|
| `careers` | `university_id` | `universities` | RESTRICT | CASCADE |
| `admission_processes` | `career_id` | `careers` | RESTRICT | CASCADE |
| `areas` | `admission_process_id` | `admission_processes` | RESTRICT | CASCADE |
| `components` | `area_id` | `areas` | RESTRICT | CASCADE |
| `topics` | `component_id` | `components` | RESTRICT | CASCADE |
| `subtopics` | `topic_id` | `topics` | RESTRICT | CASCADE |
| `questions` | `subtopic_id` | `subtopics` | RESTRICT | CASCADE |
| `question_options` | `question_id` | `questions` | CASCADE | CASCADE |
| `exam_templates` | `admission_process_id` | `admission_processes` | RESTRICT | CASCADE |
| `exam_template_questions` | `exam_template_id` | `exam_templates` | CASCADE | CASCADE |
| `exam_template_questions` | `question_id` | `questions` | RESTRICT | CASCADE |
| `student_exams` | `student_id` | `students` | RESTRICT | CASCADE |
| `student_exams` | `exam_template_id` | `exam_templates` | RESTRICT | CASCADE |
| `student_answers` | `student_exam_id` | `student_exams` | CASCADE | CASCADE |
| `student_answers` | `question_id` | `questions` | RESTRICT | CASCADE |
| `student_answers` | `selected_option_id` | `question_options` | SET NULL | CASCADE |
| `exam_results` | `student_exam_id` | `student_exams` | CASCADE | CASCADE |
| `exam_result_*` | `student_exam_id` | `student_exams` | CASCADE | CASCADE |
| `exam_result_areas` | `area_id` | `areas` | RESTRICT | CASCADE |
| `exam_result_components` | `component_id` | `components` | RESTRICT | CASCADE |
| `exam_result_topics` | `topic_id` | `topics` | RESTRICT | CASCADE |
| `exam_result_subtopics` | `subtopic_id` | `subtopics` | RESTRICT | CASCADE |

### Por qué `ON DELETE RESTRICT` en el catálogo académico

Evita borrar en cascada una universidad o área que ya tiene preguntas, exámenes o resultados históricos. La desactivación se hace con `is_active = FALSE`.

### Por qué `ON DELETE CASCADE` en respuestas y opciones

Si se elimina una sesión de examen (`student_exams`), sus respuestas y resultados deben desaparecer juntos. Si se elimina una pregunta en borrador, sus opciones se eliminan en cascada.

---

## 4. Índices

### Catálogo académico

| Tabla | Índice | Columnas | Motivo |
|-------|--------|----------|--------|
| `careers` | `idx_careers_university_id` | `university_id` | Listar carreras por universidad |
| `admission_processes` | `idx_admission_processes_career_id` | `career_id` | Procesos por carrera |
| `areas` | `idx_areas_admission_process_id` | `admission_process_id` | Áreas de un proceso |
| `components` | `idx_components_area_id` | `area_id` | Componentes de un área |
| `topics` | `idx_topics_component_id` | `component_id` | Temas de un componente |
| `subtopics` | `idx_subtopics_topic_id` | `topic_id` | Subtemas de un tema |

### Preguntas

| Tabla | Índice | Columnas | Motivo |
|-------|--------|----------|--------|
| `questions` | `idx_questions_subtopic_active` | `subtopic_id`, `is_active` | Banco filtrado por subtema |
| `questions` | `idx_questions_difficulty` | `difficulty` | Selección por dificultad en simulacros |
| `question_options` | `idx_question_options_question_id` | `question_id` | Cargar alternativas de una pregunta |

### Exámenes

| Tabla | Índice | Columnas | Motivo |
|-------|--------|----------|--------|
| `exam_templates` | `idx_exam_templates_admission_process_id` | `admission_process_id` | Plantillas por proceso |
| `exam_template_questions` | `idx_etq_template_order` | `exam_template_id`, `display_order` | Preguntas ordenadas |
| `student_exams` | `idx_student_exams_student_status` | `student_id`, `status` | Historial del estudiante |
| `student_exams` | `idx_student_exams_template_id` | `exam_template_id` | Estadísticas por plantilla |

### Respuestas y resultados

| Tabla | Índice | Columnas | Motivo |
|-------|--------|----------|--------|
| `student_answers` | `idx_student_answers_exam_id` | `student_exam_id` | Todas las respuestas de una sesión |
| `student_answers` | `idx_student_answers_question_id` | `question_id` | Análisis por pregunta |
| `exam_results` | `idx_exam_results_student_exam_id` | `student_exam_id` | UNIQUE ya indexa; lookup directo |
| `exam_result_areas` | `idx_era_student_exam_id` | `student_exam_id` | Diagnóstico por área |
| `exam_result_subtopics` | `idx_erst_student_exam_id` | `student_exam_id` | Diagnóstico fino (plan de estudio) |

---

## 5. Decisiones de diseño

| # | Decisión | Por qué |
|---|----------|---------|
| DB-01 | Jerarquía académica en 7 tablas encadenadas | Refleja el KGAA; agregar universidad = insertar registros, sin cambiar esquema |
| DB-02 | `weight_percent` en `areas` | La ponderación pertenece al proceso de admisión (UNSA Ingeniería 2026), no al área en abstracto |
| DB-03 | `questions.subtopic_id` como única FK académica | El contexto completo (área → subtema) se resuelve por JOINs; evita redundancia y desincronización |
| DB-04 | Separar `exam_templates` y `student_exams` | La plantilla es reutilizable; la sesión es un evento con estado y timestamps propios |
| DB-05 | Tabla puente `exam_template_questions` | Permite orden fijo, reutilizar preguntas en varias plantillas y validar unicidad |
| DB-06 | `student_answers.selected_option_id` nullable | Soporta preguntas sin responder; `SET NULL` si se elimina una opción en mantenimiento |
| DB-07 | `exam_results` + 4 tablas de desglose | Snapshot materializado para diagnóstico (D-05 arquitectura); consultas rápidas sin agregar en runtime |
| DB-08 | `students` mínima | `Examen`, `Respuestas` y `Resultados` requieren un sujeto; se extenderá con `auth` en Etapa 1 |
| DB-09 | `is_active` en lugar de borrado físico | Preserva integridad referencial e historial de exámenes |
| DB-10 | `BIGINT UNSIGNED` como PK | Estándar MySQL para alto volumen de respuestas |
| DB-11 | `tags` como JSON en `questions` | Flexibilidad sin tabla puente en v1; suficiente para filtros simples |
| DB-12 | UNIQUE por nombre dentro del padre | Evita duplicados (`Matemática` dos veces en el mismo proceso) |
| DB-13 | `display_order` en niveles jerárquicos | Control de presentación en UI sin depender del orden alfabético |
| DB-14 | Nombres de tabla en inglés `snake_case` | Convención de código; coherente con SQLAlchemy y Alembic |

---

## 6. Resolución de contexto académico (ejemplo)

Pregunta `3501` almacena solo `subtopic_id`. El Tutor IA y el diagnóstico obtienen el contexto con:

```sql
SELECT
  u.name  AS university,
  c.name  AS career,
  a.name  AS area,
  co.name AS component,
  t.name  AS topic,
  s.name  AS subtopic
FROM questions q
JOIN subtopics s   ON s.id = q.subtopic_id
JOIN topics t      ON t.id = s.topic_id
JOIN components co ON co.id = t.component_id
JOIN areas a       ON a.id = co.area_id
JOIN admission_processes ap ON ap.id = a.admission_process_id
JOIN careers c     ON c.id = ap.career_id
JOIN universities u ON u.id = c.university_id
WHERE q.id = 3501;
```

---

## 7. Referencias

- [ARCHITECTURE.md](ARCHITECTURE.md) — Visión del KGAA y capas del sistema
- [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) — Bitácora de desarrollo
- [schema.sql](../database/schema.sql) — DDL ejecutable de referencia
