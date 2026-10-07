# Guía de implementación — Pitágoras

Bitácora viva del desarrollo. Cada entrada documenta una etapa completada para que cualquier desarrollador pueda continuar el proyecto sin perder contexto.

**Convención:** las entradas más recientes se agregan al final del documento, en orden cronológico.

---

## Índice de etapas

| # | Etapa | Estado | Fecha |
|---|-------|--------|-------|
| 0 | Diseño de arquitectura | ✅ Completada | 2026-06-26 |
| 0.1 | Estructura de carpetas del backend | ✅ Completada | 2026-06-26 |
| 0.2 | Modelo relacional de base de datos | ✅ Completada | 2026-06-26 |
| 0.3 | Modelos SQLAlchemy | ✅ Completada | 2026-06-26 |
| 0.4 | Repositorios CRUD (catálogo + preguntas) | ✅ Completada | 2026-06-26 |
| 0.5 | Endpoints REST (catálogo + preguntas) | ✅ Completada | 2026-06-26 |
| 1 | Backend tradicional (FastAPI + MySQL) | ⏳ En progreso (auth ✅) | — |
| 2 | Motor de exámenes | ✅ Completada | 2026-06-26 |
| 2.1 | Verificación del motor de exámenes | ✅ Completada | 2026-06-26 |
| 3 | Knowledge Graph lógico | ⏳ Pendiente | — |
| 4 | Diagnóstico académico | ✅ Completada | 2026-06-26 |
| 5 | Recomendaciones (reglas) | ✅ Completada | 2026-06-26 |
| 6 | RAG (ChromaDB) | ✅ Completada | 2026-06-26 |
| 7 | Tutor IA (LLM + RAG) | ✅ Completada | 2026-06-26 |
| 8 | Tutor Google ADK | ✅ Completada | 2026-06-26 |
| 8.1 | LangGraph orquestador | ✅ Completada | 2026-06-26 |
| 8.2 | Agentes Diagnóstico, Motivador, Padres | ✅ Completada | 2026-06-26 |
| 9 | CU-01 — Auth JWT (registro + login) | ✅ Completada | 2026-06-26 |

---

## Etapa 0 — Diseño de arquitectura

**Fecha:** 2026-06-26  
**Responsable:** Sesión de diseño con Cursor (rol: Arquitecto de Software Senior)  
**Alcance:** Definición conceptual y estructural. Sin código de aplicación.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Código backend | No iniciado |
| Base de datos | No creada |
| Docker | No configurado |
| Documentación | Iniciada (este documento, README, ARCHITECTURE) |
| Cliente Flutter | No iniciado |
| IA / RAG / Agentes | Diseñados conceptualmente; fuera de alcance |

El repositorio contiene únicamente documentación de arquitectura. No hay dependencias instaladas ni servicios ejecutándose.

---

### 2. Qué se implementó

En esta etapa **no se escribió código de aplicación**. Se produjo:

- Definición del **Knowledge Graph Académico Adaptativo (KGAA)** como modelo central del sistema.
- Identificación de **9 bounded contexts** del dominio.
- Diseño de capas siguiendo **Clean Architecture** (domain → application → infrastructure → api).
- Estructura de carpetas planificada para el backend.
- Mapa de dependencias entre módulos.
- Roadmap de **9 etapas** de implementación incremental.
- Documentación base: `README.md`, `docs/ARCHITECTURE.md`, `docs/IMPLEMENTATION_GUIDE.md`.

---

### 3. Flujo actualizado

#### Flujo académico (modelo de datos)

```
Universidad
  → Carrera
    → Proceso de admisión
      → Área (peso %)
        → Componente
          → Tema
            → Subtema
              → Recursos | Preguntas
```

#### Flujo post-examen (planificado — Etapas 2–5)

```
Crear examen
  → Seleccionar preguntas (según ponderación de áreas)
    → Registrar respuestas + tiempo
      → Calificar
        → Generar diagnóstico (área → componente → tema → subtema)
          → Generar recomendaciones (reglas, sin IA)
```

#### Flujo Tutor IA (planificado — Etapa 7+)

```
Pregunta fallida
  → Resolver contexto (área, componente, tema, subtema)
    → Filtrar material en Knowledge Graph
      → Buscar embeddings en ChromaDB
        → Construir prompt
          → LLM → Respuesta contextualizada
```

#### Flujo multi-agente (planificado — Etapa 8+)

```
Flutter → FastAPI → LangGraph
                      ├─ Tutor IA
                      ├─ Diagnóstico
                      ├─ Motivador
                      └─ Padres
```

---

### 4. Archivos creados

| Archivo | Propósito |
|---------|-----------|
| `README.md` | Visión general, instalación y ejecución (plantilla para cuando exista código) |
| `docs/ARCHITECTURE.md` | Arquitectura, módulos, diagramas, modelo de datos, decisiones técnicas |
| `docs/IMPLEMENTATION_GUIDE.md` | Este documento — bitácora de desarrollo |

**Archivos de código:** ninguno.

---

### 5. Responsabilidades (módulos definidos)

| Módulo | Capa | Responsabilidad |
|--------|------|-----------------|
| `identity` | Domain | Usuarios, estudiantes, padres, roles, vínculos |
| `academic_catalog` | Domain | Jerarquía universidad → subtema, pesos por área |
| `content` | Domain | Recursos educativos por subtema |
| `assessment` | Domain | Preguntas, opciones, metadatos |
| `exam_engine` | Domain | Plantillas, sesiones, respuestas, calificación |
| `diagnostics` | Domain | Perfil académico post-examen |
| `recommendations` | Domain | Plan de estudio por reglas |
| `knowledge_graph` | Domain | Relaciones entre conceptos |
| `parents` | Domain | Vista de progreso para padres |
| `application/ports` | Application | Interfaces de repositorios (contratos) |
| `application/use_cases` | Application | Orquestación de casos de uso |
| `infrastructure/database` | Infrastructure | ORM, session, migraciones Alembic |
| `infrastructure/repositories` | Infrastructure | Implementación de puertos |
| `infrastructure/security` | Infrastructure | JWT, hash de contraseñas |
| `api/v1` | Presentation | Routers REST, schemas Pydantic |
| `rag`, `llm`, `agents`, `orchestrator` | Infrastructure (futuro) | Stubs reservados para Etapas 6–8 |

---

### 6. Dependencias

#### Entre módulos de dominio

```
identity          (independiente)

academic_catalog  (independiente)

content           → academic_catalog
assessment        → academic_catalog
exam_engine       → assessment, academic_catalog
diagnostics       → exam_engine
recommendations   → diagnostics, content
knowledge_graph   → academic_catalog
parents           → identity, diagnostics
```

#### Entre capas (Clean Architecture)

```
api              → application/use_cases
use_cases        → domain + application/ports
infrastructure   → application/ports (implementa)
domain           → (ninguna dependencia externa)
```

#### Dependencias tecnológicas planificadas

| Etapa | Dependencias nuevas |
|-------|---------------------|
| 1 | fastapi, uvicorn, sqlalchemy, alembic, pymysql, pydantic-settings, python-jose, passlib |
| 6 | chromadb, langchain (o equivalente) |
| 7 | openai / google-generativeai |
| 8 | google-adk, langgraph |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| D-01 | MySQL como fuente de verdad del KGAA | Ya forma parte de la arquitectura del equipo; suficiente para jerarquías y relaciones con FKs |
| D-02 | No usar Neo4j en v1 | Evitar complejidad prematura; sincronizar a grafo solo si el volumen lo justifica |
| D-03 | Clean Architecture con bounded contexts | Separar dominio de infraestructura; facilitar testing y evolución hacia IA |
| D-04 | ORM models separados de domain entities | El dominio no debe depender de SQLAlchemy |
| D-05 | Diagnóstico como snapshot materializado | Evitar recalcular agregaciones en cada consulta |
| D-06 | Ponderación de áreas en tabla `areas` | El motor de exámenes lee pesos del proceso de admisión, no hardcodeados |
| D-07 | IA desacoplada mediante puertos | `TutorPort`, `RAGPort` en application; implementación en infrastructure |
| D-08 | Desarrollo incremental en 9 etapas | Cada etapa entrega valor funcional sin depender de la siguiente |
| D-09 | FastAPI nunca es reemplazado por LangGraph | LangGraph vive dentro de FastAPI como módulo de orquestación |
| D-10 | Agents CLI solo para desarrollo | No forma parte del runtime de producción |
| D-11 | Tres documentos con roles distintos | README (operación), ARCHITECTURE (diseño), IMPLEMENTATION_GUIDE (bitácora) |

---

### 8. Posibles mejoras futuras

- **Sincronización a Neo4j** cuando las consultas de relaciones entre conceptos se vuelvan costosas en SQL.
- **Eventos de dominio** (ej. `ExamCompleted`) para desacoplar diagnóstico y notificaciones a padres.
- **MCP** para conectar agentes a herramientas externas (Drive, OCR, calendario) de forma estandarizada.
- **Caché (Redis)** para árboles académicos consultados frecuentemente.
- **Multi-tenancy** si Pitágoras se ofrece como SaaS a academias prepa.
- **Versionado de preguntas** para auditoría y estadísticas históricas.
- **Internacionalización** del contenido académico (no solo español).

---

### 9. Próximo paso recomendado

**Etapa 1 — Backend tradicional (FastAPI + MySQL)**

Orden sugerido de trabajo:

1. **Scaffolding**
   - Crear estructura de carpetas en `backend/app/`
   - `pyproject.toml` / `requirements.txt`
   - `docker-compose.yml` (API + MySQL)
   - `.env.example`

2. **Core**
   - `core/config.py` — settings con pydantic-settings
   - `core/exceptions.py` — excepciones de dominio y handlers HTTP
   - `infrastructure/database/session.py` — engine y session factory

3. **Identity (primer bounded context)**
   - Entidades y puertos
   - Modelos ORM + migración Alembic
   - Repositorio + casos de uso (registro, login)
   - Router `/api/v1/auth`

4. **Academic catalog (segundo bounded context)**
   - Tablas: `universities` → `careers` → `admission_processes` → `areas` → `components` → `topics` → `subtopics`
   - CRUD completo con routers REST
   - Seed inicial: UNSA / Ingeniería / Admisión 2026 con pesos de áreas

5. **Verificación**
   - Tests de integración para auth y catálogo
   - Documentación automática en `/docs`
   - Actualizar esta guía con la entrada **Etapa 1**

**Criterio de aceptación Etapa 1:** un desarrollador puede registrar un usuario, autenticarse y consultar el árbol académico completo de UNSA vía API REST, sin IA.

---

---

## Etapa 0.1 — Estructura de carpetas del backend

**Fecha:** 2026-06-26  
**Responsable:** Sesión de scaffolding con Cursor  
**Alcance:** Creación del árbol de directorios bajo `backend/app/`. Sin lógica de negocio, sin dependencias instaladas.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Código backend | Estructura de carpetas creada (vacía) |
| Base de datos | No creada |
| Docker | Carpeta `docker/` reservada, sin compose |
| Documentación | README, ARCHITECTURE, IMPLEMENTATION_GUIDE |
| Cliente Flutter | No iniciado |
| IA / RAG / Agentes | Carpetas reservadas (`rag/`, `agents/`, `orchestrator/`) |

El repositorio tiene documentación y el esqueleto de directorios del backend. Ningún módulo contiene código Python todavía.

---

### 2. Qué se implementó

- Árbol de carpetas bajo `backend/app/` con las capas horizontales y módulos verticales acordados.
- Archivos `.gitkeep` en cada carpeta para que Git rastree directorios vacíos.
- Carpetas auxiliares: `tests/unit`, `tests/integration`, `docker/`.
- **No** se escribió lógica, modelos, routers ni configuración.

---

### 3. Flujo actualizado

El flujo de negocio no cambia respecto a la Etapa 0. Lo que cambia es **dónde vivirá cada pieza** cuando se implemente:

```
HTTP Request
  → api/              (routers FastAPI)
    → auth/           (si requiere autenticación)
    → services/       (orquestación de casos de uso)
      → repositories/ (acceso a datos)
        → models/     (entidades ORM)
          → database/ (session, conexión MySQL)
    ← schemas/        (validación request/response Pydantic)
```

Flujos futuros ya tienen carpeta asignada:

```
exams/ → diagnostics/ → recommendations/     (Etapas 2–5, sin IA)
questions/                                 (banco de preguntas)
rag/ + prompts/ + tools/                   (Etapa 6–7, Tutor IA)
orchestrator/ → agents/                    (Etapa 8, multi-agente)
```

---

### 4. Archivos creados

#### Árbol del proyecto

```
pitagoras/
├── README.md
├── docs/
│   ├── ARCHITECTURE.md
│   └── IMPLEMENTATION_GUIDE.md
├── docker/
│   └── .gitkeep
├── tests/
│   ├── unit/
│   │   └── .gitkeep
│   └── integration/
│       └── .gitkeep
└── backend/
    └── app/
        ├── api/
        │   └── .gitkeep
        ├── core/
        │   └── .gitkeep
        ├── models/
        │   └── .gitkeep
        ├── schemas/
        │   └── .gitkeep
        ├── repositories/
        │   └── .gitkeep
        ├── services/
        │   └── .gitkeep
        ├── database/
        │   └── .gitkeep
        ├── auth/
        │   └── .gitkeep
        ├── exams/
        │   └── .gitkeep
        ├── questions/
        │   └── .gitkeep
        ├── diagnostics/
        │   └── .gitkeep
        ├── recommendations/
        │   └── .gitkeep
        ├── rag/
        │   └── .gitkeep
        ├── agents/
        │   └── .gitkeep
        ├── orchestrator/
        │   └── .gitkeep
        ├── prompts/
        │   └── .gitkeep
        └── tools/
            └── .gitkeep
```

**Total:** 20 carpetas de aplicación + 3 auxiliares. Solo archivos `.gitkeep`; sin `.py` de lógica.

---

### 5. Responsabilidades

| Carpeta | Capa | Responsabilidad |
|---------|------|-----------------|
| `app/` | Raíz del paquete | Punto de entrada del backend FastAPI (`main.py` irá aquí) |
| `api/` | Presentación | Routers HTTP, versionado (`/api/v1`), registro de endpoints |
| `core/` | Transversal | Configuración, logging, excepciones globales, dependencias compartidas |
| `schemas/` | Presentación | Modelos Pydantic de entrada/salida (DTOs HTTP) |
| `models/` | Persistencia | Modelos SQLAlchemy (tablas MySQL) |
| `database/` | Infraestructura | Engine, session factory, base declarativa, utilidades de conexión |
| `repositories/` | Infraestructura | Consultas y persistencia; abstrae el acceso a `models/` |
| `services/` | Aplicación | Casos de uso y reglas de negocio; orquesta `repositories/` |
| `auth/` | Dominio + aplicación | Registro, login, JWT, roles, vínculo padre–estudiante |
| `exams/` | Dominio + aplicación | Plantillas, sesiones, respuestas, calificación, control de tiempo |
| `questions/` | Dominio + aplicación | Banco de preguntas, opciones, filtros por jerarquía académica |
| `diagnostics/` | Dominio + aplicación | Agregación post-examen por área → subtema; snapshots de perfil |
| `recommendations/` | Dominio + aplicación | Plan de estudio por reglas; asignación de recursos |
| `rag/` | Infraestructura IA | ChromaDB, embeddings, indexación de material educativo (Etapa 6+) |
| `agents/` | Infraestructura IA | Agentes Google ADK: Tutor, Motivador, Padres (Etapa 8+) |
| `orchestrator/` | Infraestructura IA | LangGraph: routing entre agentes según contexto del estudiante |
| `prompts/` | Infraestructura IA | Plantillas de prompts por agente y por subtema |
| `tools/` | Infraestructura IA | Herramientas invocables por agentes (calculadora, búsqueda PDF, OCR) |

**Convención:** cada módulo vertical (`auth/`, `exams/`, etc.) puede contener sus propios archivos de servicio, repositorio y router; las carpetas horizontales (`services/`, `repositories/`, `api/`) agrupan o reexportan según convenga al implementar.

---

### 6. Dependencias

#### Entre carpetas (dirección permitida)

```
api/           → services/, schemas/, auth/ (middleware)
services/      → repositories/, core/
repositories/  → models/, database/
models/        → database/
auth/          → services/, repositories/ (cuando se implemente)

exams/         → questions/, services/
diagnostics/   → exams/, services/
recommendations/ → diagnostics/, services/

agents/        → rag/, prompts/, tools/, orchestrator/ (futuro)
orchestrator/  → agents/ (futuro)
rag/           → tools/ (futuro)
```

#### Prohibido (para mantener capas)

```
models/        ✗→ api/
repositories/  ✗→ api/
database/      ✗→ services/
```

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| D-12 | Estructura híbrida: capas horizontales + módulos verticales | Combina claridad de Clean Architecture (`api`, `services`, `repositories`) con bounded contexts (`exams`, `questions`, `diagnostics`) |
| D-13 | Todo bajo `backend/app/` | Convención estándar de FastAPI; facilita imports `from app.services...` |
| D-14 | Carpetas IA creadas desde el inicio pero vacías | Evita reestructurar el proyecto al llegar a Etapas 6–8 |
| D-15 | `.gitkeep` en lugar de archivos `.py` vacíos | Git rastrea directorios sin introducir código ni imports rotos |
| D-16 | `tests/` fuera de `app/` | Separación clara entre código de producción y pruebas |

---

### 8. Posibles mejoras futuras

- Subcarpeta `api/v1/` cuando se registren los primeros routers.
- `alembic/` junto a `backend/` para migraciones.
- Dividir `agents/` en subcarpetas (`tutor/`, `motivador/`, `padres/`, `diagnostico/`).
- `app/academic/` para el catálogo jerárquico (universidades, áreas, subtemas) cuando se implemente el KGAA.
- `app/content/` para recursos educativos (PDF, video, flashcards).

---

### 9. Próximo paso recomendado

Continuar **Etapa 1 — Backend tradicional**:

1. `backend/requirements.txt` y `backend/.env.example`
2. `docker/docker-compose.yml` (API + MySQL)
3. `app/main.py` — factory FastAPI mínima
4. `app/core/config.py` — settings
5. `app/database/` — session y base ORM
6. Primer módulo funcional: `auth/` (registro + login)

**Criterio de aceptación inmediato:** `uvicorn app.main:app` arranca sin errores y `/docs` responde.

---

---

## Etapa 0.2 — Modelo relacional de base de datos

**Fecha:** 2026-06-26  
**Responsable:** Sesión de diseño con Cursor  
**Alcance:** Diseño relacional MySQL para catálogo académico, preguntas, exámenes, respuestas y resultados. Sin endpoints, sin modelos ORM, sin migraciones Alembic.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Código backend | Estructura de carpetas vacía |
| Base de datos | **Diseñada** (documentación + DDL de referencia) |
| Migraciones Alembic | No creadas |
| Docker MySQL | No configurado |
| Documentación | README, ARCHITECTURE, DATABASE, IMPLEMENTATION_GUIDE |

El modelo relacional está definido y listo para implementarse en SQLAlchemy/Alembic. No hay tablas creadas en un servidor MySQL todavía.

---

### 2. Qué se implementó

- Modelo relacional de **18 tablas** (17 solicitadas + `students` como entidad de soporte).
- Documento completo: `docs/DATABASE.md` (entidades, relaciones, FKs, índices, decisiones).
- DDL de referencia: `database/schema.sql` (ejecutable en MySQL 8.x).
- Separación **plantilla de examen** (`exam_templates`) vs **sesión** (`student_exams`).
- Tablas de **desglose de resultados** en 4 niveles (área, componente, tema, subtema) para diagnóstico.
- **No** se escribieron endpoints, modelos SQLAlchemy ni migraciones.

---

### 3. Flujo actualizado

#### Persistencia del catálogo académico

```
INSERT universities → careers → admission_processes
  → areas (weight_percent) → components → topics → subtopics
```

#### Ciclo de examen (tablas involucradas)

```
exam_templates + exam_template_questions
  → student_exams (student_id + exam_template_id)
    → student_answers (question_id + selected_option_id)
      → exam_results (score global)
        → exam_result_areas
        → exam_result_components
        → exam_result_topics
        → exam_result_subtopics
```

#### Resolución de contexto para Tutor IA (futuro)

```
questions.subtopic_id
  → JOIN jerárquico hasta universities
  → JSON de contexto sin columnas redundantes en questions
```

---

### 4. Archivos creados

| Archivo | Propósito |
|---------|-----------|
| `docs/DATABASE.md` | Diseño relacional completo con justificación de decisiones |
| `database/schema.sql` | DDL MySQL 8.x de las 18 tablas |

#### Tablas definidas

| Grupo | Tablas |
|-------|--------|
| Catálogo académico | `universities`, `careers`, `admission_processes`, `areas`, `components`, `topics`, `subtopics` |
| Preguntas | `questions`, `question_options` |
| Exámenes | `students`, `exam_templates`, `exam_template_questions`, `student_exams` |
| Respuestas y resultados | `student_answers`, `exam_results`, `exam_result_areas`, `exam_result_components`, `exam_result_topics`, `exam_result_subtopics` |

---

### 5. Responsabilidades

| Tabla | Responsabilidad |
|-------|-----------------|
| `universities` → `subtopics` | KGAA Nivel 1; jerarquía académica con pesos en `areas` |
| `questions` | Banco de preguntas; contexto vía `subtopic_id` |
| `question_options` | Alternativas A/B/C/D; una marcada `is_correct` |
| `exam_templates` | Definición reutilizable de un simulacro |
| `exam_template_questions` | Preguntas incluidas y su orden en la plantilla |
| `student_exams` | Sesión concreta de un estudiante (estado, tiempos) |
| `student_answers` | Respuesta por pregunta con tiempo y corrección |
| `exam_results` | Resultado global materializado (1:1 con sesión) |
| `exam_result_*` | Desglose por nivel para diagnóstico y plan de estudio |
| `students` | Sujeto del examen; se integrará con `auth` en Etapa 1 |

---

### 6. Dependencias

#### Cadena de claves foráneas (catálogo)

```
universities
  ← careers
    ← admission_processes
      ← areas
        ← components
          ← topics
            ← subtopics
              ← questions
                ← question_options
```

#### Cadena de examen

```
admission_processes ← exam_templates ← exam_template_questions → questions
students + exam_templates → student_exams → student_answers → question_options
student_exams → exam_results → exam_result_{areas,components,topics,subtopics}
```

#### Mapeo tabla → carpeta del backend (futuro)

| Tablas | Carpeta `app/` |
|--------|----------------|
| `universities` … `subtopics` | `models/` + servicios de catálogo académico |
| `questions`, `question_options` | `questions/` |
| `exam_templates`, `student_exams`, `student_answers` | `exams/` |
| `exam_results`, `exam_result_*` | `diagnostics/` |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| DB-01 | 7 tablas encadenadas para el catálogo | Refleja KGAA; escalar por datos, no por código |
| DB-02 | `weight_percent` en `areas` | Ponderación específica del proceso (ej. UNSA Ingeniería 2026) |
| DB-03 | `questions` solo FK a `subtopic_id` | Contexto completo por JOINs; sin redundancia |
| DB-04 | `exam_templates` ≠ `student_exams` | Plantilla reutilizable vs evento con estado |
| DB-05 | `exam_template_questions` como tabla puente | Orden fijo y reutilización de preguntas |
| DB-06 | `selected_option_id` nullable en respuestas | Soporta omisiones; `SET NULL` en mantenimiento |
| DB-07 | 4 tablas de desglose de resultados | Snapshot de diagnóstico; evita agregaciones en runtime |
| DB-08 | Tabla `students` mínima | Requerida por examen/respuestas; se amplía con auth |
| DB-09 | `is_active` en lugar de DELETE físico | Preserva historial e integridad referencial |
| DB-10 | `ON DELETE RESTRICT` en catálogo | No borrar universidades/áreas con datos históricos |
| DB-11 | `ON DELETE CASCADE` en respuestas/resultados | Limpieza coherente al eliminar una sesión |
| DB-12 | `BIGINT UNSIGNED` como PK | Estándar MySQL para alto volumen |
| DB-13 | `tags` JSON en `questions` | Flexibilidad en v1 sin tabla puente |
| DB-14 | UNIQUE `(padre_id, name)` en cada nivel | Evita duplicados en la jerarquía |

---

### 8. Posibles mejoras futuras

- Tabla `users` unificada con roles (`student`, `parent`, `admin`) vinculada a `students`.
- Tabla `concept_relations` para el KGAA Nivel 4 (`prerequisito_de`, `relacionado_con`).
- Tabla `resources` (PDF, video, flashcards) ligada a `subtopics`.
- Constraint o trigger: exactamente una `question_option` con `is_correct = TRUE` por pregunta.
- Tabla `question_tags` normalizada si los filtros por etiqueta se vuelven complejos.
- Particionamiento de `student_answers` por año si el volumen crece significativamente.
- Vista materializada o vista SQL `v_question_context` para simplificar JOINs del Tutor IA.

---

### 9. Próximo paso recomendado

Continuar **Etapa 1 — Backend tradicional**:

1. `docker/docker-compose.yml` con servicio MySQL
2. Inicializar Alembic en `backend/`
3. Primera migración basada en `database/schema.sql`
4. Modelos SQLAlchemy en `app/models/` (uno por tabla o agrupados por dominio)
5. `app/database/session.py` — conexión y session factory
6. Seed script: UNSA / Ingeniería / Admisión 2026 con pesos de áreas

**Criterio de aceptación inmediato:** `alembic upgrade head` crea las 18 tablas en MySQL sin errores.

---

---

## Etapa 0.3 — Modelos SQLAlchemy

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Modelos ORM SQLAlchemy 2.0 para las 18 tablas de `database/schema.sql`. Sin routers, servicios, CRUD ni migraciones Alembic.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Código backend | Modelos ORM implementados |
| Base de datos | Diseñada; tablas aún no creadas en MySQL |
| Migraciones Alembic | No creadas |
| Session / engine | No implementado (`database/session.py` pendiente) |
| API REST | No implementada |
| Documentación | Actualizada |

Los modelos están listos para usarse con Alembic autogenerate y con repositorios en etapas posteriores.

---

### 2. Qué se implementó

- **18 modelos ORM** alineados 1:1 con `database/schema.sql`.
- Estilo **SQLAlchemy 2.0**: `Mapped`, `mapped_column`, `relationship`.
- **Mixins** de timestamps: `TimestampMixin` (created/updated) y `CreatedAtMixin` (solo created).
- **Enums** Python: `QuestionLevel`, `StudentExamStatus`.
- **Foreign Keys** con `ondelete`/`onupdate` idénticos al DDL.
- **Índices** y **UniqueConstraint** en `__table_args__`.
- **CheckConstraint** en `areas` (peso) y `questions` (dificultad).
- **`models/__init__.py`** exporta todos los modelos y `Base` para Alembic.

**No implementado:** `session.py`, `main.py`, routers, servicios, repositorios, migraciones.

---

### 3. Flujo actualizado

```
database/schema.sql  (DDL referencia)
        ↓
app/database/base.py  (DeclarativeBase)
        ↓
app/models/*.py       (18 modelos ORM)
        ↓
[Alembic autogenerate]  ← próximo paso
        ↓
MySQL (tablas físicas)
        ↓
repositories/ → services/ → api/  (futuro)
```

Los modelos permiten navegar el grafo en Python:

```python
question.subtopic.topic.component.area.admission_process.career.university
student_exam.answers → question → options
student_exam.result_subtopics → subtopic  # diagnóstico
```

---

### 4. Archivos creados

```
backend/app/
├── __init__.py
├── database/
│   ├── __init__.py
│   └── base.py              # DeclarativeBase
└── models/
    ├── __init__.py          # exporta todos los modelos
    ├── enums.py             # QuestionLevel, StudentExamStatus
    ├── mixins.py            # TimestampMixin, CreatedAtMixin
    ├── academic.py          # University → Subtopic (7 modelos)
    ├── question.py          # Question, QuestionOption
    ├── student.py           # Student
    ├── exam.py              # ExamTemplate, ExamTemplateQuestion, StudentExam
    ├── answer.py            # StudentAnswer
    └── result.py            # ExamResult + 4 tablas de desglose
```

| Archivo | Modelos |
|---------|---------|
| `academic.py` | `University`, `Career`, `AdmissionProcess`, `Area`, `Component`, `Topic`, `Subtopic` |
| `question.py` | `Question`, `QuestionOption` |
| `student.py` | `Student` |
| `exam.py` | `ExamTemplate`, `ExamTemplateQuestion`, `StudentExam` |
| `answer.py` | `StudentAnswer` |
| `result.py` | `ExamResult`, `ExamResultArea`, `ExamResultComponent`, `ExamResultTopic`, `ExamResultSubtopic` |

---

### 5. Responsabilidades

| Módulo | Responsabilidad |
|--------|-----------------|
| `database/base.py` | Clase `Base` declarativa compartida |
| `models/mixins.py` | Timestamps reutilizables según el esquema de cada tabla |
| `models/enums.py` | Enums de dominio mapeados a columnas `ENUM` de MySQL |
| `models/academic.py` | KGAA Nivel 1 — jerarquía universidad → subtema |
| `models/question.py` | Banco de preguntas y alternativas |
| `models/student.py` | Estudiante (soporte para sesiones de examen) |
| `models/exam.py` | Plantillas, preguntas de plantilla y sesiones |
| `models/answer.py` | Respuestas individuales por pregunta |
| `models/result.py` | Resultado global y desglose por nivel jerárquico |
| `models/__init__.py` | Registro central para imports y Alembic `target_metadata` |

---

### 6. Dependencias

#### Entre archivos de modelos

```
base.py ← todos los modelos
mixins.py, enums.py ← modelos de dominio
academic.py (sin dependencias de otros modelos en runtime)
question.py → academic.Subtopic
student.py → exam.StudentExam (TYPE_CHECKING)
exam.py → academic, question, student, answer, result
answer.py → exam, question
result.py → academic, exam
__init__.py → importa todos (registra tablas en Base.metadata)
```

#### Paquetes Python requeridos (aún sin requirements.txt)

```
sqlalchemy>=2.0
```

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| M-01 | SQLAlchemy 2.0 con `Mapped`/`mapped_column` | Estándar actual; tipado estático y mejor DX |
| M-02 | Modelos agrupados por dominio, no un archivo por tabla | 8 archivos legibles vs 18 archivos fragmentados |
| M-03 | `TimestampMixin` y `CreatedAtMixin` separados | Refleja el DDL: no todas las tablas tienen `updated_at` |
| M-04 | `TYPE_CHECKING` para imports circulares | Evita ciclos en runtime entre academic ↔ exam ↔ result |
| M-05 | `from __future__ import annotations` | Anotaciones diferidas; relaciones forward-ref sin comillas |
| M-06 | FK `ondelete`/`onupdate` explícitos en cada columna | Paridad exacta con `schema.sql` (RESTRICT, CASCADE, SET NULL) |
| M-07 | Índices y constraints en `__table_args__` | Alembic los genera; consultas alineadas al diseño DB-01–DB-14 |
| M-08 | `cascade="all, delete-orphan"` solo en composiciones fuertes | Opciones de pregunta, respuestas de sesión, preguntas de plantilla |
| M-09 | `cascade="save-update, merge"` en asociaciones de catálogo | No borrar en cascada áreas/temas al guardar |
| M-10 | Enums Python `str, enum.Enum` | Serialización natural; valores coinciden con MySQL ENUM |
| M-11 | `Base` en `database/base.py`, modelos en `models/` | Separación infraestructura (base) vs mapeo (modelos) |

---

### 8. Posibles mejoras futuras

- `requirements.txt` con `sqlalchemy>=2.0`, `pymysql`, `cryptography`.
- `database/session.py` con engine y `SessionLocal`.
- Configurar Alembic con `target_metadata = Base.metadata`.
- Type aliases o métodos helper en `Question` para resolver contexto académico (`get_academic_context()`).
- Validación a nivel ORM (`@validates`) para una sola opción correcta por pregunta.
- Usar `BIGINT(unsigned=True)` del dialecto MySQL si se requiere paridad byte a byte con el DDL.

---

### 9. Próximo paso recomendado

Continuar **Etapa 1 — Backend tradicional**:

1. `backend/requirements.txt` — sqlalchemy, fastapi, uvicorn, pymysql, alembic, pydantic-settings
2. `app/database/session.py` — engine + session factory
3. Inicializar **Alembic** y generar migración inicial desde los modelos
4. `docker/docker-compose.yml` — MySQL 8
5. `alembic upgrade head` — crear las 18 tablas
6. Seed: UNSA / Ingeniería / Admisión 2026

**Criterio de aceptación inmediato:** `from app.models import Base` registra 18 tablas en `Base.metadata` y la migración Alembic coincide con `schema.sql`.

---

---

## Etapa 0.4 — Repositorios CRUD (catálogo + preguntas)

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Capa de acceso a datos (Repository) para Universidad, Carrera, Área, Tema, Subtema y Pregunta. Sin servicios, sin routers, sin lógica de negocio.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Modelos ORM | ✅ 18 tablas |
| Repositorios CRUD | ✅ 6 entidades + base genérica |
| Session / engine | ⏳ Pendiente (`database/session.py`) |
| Servicios | No implementados |
| API REST | No implementada |
| Migraciones Alembic | No creadas |

Los repositorios están listos para ser consumidos por la capa `services/` una vez exista la session de base de datos.

---

### 2. Qué se implementó

- **`BaseRepository[ModelT]`** — CRUD genérico: `get_by_id`, `list_all`, `create`, `update`, `delete`, `delete_by_id`, `count`.
- **6 repositorios concretos** con consultas por clave foránea del padre directo.
- Carga eager de **`Question.options`** vía `selectinload` (solo acceso a datos, sin reglas).
- Paginación básica (`skip`/`limit`) y filtro `active_only` donde aplica.
- **No** se implementaron servicios, schemas Pydantic, endpoints ni transacciones globales.

---

### 3. Flujo actualizado

```
SQLAlchemy Session  (pendiente: session.py)
        ↓
Repository          ← implementado en esta etapa
        ↓
[Service]           ← futuro: orquestación y reglas de negocio
        ↓
[API Router]        ← futuro: HTTP
```

Ejemplo de uso previsto (sin commit automático en el repositorio):

```python
university = UniversityRepository(session).get_by_code("UNSA")
careers = CareerRepository(session).list_by_university_id(university.id)
areas = AreaRepository(session).list_by_admission_process_id(process_id)
question = QuestionRepository(session).get_by_id_with_options(3501)
session.commit()
```

---

### 4. Archivos creados

```
backend/app/repositories/
├── __init__.py
├── base.py
├── university_repository.py
├── career_repository.py
├── area_repository.py
├── topic_repository.py
├── subtopic_repository.py
└── question_repository.py
```

#### Métodos por repositorio

| Repositorio | Hereda CRUD | Métodos adicionales |
|-------------|-------------|---------------------|
| `UniversityRepository` | ✅ | `get_by_code`, `list_by_country` |
| `CareerRepository` | ✅ | `get_by_university_and_code`, `list_by_university_id` |
| `AreaRepository` | ✅ | `get_by_admission_process_and_name`, `list_by_admission_process_id` |
| `TopicRepository` | ✅ | `get_by_component_and_name`, `list_by_component_id` |
| `SubtopicRepository` | ✅ | `get_by_topic_and_name`, `list_by_topic_id` |
| `QuestionRepository` | ✅ | `get_by_id_with_options`, `list_by_subtopic_id`, `list_by_subtopic_id_with_options`, `list_by_difficulty` |

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `BaseRepository` | Operaciones CRUD reutilizables sobre cualquier modelo |
| `UniversityRepository` | Persistencia de universidades |
| `CareerRepository` | Persistencia de carreras filtradas por universidad |
| `AreaRepository` | Persistencia de áreas filtradas por proceso de admisión |
| `TopicRepository` | Persistencia de temas filtrados por componente |
| `SubtopicRepository` | Persistencia de subtemas filtrados por tema |
| `QuestionRepository` | Persistencia de preguntas filtradas por subtema o dificultad |

**Fuera de alcance:** validar que los pesos de áreas sumen 100 %, autorización, conversión a DTOs, commit/rollback de transacciones.

---

### 6. Dependencias

```
repositories/*  →  models/*  (ORM)
repositories/*  →  sqlalchemy.orm.Session  (inyectada en constructor)
```

| Repositorio | FK de filtrado principal |
|-------------|--------------------------|
| `CareerRepository` | `university_id` |
| `AreaRepository` | `admission_process_id` |
| `TopicRepository` | `component_id` |
| `SubtopicRepository` | `topic_id` |
| `QuestionRepository` | `subtopic_id` |

**Nota:** `Component` y `AdmissionProcess` no tienen repositorio propio en esta etapa; se acceden vía relaciones ORM o en una etapa posterior.

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| R-01 | `BaseRepository` genérico con `TypeVar` | Evita duplicar CRUD en 6 clases |
| R-02 | `Session` inyectada en el constructor | El repositorio no crea ni cierra sesiones; facilita testing con mocks |
| R-03 | `flush()` sin `commit()` en repositorios | La transacción la controla la capa superior (servicio o dependency FastAPI) |
| R-04 | Un archivo por entidad | Localización rápida; archivos pequeños y enfocados |
| R-05 | Filtros por FK del padre directo | Alineado al modelo jerárquico; sin saltar niveles en SQL |
| R-06 | `order_by(display_order)` en área/tema/subtema | Respeta el orden pedagógico definido en el catálogo |
| R-07 | `selectinload` para opciones de pregunta | Evita N+1 al listar preguntas con alternativas |
| R-08 | `active_only` opcional en listados | Soporta soft-delete vía `is_active` sin borrado físico |
| R-09 | Sin repositorio de `Component` en esta etapa | No solicitado; Tema cuelga de Componente y se filtra por `component_id` |
| R-10 | `merge()` en `update()` | Soporta entidades detached provenientes de capas superiores |

---

### 8. Posibles mejoras futuras

- `ComponentRepository` y `AdmissionProcessRepository` para completar el catálogo.
- `QuestionOptionRepository` si las opciones se gestionan por separado.
- Método `exists()` y `get_or_none` con excepciones de dominio en la capa de servicio.
- Paginación con `total` en una sola consulta (window functions o count separado optimizado).
- Repositorio genérico de árbol académico (`get_full_tree(university_id)`) — podría ser servicio, no repositorio.
- Tests unitarios con SQLite in-memory y fixtures de catálogo UNSA.

---

### 9. Próximo paso recomendado

1. `app/database/session.py` — engine, `SessionLocal`, dependency `get_db()`
2. `backend/requirements.txt` y `docker-compose.yml`
3. Alembic + migración inicial
4. **Services** delgados que usen repositorios y hagan `commit()`
5. Routers REST `/api/v1/universities`, `/careers`, `/areas`, `/topics`, `/subtopics`, `/questions`

**Criterio de aceptación inmediato:** con una session activa, `UniversityRepository(session).create(University(...))` + `session.commit()` persiste en MySQL.

---

---

## Etapa 0.5 — Endpoints REST (catálogo + preguntas)

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** API REST FastAPI con GET, POST, PUT y DELETE para Universidad, Carrera, Área, Tema, Subtema y Pregunta. Sin IA, sin agentes, sin capa de servicios.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Modelos ORM | ✅ 18 tablas |
| Repositorios | ✅ 6 entidades |
| Schemas Pydantic | ✅ 6 entidades (Create/Update/Response) |
| Endpoints REST | ✅ 30 rutas CRUD + `/health` |
| Session / config | ✅ Implementados |
| Docker / Alembic | ⏳ Pendiente |
| Auth | No implementado |
| IA / Agentes | No implementado |

La API puede arrancar con `uvicorn app.main:app` cuando MySQL esté disponible y las tablas existan.

---

### 2. Qué se implementó

- **`app/main.py`** — aplicación FastAPI con router `/api/v1`.
- **`app/core/config.py`** — settings con `DATABASE_URL`.
- **`app/database/session.py`** — engine y `SessionLocal`.
- **`app/core/dependencies.py`** — dependency `get_db()`.
- **6 schemas Pydantic** — `Create`, `Update`, `Response` por entidad.
- **6 routers** — CRUD completo por recurso.
- **`GET /health`** — health check.
- **`backend/requirements.txt`** y **`.env.example`**.

**No implementado:** autenticación, servicios, validación de negocio (pesos de áreas), Docker, migraciones, tests de integración.

---

### 3. Flujo actualizado

```
HTTP Request
  → FastAPI Router (/api/v1/...)
    → Pydantic Schema (validación entrada/salida)
      → Repository (acceso a datos)
        → SQLAlchemy Session
          → MySQL
    → db.commit() en el router
```

#### Rutas disponibles

| Recurso | GET list | GET by id | POST | PUT | DELETE |
|---------|----------|-----------|------|-----|--------|
| `/api/v1/universities` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/careers` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/areas` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/topics` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/subtopics` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/questions` | ✅ | ✅ | ✅ | ✅ | ✅ |

#### Query params en listados

| Endpoint | Filtros opcionales |
|----------|-------------------|
| `GET /universities` | `country`, `active_only`, `skip`, `limit` |
| `GET /careers` | `university_id`, `active_only`, `skip`, `limit` |
| `GET /areas` | `admission_process_id`, `active_only`, `skip`, `limit` |
| `GET /topics` | `component_id`, `active_only`, `skip`, `limit` |
| `GET /subtopics` | `topic_id`, `active_only`, `skip`, `limit` |
| `GET /questions` | `subtopic_id`, `difficulty`, `with_options`, `active_only`, `skip`, `limit` |

---

### 4. Archivos creados

```
backend/
├── requirements.txt
├── .env.example
└── app/
    ├── main.py
    ├── core/
    │   ├── config.py
    │   └── dependencies.py
    ├── database/
    │   └── session.py
    ├── schemas/
    │   ├── university.py
    │   ├── career.py
    │   ├── area.py
    │   ├── topic.py
    │   ├── subtopic.py
    │   └── question.py
    └── api/
        ├── helpers.py
        └── v1/
            ├── router.py
            ├── universities.py
            ├── careers.py
            ├── areas.py
            ├── topics.py
            ├── subtopics.py
            └── questions.py
```

---

### 5. Responsabilidades

| Capa | Responsabilidad |
|------|-----------------|
| `main.py` | Factory FastAPI, registro de routers, health check |
| `schemas/` | Validación y serialización HTTP (Pydantic v2) |
| `api/v1/*.py` | Mapeo HTTP → repositorio; `commit()` de transacción |
| `api/helpers.py` | Utilidades HTTP (`apply_update`, `not_found`) |
| `core/dependencies.py` | Inyección de sesión DB por request |
| `repositories/` | Sin cambios; consumidos directamente por routers |

---

### 6. Dependencias

```
main.py → api/v1/router.py → routers → repositories → models
routers → schemas (Pydantic)
routers → core/dependencies.get_db → database/session.py
database/session.py → core/config.settings
```

**Paquetes:** `fastapi`, `uvicorn`, `sqlalchemy`, `pymysql`, `pydantic-settings`.

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| E-01 | Routers llaman repositorios directamente | Alcance acotado a endpoints; servicios se añaden cuando haya reglas de negocio |
| E-02 | `commit()` en el router, no en el repositorio | Mantiene R-03; una transacción por request HTTP |
| E-03 | PUT parcial con `exclude_unset=True` | Actualiza solo campos enviados sin requerir PATCH separado |
| E-04 | DELETE devuelve `204 No Content` | Convención REST estándar |
| E-05 | POST devuelve `201 Created` | Indica recurso creado con body de respuesta |
| E-06 | Filtros por FK como query params en GET list | Reutiliza métodos existentes de repositorios |
| E-07 | `Question` incluye `options` anidadas | CRUD completo de pregunta + alternativas en un solo recurso |
| E-08 | `GET /questions/{id}` siempre carga opciones | Respuesta útil para simulacros y tutor (futuro) |
| E-09 | Prefijo `/api/v1` | Versionado desde el inicio |
| E-10 | Sin auth en v1 de endpoints | Etapa 1 continúa con auth como siguiente módulo |

---

### 8. Posibles mejoras futuras

- Capa `services/` entre router y repositorio para reglas de negocio.
- Manejo global de excepciones (`IntegrityError` → 409 Conflict).
- Paginación con metadata (`total`, `page`, `pages`).
- Autenticación JWT en rutas de escritura.
- Endpoints para `Component` y `AdmissionProcess`.
- Tests de integración con `TestClient` y DB de prueba.
- CORS middleware para cliente Flutter.

---

### 9. Próximo paso recomendado

1. `docker/docker-compose.yml` — MySQL 8 + API
2. Alembic — migración inicial desde modelos
3. Seed script UNSA / Ingeniería / Admisión 2026
4. Probar CRUD completo vía `/docs` (Swagger UI)
5. Módulo `auth/` — registro, login, JWT

**Criterio de aceptación inmediato:**

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
# http://localhost:8000/docs → CRUD funcional con MySQL levantado
```

---

---

## Etapa 2 — Motor de exámenes

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Motor completo de simulacros sin GPT: crear plantilla, seleccionar preguntas por ponderación de áreas, iniciar sesión, guardar respuestas, controlar tiempo, calificar y persistir resultados con desglose jerárquico.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| CRUD catálogo + preguntas | ✅ |
| Motor de exámenes | ✅ |
| Selección por pesos de área | ✅ |
| Control de tiempo | ✅ |
| Calificación + resultados | ✅ |
| Diagnóstico (servicio dedicado) | Incluido en `finish_exam` (snapshot) |
| Auth | ⏳ Pendiente |
| Docker / Alembic | ⏳ Pendiente |
| GPT / Agentes | No implementado |

---

### 2. Qué se implementó

- **`ExamEngineService`** — orquestación del ciclo de vida del examen.
- **Selección automática de preguntas** según `weight_percent` de cada área del proceso de admisión.
- **Sesión de examen** (`student_exams`) con estado `pending → in_progress → completed/expired`.
- **Respuestas** pre-creadas al iniciar; actualización al enviar cada respuesta.
- **Control de tiempo** — cálculo de tiempo restante y expiración automática.
- **Calificación** — comparación con `question_options.is_correct`; omisiones = incorrectas.
- **Resultados materializados** — `exam_results` + desglose por área, componente, tema y subtema.
- **8 endpoints REST** bajo `/api/v1` para el flujo completo del simulacro.
- **Repositorios nuevos** para plantillas, sesiones, respuestas, resultados y selección de preguntas.

---

### 3. Flujo actualizado

```
1. POST /exam-templates
   → Selecciona preguntas por peso de áreas
   → Crea exam_templates + exam_template_questions

2. POST /student-exams
   → Crea student_exams (in_progress, started_at)
   → Pre-crea student_answers vacías

3. GET /student-exams/{id}/time
   → elapsed_seconds, remaining_seconds, is_expired

4. POST /student-exams/{id}/answers
   → Guarda selected_option_id, time_seconds
   → Califica respuesta individual (is_correct)

5. POST /student-exams/{id}/finish
   → Marca omisiones como incorrectas
   → Calcula score_percent global
   → Guarda exam_results + exam_result_{areas,components,topics,subtopics}
   → status = completed

6. GET /student-exams/{id}/results
   → Consulta resultados y matriz de diagnóstico
```

#### Endpoints del motor

| Método | Ruta | Función |
|--------|------|---------|
| POST | `/api/v1/exam-templates` | Crear plantilla + seleccionar preguntas |
| GET | `/api/v1/exam-templates/{id}` | Obtener plantilla |
| POST | `/api/v1/student-exams` | Iniciar examen |
| GET | `/api/v1/student-exams/{id}` | Examen con preguntas (sin revelar correctas) |
| GET | `/api/v1/student-exams/{id}/time` | Tiempo restante |
| POST | `/api/v1/student-exams/{id}/answers` | Guardar respuesta |
| POST | `/api/v1/student-exams/{id}/finish` | Finalizar y calificar |
| GET | `/api/v1/student-exams/{id}/results` | Resultados + desglose |

---

### 4. Archivos creados

```
backend/app/
├── exams/
│   ├── __init__.py
│   ├── exceptions.py
│   └── exam_engine_service.py
├── repositories/
│   ├── exam_template_repository.py
│   ├── student_exam_repository.py
│   ├── student_answer_repository.py
│   ├── exam_result_repository.py
│   ├── student_repository.py
│   └── question_selection_repository.py
├── schemas/
│   └── exam.py
└── api/v1/
    └── exams.py
```

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `ExamEngineService` | Lógica del simulacro: selección, tiempo, calificación, resultados |
| `QuestionSelectionRepository` | Queries SQL para preguntas aleatorias por área/proceso |
| `ExamTemplateRepository` | Plantillas con preguntas cargadas (eager) |
| `StudentExamRepository` | Sesiones con preguntas, grading y resultados |
| `StudentAnswerRepository` | Respuestas por examen + pregunta |
| `ExamResultRepository` | Persistencia de resultado global y desglose |
| `api/v1/exams.py` | HTTP → servicio; oculta `is_correct` en preguntas del examen |
| `exams/exceptions.py` | Errores de dominio del motor |

---

### 6. Dependencias

```
api/v1/exams.py
  → ExamEngineService
    → ExamTemplateRepository, StudentExamRepository, StudentAnswerRepository
    → ExamResultRepository, AreaRepository, QuestionSelectionRepository
    → StudentRepository
    → models (ExamTemplate, StudentExam, StudentAnswer, ExamResult, ...)
```

**Cadena académica para selección y diagnóstico:**

```
Question → Subtopic → Topic → Component → Area (weight_percent)
```

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| X-01 | Servicio dedicado `ExamEngineService` | La lógica de examen supera el CRUD simple de repositorios |
| X-02 | Selección por `weight_percent` de áreas | Alineado al modelo UNSA y al diseño DB-02 |
| X-03 | `func.rand()` para aleatoriedad | Distribución equitativa dentro de cada área en MySQL |
| X-04 | Pre-crear `student_answers` al iniciar | Garantiza un slot por pregunta; simplifica envío de respuestas |
| X-05 | Calificación inmediata al enviar respuesta | Feedback parcial posible; `finish` recalcula omisiones |
| X-06 | Omisiones = incorrectas al finalizar | Comportamiento estándar de examen cronometrado |
| X-07 | Expiración → `status=expired`; finish permite calificar | No se pierden respuestas ya enviadas |
| X-08 | Snapshot de desglose en 4 tablas | Diagnóstico sin recalcular (D-05, DB-07) |
| X-09 | Opciones sin `is_correct` en GET del examen | Evita filtrar respuestas correctas durante el simulacro |
| X-10 | `datetime.utcnow()` para tiempos | Consistencia en servidor; timezone UTC explícito |
| X-11 | Sin GPT en ningún paso | Etapa 2 es Python puro según roadmap |

---

### 8. Posibles mejoras futuras

- Bloquear envío de respuestas tras expiración y forzar `finish` automático.
- Selección estratificada por dificultad además de área.
- Evitar repetir preguntas entre simulacros del mismo estudiante.
- Endpoint `GET /students/{id}/exams` (repositorio ya tiene `list_by_student_id`).
- Transacciones con retry ante conflictos de concurrencia.
- WebSocket para countdown en tiempo real (Flutter).
- Tests de integración del flujo completo end-to-end.

---

### 9. Próximo paso recomendado

1. **Etapa 4 formal** — servicio `DiagnosticsService` que lea snapshots (ya generados) y produzca fortalezas/debilidades.
2. **Etapa 5** — `RecommendationsService` con reglas (`if score < 50 → video`).
3. Docker + Alembic + seed UNSA para probar flujo completo en `/docs`.
4. Módulo `auth/` — asociar `student_id` al usuario autenticado.

**Criterio de aceptación del motor:**

```bash
# 1. Crear plantilla
POST /api/v1/exam-templates
# 2. Iniciar examen
POST /api/v1/student-exams
# 3. Responder preguntas
POST /api/v1/student-exams/{id}/answers
# 4. Finalizar
POST /api/v1/student-exams/{id}/finish
# 5. Ver matriz
GET /api/v1/student-exams/{id}/results
```

---

---

## Etapa 2.1 — Verificación del motor de exámenes

**Fecha:** 2026-06-26  
**Responsable:** Revisión de consolidación con Cursor  
**Alcance:** Confirmar que el motor de exámenes (Etapa 2) cumple todos los requisitos solicitados. Sin cambios de código en esta entrada — la implementación ya existía.

---

### 1. Estado del proyecto

| Requisito | Estado | Ubicación |
|-----------|--------|-----------|
| Crear examen | ✅ | `ExamEngineService.create_exam_template()` |
| Seleccionar preguntas | ✅ | `_select_questions_by_area_weights()` |
| Guardar respuestas | ✅ | `submit_answer()` → `student_answers` |
| Controlar tiempo | ✅ | `get_time_status()`, `_mark_expired_if_needed()` |
| Calificar | ✅ | `submit_answer()` + `_grade_unanswered()` |
| Guardar resultados | ✅ | `_save_results()` → `exam_results` + desglose |
| Sin GPT | ✅ | Solo Python / SQLAlchemy |

El motor está operativo vía 8 endpoints en `/api/v1`. Pendiente: Docker, Alembic y datos seed para prueba end-to-end en MySQL.

---

### 2. Qué se implementó

**Nada nuevo en esta etapa.** Se verificó la implementación existente de la Etapa 2:

- `backend/app/exams/exam_engine_service.py` (456 líneas)
- `backend/app/exams/exceptions.py`
- `backend/app/api/v1/exams.py`
- `backend/app/schemas/exam.py`
- 6 repositorios de soporte en `backend/app/repositories/`

---

### 3. Flujo actualizado

Sin cambios respecto a la Etapa 2. Flujo de referencia:

```
POST /api/v1/exam-templates
  → Selección por weight_percent de áreas
POST /api/v1/student-exams
  → status=in_progress, started_at, student_answers vacías
GET  /api/v1/student-exams/{id}/time
  → remaining_seconds, is_expired
POST /api/v1/student-exams/{id}/answers
  → Guarda opción + califica (is_correct)
POST /api/v1/student-exams/{id}/finish
  → Omisiones=false, exam_results + exam_result_*
GET  /api/v1/student-exams/{id}/results
  → Matriz área → subtema
```

---

### 4. Archivos creados

Ningún archivo nuevo en la Etapa 2.1. Inventario confirmado de la Etapa 2:

| Archivo | Rol |
|---------|-----|
| `exams/exam_engine_service.py` | Motor principal |
| `exams/exceptions.py` | Errores de dominio |
| `api/v1/exams.py` | Endpoints REST |
| `schemas/exam.py` | DTOs Pydantic |
| `repositories/exam_template_repository.py` | Plantillas |
| `repositories/student_exam_repository.py` | Sesiones |
| `repositories/student_answer_repository.py` | Respuestas |
| `repositories/exam_result_repository.py` | Resultados |
| `repositories/question_selection_repository.py` | Selección aleatoria por área |
| `repositories/student_repository.py` | Validación de estudiante |

---

### 5. Responsabilidades

| Capacidad | Componente | Método / endpoint |
|-----------|------------|-------------------|
| Crear examen | `ExamEngineService` | `create_exam_template` / `POST /exam-templates` |
| Seleccionar preguntas | `QuestionSelectionRepository` + servicio | `_select_questions_by_area_weights` |
| Guardar respuestas | `ExamEngineService` | `submit_answer` / `POST .../answers` |
| Controlar tiempo | `ExamEngineService` | `get_time_status` / `GET .../time` |
| Calificar | `ExamEngineService` | `submit_answer`, `_grade_unanswered`, `finish_exam` |
| Guardar resultados | `ExamEngineService` | `_save_results` / `POST .../finish` |

---

### 6. Dependencias

```
api/v1/exams.py
  └── ExamEngineService
        ├── ExamTemplateRepository
        ├── StudentExamRepository
        ├── StudentAnswerRepository
        ├── ExamResultRepository
        ├── AreaRepository
        ├── QuestionSelectionRepository
        └── StudentRepository
```

---

### 7. Decisiones tomadas

| # | Decisión | Nota |
|---|----------|------|
| V-01 | No reimplementar el motor | La Etapa 2 ya cubría el alcance completo |
| V-02 | Documentar mapeo requisito → código | Facilita onboarding de nuevos desarrolladores |
| V-03 | Mantener GPT fuera del motor | Confirmado: ningún import de LLM en `exams/` |

---

### 8. Posibles mejoras futuras

(Ver Etapa 2, sección 8.) Prioridad inmediata:

- Docker + Alembic + seed UNSA para probar el flujo en base real.
- Tests de integración automatizados del ciclo completo.
- `GET /api/v1/students/{id}/exams` — listar historial (repositorio listo).

---

### 9. Próximo paso recomendado

**No volver a implementar el motor.** Continuar con:

1. `docker-compose.yml` + Alembic + migración inicial
2. Seed: UNSA / Ingeniería / Admisión 2026 / áreas con pesos / preguntas de prueba
3. Probar en Swagger (`/docs`) el flujo de 5 pasos de la Etapa 2
4. Etapa 4 — `DiagnosticsService` sobre snapshots ya guardados

---

---

## Etapa 4 — Diagnóstico académico

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Sistema de diagnóstico post-examen con porcentajes por área, componente, tema y subtema. Reglas de negocio fijas (fortalezas/debilidades). Sin IA.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Motor de exámenes | ✅ Genera snapshots en `exam_result_*` |
| Diagnóstico académico | ✅ `DiagnosticService` + endpoints REST |
| Clasificación fortalezas/debilidades | ✅ Umbrales 70 % / 50 % |
| Recálculo desde respuestas | ✅ Fallback si faltan snapshots |
| Recomendaciones | ⏳ Etapa 5 |
| GPT / Agentes | No implementado |

---

### 2. Qué se implementó

- **`DiagnosticService`** — lee snapshots o recalcula desde `student_answers`.
- **Porcentajes en 4 niveles** — área, componente, tema, subtema.
- **Clasificación por reglas:**
  - `>= 70 %` → `strength` (fortaleza)
  - `< 50 %` → `weakness` (debilidad)
  - entre 50–70 % → `neutral`
- **Listas `strengths` y `weaknesses`** derivadas de temas y subtemas.
- **`DiagnosticRepository`** — carga snapshots con nombres de entidades académicas.
- **5 endpoints REST** bajo `/api/v1/diagnostics`.

---

### 3. Flujo actualizado

```
POST /api/v1/student-exams/{id}/finish
  → exam_results + exam_result_{areas,components,topics,subtopics}
        ↓
GET /api/v1/diagnostics/student-exams/{id}
  → DiagnosticService.get_diagnostic()
        ↓
  Lee snapshots (ruta principal)
  o recalcula desde student_answers (fallback)
        ↓
  Aplica reglas STRENGTH_THRESHOLD / WEAKNESS_THRESHOLD
        ↓
  DiagnosticReportResponse
    ├── areas[]      (score_percent, level)
    ├── components[]
    ├── topics[]
    ├── subtopics[]
    ├── strengths[]
    └── weaknesses[]
```

#### Endpoints de diagnóstico

| Método | Ruta | Respuesta |
|--------|------|-----------|
| GET | `/api/v1/diagnostics/student-exams/{id}` | Informe completo |
| GET | `/api/v1/diagnostics/student-exams/{id}/areas` | Solo áreas |
| GET | `/api/v1/diagnostics/student-exams/{id}/components` | Solo componentes |
| GET | `/api/v1/diagnostics/student-exams/{id}/topics` | Solo temas |
| GET | `/api/v1/diagnostics/student-exams/{id}/subtopics` | Solo subtemas |

---

### 4. Archivos creados

```
backend/app/
├── diagnostics/
│   ├── __init__.py
│   ├── rules.py              # Umbrales 70 % / 50 %
│   ├── exceptions.py
│   └── diagnostic_service.py
├── repositories/
│   └── diagnostic_repository.py
├── schemas/
│   └── diagnostic.py
└── api/v1/
    └── diagnostics.py
```

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `DiagnosticService` | Orquestar lectura/recálculo y clasificación |
| `DiagnosticRepository` | Queries con eager load de nombres académicos |
| `rules.py` | Umbrales configurables de fortaleza/debilidad |
| `api/v1/diagnostics.py` | Exponer informe y vistas por nivel |
| `exam_engine_service._save_results` | Materializa snapshots al finalizar (Etapa 2) |

---

### 6. Dependencias

```
api/v1/diagnostics.py
  → DiagnosticService
    → DiagnosticRepository
      → StudentExam + exam_result_* + relaciones académicas
```

**Prerequisito:** examen con `status=completed` y datos en `exam_result_*` (o respuestas calificadas para fallback).

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| Dg-01 | Leer snapshots como ruta principal | Evita recalcular; alineado a DB-07 y D-05 |
| Dg-02 | Fallback: recálculo desde `student_answers` | Resiliencia si snapshots incompletos |
| Dg-03 | Umbrales fijos en `rules.py` | Reglas explícitas sin IA; fáciles de ajustar |
| Dg-04 | `>= 70 %` fortaleza, `< 50 %` debilidad | Criterio estándar de la conversación de diseño |
| Dg-05 | Fortalezas/debilidades desde temas + subtemas | Granularidad útil para plan de estudio (Etapa 5) |
| Dg-06 | Endpoints separados de `/results` | `/results` = datos crudos; `/diagnostics` = perfil interpretado |
| Dg-07 | Requiere examen `completed` | Diagnóstico solo tiene sentido post-simulacro |
| Dg-08 | Sin GPT ni LLM | Etapa 4 es analítica pura según roadmap |

---

### 8. Posibles mejoras futuras

- Umbrales configurables por universidad o proceso de admisión.
- Diagnóstico agregado multi-examen (`GET /students/{id}/diagnostics`).
- Persistir `diagnostic_snapshots` como entidad propia si se necesita historial inmutable.
- Gráficos de barras pre-calculados para Flutter.
- Tests unitarios de `_classify` y `_build_from_answers`.

---

### 9. Próximo paso recomendado

**Etapa 5 — Recomendaciones:**

1. `RecommendationsService` que consuma `DiagnosticReport.weaknesses`.
2. Reglas: `if subtopic < 50 %` → asignar video; `if < 40 %` → ejercicios; etc.
3. Endpoint `GET /api/v1/recommendations/student-exams/{id}`.
4. Docker + Alembic + seed para probar flujo examen → diagnóstico → recomendación.

**Criterio de aceptación Etapa 4:**

```bash
POST /api/v1/student-exams/{id}/finish
GET  /api/v1/diagnostics/student-exams/{id}
# → areas[], components[], topics[], subtopics[] con score_percent
# → strengths[], weaknesses[]
```

---

---

## Etapa 5 — Recomendaciones (reglas)

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Plan de estudio automático basado en diagnóstico y reglas de negocio extensibles. Sin GPT.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Diagnóstico (Etapa 4) | ✅ |
| Recomendaciones por reglas | ✅ |
| Registro extensible de reglas | ✅ `RecommendationRuleRegistry` |
| Persistencia de planes | No (generación on-the-fly) |
| Vinculación a recursos reales (PDF/video) | ⏳ Futuro (tabla `resources`) |
| GPT / Agentes | No implementado |

---

### 2. Qué se implementó

- **`RecommendationRuleRegistry`** — registro extensible de reglas por rango de porcentaje.
- **3 reglas por defecto:**
  - `< 40 %` → `video`
  - `40 % – 70 %` → `exercises`
  - `> 70 %` → `mock_exam`
- **`RecommendationService`** — consume `DiagnosticService` y genera `StudyPlan`.
- **`StudyPlan`** — recomendaciones por subtema, `focus_subtopics`, `estimated_days`, agrupación por tipo de recurso.
- **2 endpoints REST** + listado de reglas activas.
- **`ResourceType` enum** — extensible (`pdf`, `flashcards` reservados).

---

### 3. Flujo actualizado

```
POST /student-exams/{id}/finish
  → snapshots de resultados
GET  /diagnostics/student-exams/{id}
  → DiagnosticReport (porcentajes por nivel)
GET  /recommendations/student-exams/{id}
  → RecommendationService.get_study_plan()
    → Por cada subtema: RuleRegistry.resolve(score_percent)
    → StudyPlan con mensajes y recursos sugeridos
```

#### Reglas por defecto

| Rango | Recurso | rule_id |
|-------|---------|---------|
| 0 % – 39.99 % | `video` | `critical_video` |
| 40 % – 70 % | `exercises` | `practice_exercises` |
| 70.01 % – 100 % | `mock_exam` | `maintain_mock_exam` |

#### Endpoints

| Método | Ruta | Función |
|--------|------|---------|
| GET | `/api/v1/recommendations/student-exams/{id}` | Plan de estudio completo |
| GET | `/api/v1/recommendations/rules` | Reglas activas (extensibilidad) |

---

### 4. Archivos creados

```
backend/app/
├── recommendations/
│   ├── __init__.py
│   ├── types.py              # ResourceType enum
│   ├── rules.py              # RecommendationRule + Registry
│   ├── exceptions.py
│   └── recommendation_service.py
├── schemas/
│   └── recommendation.py
└── api/v1/
    └── recommendations.py
```

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `RecommendationRule` | Define rango, recurso, prioridad y mensaje |
| `RecommendationRuleRegistry` | Registro y resolución de reglas (`register`, `resolve`) |
| `RecommendationService` | Diagnóstico → plan de estudio |
| `StudyPlan` | DTO con recomendaciones, foco y días estimados |
| `api/v1/recommendations.py` | HTTP; expone plan y reglas |

---

### 6. Dependencias

```
api/v1/recommendations.py
  → RecommendationService
    → DiagnosticService (Etapa 4)
    → RecommendationRuleRegistry
```

**Extensión futura:**

```python
registry = RecommendationRuleRegistry()
registry.register(RecommendationRule(
    id="add_flashcards",
    resource_type=ResourceType.FLASHCARDS,
    min_percent=Decimal("30"),
    max_percent=Decimal("50"),
    priority=15,
    message_template="Repasa {entity} con flashcards.",
))
service = RecommendationService(session, rule_registry=registry)
```

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| Rc-01 | `RecommendationRuleRegistry` extensible | Nuevas reglas sin modificar el servicio |
| Rc-02 | Reglas por rango `[min, max]` inclusive | Modelo claro; fácil de auditar |
| Rc-03 | Prioridad numérica en reglas | Permite solapamiento controlado al extender |
| Rc-04 | Recomendación por subtema (fallback: tema) | Máxima granularidad para el plan de estudio |
| Rc-05 | Sin persistencia en v1 | Plan se regenera; evita migración nueva |
| Rc-06 | `estimated_days = clamp(focus_count, 3, 14)` | Heurística simple sin IA |
| Rc-07 | `by_resource_type` en respuesta | Facilita UI Flutter (secciones Video / Ejercicios / Simulacro) |
| Rc-08 | Endpoint `/rules` público | Documenta comportamiento y facilita debugging |
| Rc-09 | Sin GPT | Coherente con roadmap Etapa 5 |

---

### 8. Posibles mejoras futuras

- Persistir `study_plans` y `study_recommendations` en MySQL.
- Vincular `ResourceType` a registros reales en tabla `resources` (URLs de PDF/video).
- Reglas por universidad o carrera (config en BD).
- Reglas por `PerformanceLevel` además de porcentaje exacto.
- Notificaciones push con plan diario.
- Tests unitarios del registry con reglas solapadas.

---

### 9. Próximo paso recomendado

1. **Infraestructura** — Docker + Alembic + seed UNSA para probar flujo completo:
   `examen → finish → diagnostics → recommendations`
2. **Tabla `resources`** — vincular subtemas con PDF/video/flashcards reales.
3. **Etapa 6** — RAG (ChromaDB) para indexar esos recursos.
4. **Auth** — asociar estudiante autenticado al flujo.

**Criterio de aceptación Etapa 5:**

```bash
GET /api/v1/recommendations/student-exams/{id}
# → recommendations[] con resource_type: video|exercises|mock_exam
# → focus_subtopics[], estimated_days
GET /api/v1/recommendations/rules
# → 3 reglas por defecto
```

---

---

## Etapa 6 — RAG (ChromaDB)

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Pipeline RAG completo: loader, chunking, embeddings, ChromaDB y búsqueda vectorial. Sin agentes ni GPT.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Loader (PDF, TXT, MD) | ✅ |
| Chunking con solapamiento | ✅ |
| Embeddings locales | ✅ `sentence-transformers` |
| ChromaDB persistente | ✅ |
| Búsqueda vectorial filtrada por subtema | ✅ |
| API REST `/rag` | ✅ |
| Agentes / Tutor GPT | No implementado |

---

### 2. Qué se implementó

- **`DocumentLoader`** — carga texto plano, `.txt`, `.md`, `.pdf` (pypdf).
- **`TextChunker`** — fragmentos de 800 caracteres con solapamiento de 120.
- **`SentenceTransformerEmbeddings`** — modelo `all-MiniLM-L6-v2` (384 dimensiones).
- **`ChromaStore`** — cliente persistente, cosine similarity, filtros por metadata.
- **`RAGService`** — orquesta ingestión y búsqueda.
- **4 endpoints REST** bajo `/api/v1/rag`.
- **Config** en `core/config.py` y `.env.example`.

---

### 3. Flujo actualizado

#### Flujo de indexación (ingest)

```
Material educativo (PDF / texto / MD)
        ↓
   DocumentLoader          → texto completo + metadata
        ↓
   TextChunker             → fragmentos (~800 chars, overlap 120)
        ↓
   EmbeddingProvider       → vectores (384 dims)
        ↓
   ChromaStore.add_chunks  → pitagoras_knowledge (persistido en disco)
```

#### Flujo de búsqueda (retrieval)

```
Pregunta del estudiante / consulta del tutor (futuro)
        ↓
   Metadata filter         → subtopic_id / topic_id / area_id (KGAA)
        ↓
   embed_query()           → vector de la consulta
        ↓
   ChromaDB.query          → top_k fragmentos más similares (cosine)
        ↓
   VectorSearchResult[]    → texto + score + metadata
        ↓
   [Futuro Etapa 7] LLM    → respuesta contextualizada
```

#### Integración con el KGAA

Cada chunk almacena metadata académica:

```json
{
  "subtopic_id": 12,
  "topic_id": 5,
  "area_id": 2,
  "title": "Fracciones - apuntes",
  "source": "fracciones.pdf",
  "chunk_index": 0
}
```

La búsqueda filtra **antes** del matching vectorial, igual que diseñó la arquitectura: el grafo acotará el RAG.

#### Endpoints

| Método | Ruta | Función |
|--------|------|---------|
| POST | `/api/v1/rag/ingest/text` | Indexar texto plano |
| POST | `/api/v1/rag/ingest/file` | Indexar PDF/TXT/MD |
| POST | `/api/v1/rag/search` | Búsqueda vectorial |
| GET | `/api/v1/rag/stats` | Estadísticas de la colección |

---

### 4. Archivos creados

```
backend/app/
├── rag/
│   ├── __init__.py
│   ├── exceptions.py
│   ├── loader.py
│   ├── chunking.py
│   ├── embeddings.py
│   ├── chroma.py
│   └── rag_service.py
├── schemas/
│   └── rag.py
└── api/v1/
    └── rag.py
```

**Dependencias añadidas:** `chromadb`, `sentence-transformers`, `pypdf`, `python-multipart`.

---

### 5. Responsabilidades

| Módulo | Responsabilidad |
|--------|-----------------|
| `loader.py` | Extraer texto de fuentes (archivo o inline) |
| `chunking.py` | Dividir en fragmentos indexables con overlap |
| `embeddings.py` | Convertir texto → vectores (`EmbeddingProvider` extensible) |
| `chroma.py` | Persistencia y query vectorial en ChromaDB |
| `rag_service.py` | Orquestar ingest + search; filtros KGAA |
| `api/v1/rag.py` | Exponer indexación y búsqueda vía HTTP |

---

### 6. Dependencias

```
api/v1/rag.py → RAGService
  → DocumentLoader
  → TextChunker
  → SentenceTransformerEmbeddings
  → ChromaStore (chromadb.PersistentClient)
```

**Variables de entorno:**

| Variable | Default |
|----------|---------|
| `CHROMA_PERSIST_DIRECTORY` | `./data/chroma` |
| `CHROMA_COLLECTION_NAME` | `pitagoras_knowledge` |
| `EMBEDDING_MODEL` | `all-MiniLM-L6-v2` |
| `RAG_CHUNK_SIZE` | `800` |
| `RAG_CHUNK_OVERLAP` | `120` |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| RG-01 | `sentence-transformers` local | Embeddings sin API key; coherente con "sin GPT" en esta etapa |
| RG-02 | `EmbeddingProvider` abstracto | Permite cambiar a OpenAI/Cohere en Etapa 7 sin reescribir Chroma |
| RG-03 | ChromaDB persistente en disco | Los vectores sobreviven reinicios; no requiere servidor aparte en dev |
| RG-04 | Cosine similarity | Estándar para embeddings de oraciones |
| RG-05 | Metadata `subtopic_id` en cada chunk | Filtrado KGAA antes de búsqueda vectorial |
| RG-06 | Chunk 800 / overlap 120 | Balance contexto vs granularidad para material educativo |
| RG-07 | Score = `1 - distance` | Normaliza distancia coseno a similitud 0–1 |
| RG-08 | Sin agentes en esta etapa | RAG es infraestructura; Tutor IA viene en Etapa 7 |
| RG-09 | Upload multipart para PDFs | Permite indexar material desde admin sin rutas de servidor |

---

### 8. Posibles mejoras futuras

- Indexación automática al subir recursos en tabla `resources` (MySQL → RAG).
- Embeddings OpenAI `text-embedding-3-small` vía `OpenAIEmbeddingProvider`.
- Re-ranking con cross-encoder tras búsqueda vectorial.
- Eliminar chunks obsoletos al actualizar un recurso.
- Docker volume para `./data/chroma`.
- Indexar explicaciones de preguntas (`questions.explanation`) automáticamente.

---

### 9. Próximo paso recomendado

**Etapa 7 — Tutor IA (sin agentes LangGraph aún):**

1. `llm/` — cliente OpenAI/Gemini.
2. Endpoint `POST /api/v1/tutor/explain` que:
   - Recibe `question_id` o `subtopic_id`
   - Busca en RAG con filtro de subtema
   - Construye prompt con fragmentos recuperados
   - Llama al LLM
3. Docker Compose con volumen para ChromaDB.

**Criterio de aceptación Etapa 6:**

```bash
POST /api/v1/rag/ingest/text  {"text":"...", "subtopic_id": 1}
POST /api/v1/rag/search       {"query":"suma de fracciones", "subtopic_id": 1}
GET  /api/v1/rag/stats
```

---

---

## Etapa 7 — Tutor IA (LLM + RAG)

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Tutor IA único que recibe una pregunta, resuelve el subtema, consulta ChromaDB, construye el prompt y llama al LLM. Sin LangGraph ni agentes múltiples.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| RAG (ChromaDB) | ✅ |
| Tutor IA único | ✅ `TutorService` |
| Cliente LLM OpenAI | ✅ |
| Cliente LLM Gemini | ✅ |
| Endpoint `/tutor/explain` | ✅ |
| LangGraph / multi-agente | No implementado |
| Google ADK | No implementado |

---

### 2. Qué se implementó

- **`TutorService`** — orquesta el flujo completo pregunta → explicación.
- **`LLMProvider`** — interfaz extensible con implementaciones OpenAI y Gemini.
- **`prompts/tutor_prompt.py`** — system prompt y plantilla de usuario.
- **`QuestionRepository.get_with_academic_context()`** — carga jerarquía KGAA completa.
- **`POST /api/v1/tutor/explain`** — endpoint único del tutor.
- Configuración LLM en `core/config.py` y `.env.example`.

---

### 3. Flujo actualizado

```
POST /api/v1/tutor/explain  { "question_id": 3501 }
        │
        ▼
┌───────────────────────┐
│ 1. Cargar pregunta    │  MySQL: question + options + subtopic → área
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 2. Resolver subtema   │  AcademicContext (área, componente, tema, subtema)
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 3. Buscar en ChromaDB │  RAGService.search(stem, subtopic_id=...)
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 4. Construir prompt   │  TUTOR_SYSTEM_PROMPT + TUTOR_USER_TEMPLATE
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 5. Consultar LLM      │  OpenAI o Gemini (configurable)
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 6. Devolver explicación│  explanation + context + rag_sources
└───────────────────────┘
```

#### Ejemplo de request

```json
POST /api/v1/tutor/explain
{
  "question_id": 3501,
  "student_message": "No entiendo por qué no es la opción C",
  "selected_option_id": 42
}
```

#### Ejemplo de response

```json
{
  "question_id": 3501,
  "explanation": "Para sumar fracciones con distinto denominador...",
  "academic_context": {
    "subtopic_name": "Suma de fracciones",
    "topic_name": "Fracciones",
    "area_name": "Matemática"
  },
  "rag_sources": [{ "score": 0.87, "text": "..." }],
  "llm_model": "gpt-4o-mini",
  "llm_provider": "openai"
}
```

---

### 4. Archivos creados

```
backend/app/
├── agents/
│   ├── __init__.py
│   ├── exceptions.py
│   └── tutor_service.py
├── llm/
│   ├── __init__.py
│   └── provider.py
├── prompts/
│   ├── __init__.py
│   └── tutor_prompt.py
├── schemas/
│   └── tutor.py
└── api/v1/
    └── tutor.py
```

**Modificados:** `question_repository.py`, `core/config.py`, `api/v1/router.py`, `requirements.txt`, `.env.example`.

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `TutorService` | Orquestar flujo completo del tutor |
| `QuestionRepository.get_with_academic_context` | Resolver KGAA desde `question_id` |
| `RAGService.search` | Retrieval filtrado por `subtopic_id` |
| `prompts/tutor_prompt.py` | Plantillas de system y user prompt |
| `LLMProvider` | Abstracción OpenAI / Gemini |
| `api/v1/tutor.py` | Endpoint HTTP |

---

### 6. Dependencias

```
api/v1/tutor.py
  → TutorService
    → QuestionRepository (MySQL)
    → RAGService (ChromaDB)
    → LLMProvider (OpenAI / Gemini)
    → prompts/tutor_prompt.py
```

**Variables de entorno:**

| Variable | Descripción |
|----------|-------------|
| `LLM_PROVIDER` | `openai` o `gemini` |
| `OPENAI_API_KEY` | Clave API OpenAI |
| `OPENAI_MODEL` | Ej. `gpt-4o-mini` |
| `GEMINI_API_KEY` | Clave API Google Gemini |
| `GEMINI_MODEL` | Ej. `gemini-2.0-flash` |
| `TUTOR_RAG_TOP_K` | Fragmentos RAG a incluir (default 5) |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| T-01 | Un solo `TutorService`, sin LangGraph | Alcance Etapa 7: tutor único, no orquestación multi-agente |
| T-02 | `question_id` como entrada principal | El sistema ya conoce el contexto vía FK a subtema |
| T-03 | RAG filtrado por `subtopic_id` | Alineado al diseño KGAA; precisión del retrieval |
| T-04 | `LLMProvider` abstracto | Cambiar OpenAI ↔ Gemini sin tocar el tutor |
| T-05 | Prompts en archivo dedicado | Fácil iterar sin modificar lógica |
| T-06 | Incluir `rag_sources` en respuesta | Transparencia y debugging; útil para Flutter |
| T-07 | `temperature=0.3` en OpenAI | Explicaciones consistentes y pedagógicas |
| T-08 | Errores LLM como 502/503 | Distingue config vs fallo del proveedor |
| T-09 | `selected_option_id` opcional | Personaliza explicación cuando el estudiante falla |

---

### 8. Posibles mejoras futuras

- Streaming de la respuesta (`StreamingResponse`).
- Cache de explicaciones por `question_id`.
- Indexar automáticamente `questions.explanation` en ChromaDB.
- Historial de conversación multi-turno.
- LangGraph + agentes especializados (Etapa 8).
- Google ADK como wrapper formal del tutor.

---

### 9. Próximo paso recomendado

1. **Docker Compose** — API + MySQL + volumen ChromaDB.
2. **Seed UNSA** — preguntas + material RAG indexado por subtema.
3. Probar flujo: `ingest → exam → finish → diagnostics → recommendations → tutor/explain`.
4. **Etapa 8** — LangGraph solo si se necesitan agentes adicionales (Motivador, Padres).

**Criterio de aceptación Etapa 7:**

```bash
# Configurar OPENAI_API_KEY en .env
POST /api/v1/rag/ingest/text {"text":"...", "subtopic_id": 1}
POST /api/v1/tutor/explain {"question_id": 1}
# → explanation con contexto académico y rag_sources
```

---

*Última actualización: 2026-06-26 — Etapa 7 completada.*

---

## Etapa 8 — Tutor Google ADK

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Transformar el Tutor IA en un agente formal con Google ADK (Agent, Tools, Instructions, Configuration). Sin LangGraph ni agentes adicionales (Motivador, Padres).

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Tutor IA (Etapa 7) | ✅ Base funcional |
| Agente Google ADK | ✅ `agents/tutor/` |
| Tools (`get_question_context`, `search_subtopic_material`) | ✅ |
| Instructions (static + dynamic) | ✅ |
| Configuration ADK | ✅ `agents/tutor/config.py` |
| Endpoint `/tutor/explain` | ✅ (misma API, motor ADK) |
| LangGraph / multi-agente | No implementado |
| Agentes Motivador / Padres | No implementado |

---

### 2. Qué se implementó

- **`agents/tutor/agent.py`** — define el agente ADK (`get_root_agent`) con modelo, instrucciones y tools.
- **`agents/tutor/tools.py`** — herramientas:
  - `get_question_context(question_id)` — carga pregunta + jerarquía KGAA desde MySQL.
  - `search_subtopic_material(query, subtopic_id, top_k)` — retrieval RAG filtrado por subtema.
- **`agents/tutor/instructions.py`** — `TUTOR_STATIC_INSTRUCTION` (reglas pedagógicas) y `TUTOR_AGENT_INSTRUCTION` (flujo de uso de tools).
- **`agents/tutor/config.py`** — `TutorAgentConfig`, resolución de modelo ADK (Gemini nativo / OpenAI vía LiteLlm).
- **`agents/tutor/runtime.py`** — contexto de ejecución (`contextvars`) para inyectar sesión DB y RAG en las tools.
- **`agents/types.py`** — `AcademicContext`, `TutorExplanation` (tipos compartidos).
- **`TutorService` refactorizado** — ejecuta el agente con `InMemoryRunner` de ADK en lugar de llamar al LLM directamente.
- **Dependencia** `google-adk[extensions]>=2.0.0` en `requirements.txt`.

---

### 3. Flujo actualizado

```
POST /api/v1/tutor/explain  { "question_id": 3501 }
        │
        ▼
┌───────────────────────┐
│ TutorService          │  Valida question_id; inicializa TutorRuntimeContext
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ InMemoryRunner (ADK)  │  Sesión efímera por request
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ Agente pitagoras_tutor│  instruction → decide usar tools
└───────────┬───────────┘
            ├─► get_question_context(question_id)     → MySQL + KGAA
            ├─► search_subtopic_material(query, ...)  → ChromaDB RAG
            ▼
┌───────────────────────┐
│ Respuesta del LLM     │  Explicación paso a paso (Gemini / OpenAI)
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ TutorExplanation      │  explanation + academic_context + rag_sources
└───────────────────────┘
```

#### Contrato API (sin cambios)

El endpoint `POST /api/v1/tutor/explain` mantiene el mismo request/response de la Etapa 7. El cambio es interno: el motor pasa de `LLMProvider.generate()` directo a un agente ADK con herramientas.

---

### 4. Archivos creados

```
backend/app/
├── agents/
│   ├── types.py                    # AcademicContext, TutorExplanation
│   └── tutor/
│       ├── __init__.py
│       ├── agent.py                # Agent ADK
│       ├── config.py               # Configuration
│       ├── instructions.py         # Instructions
│       ├── runtime.py              # Contexto para tools
│       └── tools.py                # Tools
```

**Modificados:** `agents/tutor_service.py`, `requirements.txt`, `.env.example`, `prompts/tutor_prompt.py` (referencia; instrucciones activas en `agents/tutor/instructions.py`).

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `get_root_agent()` | Instanciar agente ADK con modelo, instrucciones y tools |
| `get_question_context` | Tool: resolver pregunta y contexto académico KGAA |
| `search_subtopic_material` | Tool: búsqueda RAG filtrada por `subtopic_id` |
| `TutorAgentConfig` | Nombre de app, temperatura, top_k por defecto |
| `TutorRuntimeContext` | Inyectar `Session` y `RAGService` en tools vía `contextvars` |
| `TutorService` | Orquestar Runner ADK y mapear respuesta al contrato REST |
| `api/v1/tutor.py` | Endpoint HTTP (sin cambios de contrato) |

---

### 6. Dependencias

```
api/v1/tutor.py
  → TutorService
    → InMemoryRunner (google-adk)
      → Agent (pitagoras_tutor)
        → get_question_context → QuestionRepository (MySQL)
        → search_subtopic_material → RAGService (ChromaDB)
        → LLM (Gemini vía ADK o OpenAI vía LiteLlm)
```

**Paquetes Python nuevos:**

| Paquete | Uso |
|---------|-----|
| `google-adk[extensions]>=2.0.0` | Agent, Runner, tools; LiteLlm para OpenAI |

**Variables de entorno (sin cambios funcionales):**

| Variable | Descripción |
|----------|-------------|
| `LLM_PROVIDER` | `openai` o `gemini` |
| `OPENAI_API_KEY` | Requerida si `LLM_PROVIDER=openai` |
| `GEMINI_API_KEY` | Requerida si `LLM_PROVIDER=gemini` |
| `GOOGLE_API_KEY` | Opcional; ADK la usa directamente. Si falta, se mapea desde `GEMINI_API_KEY` |
| `TUTOR_RAG_TOP_K` | Fragmentos RAG por defecto en tools |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| AD-01 | Un solo agente `pitagoras_tutor` | Alcance: solo Tutor; sin Motivador/Padres aún |
| AD-02 | Tools explícitas para MySQL y RAG | El agente decide cuándo consultar; trazabilidad ADK |
| AD-03 | `contextvars` para inyectar DB/RAG | ADK tools son funciones puras; evita estado global |
| AD-04 | `InMemoryRunner` por request | Sin sesiones persistentes; endpoint stateless |
| AD-05 | `static_instruction` + `instruction` | Separa reglas pedagógicas del flujo operativo |
| AD-06 | Gemini nativo; OpenAI vía `LiteLlm` | Reutiliza `LLM_PROVIDER` existente con ADK |
| AD-07 | Mismo contrato REST | No romper clientes Flutter ni pruebas de Etapa 7 |
| AD-08 | `get_root_agent()` con `@lru_cache` | Evita recrear agente; inicialización lazy al primer uso |
| AD-09 | `llm/` conservado | Útil para futuros agentes o scripts; tutor ya no lo usa directamente |

---

### 8. Posibles mejoras futuras

- Sesiones ADK persistentes (PostgreSQL / Redis) para conversación multi-turno.
- Exponer rutas ADK nativas (`/run_sse`) vía `get_fast_api_app` para debugging.
- Tool adicional: `get_diagnostic_summary(student_exam_id)` para contexto post-examen.
- Streaming de respuesta con `run_async` + SSE.
- LangGraph como orquestador de múltiples agentes (Etapa 8.1).
- Agentes Motivador y Padres como sub-agentes o tools delegadas.

---

### 9. Próximo paso recomendado

1. **Docker Compose** — API + MySQL + volumen ChromaDB.
2. **Seed UNSA** — preguntas + material RAG indexado por subtema.
3. Probar flujo completo con agente ADK:
   ```bash
   POST /api/v1/rag/ingest/text {"text":"...", "subtopic_id": 1}
   POST /api/v1/tutor/explain {"question_id": 1}
   ```
4. **Etapa 8.1** — LangGraph + agentes Motivador/Padres (solo si se requiere orquestación multi-agente).

**Criterio de aceptación Etapa 8:**

```bash
# Configurar GEMINI_API_KEY o OPENAI_API_KEY en .env
POST /api/v1/tutor/explain {"question_id": 1}
# → explanation generada por agente ADK con rag_sources poblados por tools
```

---

*Última actualización: 2026-06-26 — Etapa 8 completada (Tutor Google ADK).*

---

## Etapa 8.1 — LangGraph orquestador

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Orquestador LangGraph que decide qué agente ejecutar. Por ahora solo enruta al Tutor IA (ADK). Sin agentes Motivador/Padres aún.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Tutor Google ADK (Etapa 8) | ✅ |
| Orquestador LangGraph | ✅ `orchestrator/` |
| Router por intención | ✅ `explain_question` → `tutor` |
| Registro de agentes extensible | ✅ `registry.py` |
| Endpoint `/tutor/explain` | ✅ Sin cambios de contrato |
| Agente Motivador | No implementado |
| Agente Padres | No implementado |

---

### 2. Qué se implementó

- **`orchestrator/service.py`** — `OrchestratorService`: punto de entrada que invoca el grafo LangGraph.
- **`orchestrator/graph.py`** — `StateGraph` con nodos `router` → `tutor` → `END`.
- **`orchestrator/router.py`** — resuelve intención y agente destino; arista condicional post-router.
- **`orchestrator/registry.py`** — mapa `Intent` → `AgentName` (extensible).
- **`orchestrator/nodes.py`** — nodo `tutor` que delega en `TutorAgentExecutor`.
- **`orchestrator/types.py`** — `OrchestratorState`, `Intent`, `AgentName`.
- **`agents/tutor/executor.py`** — lógica ADK extraída del antiguo `TutorService` (ejecutor del agente).
- **`TutorService` refactorizado** — fachada que delega en `OrchestratorService` (API REST sin cambios).
- **Dependencia** `langgraph>=0.2.0` en `requirements.txt`.

---

### 3. Flujo actualizado

```
POST /api/v1/tutor/explain
        │
        ▼
┌───────────────────────┐
│ TutorService          │  Fachada (contrato REST intacto)
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ OrchestratorService   │  graph.invoke(initial_state)
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ Nodo: router          │  intent=explain_question → agent=tutor
└───────────┬───────────┘
            │ (conditional edge)
            ▼
┌───────────────────────┐
│ Nodo: tutor           │  TutorAgentExecutor → ADK + tools
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ TutorExplanation      │  explanation + context + rag_sources
└───────────────────────┘
```

#### Grafo LangGraph (actual)

```
START → router → [tutor | END] → END
```

Cuando se agreguen Motivador y Padres, el router devolverá aristas adicionales sin cambiar el contrato REST.

---

### 4. Archivos creados

```
backend/app/
├── orchestrator/
│   ├── __init__.py
│   ├── exceptions.py
│   ├── graph.py
│   ├── nodes.py
│   ├── registry.py
│   ├── router.py
│   ├── service.py
│   └── types.py
└── agents/tutor/
    └── executor.py              # Ejecutor ADK (invocado por el grafo)
```

**Modificados:** `agents/tutor_service.py` (fachada → orquestador), `requirements.txt`.

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `OrchestratorService` | Invocar el grafo y devolver `TutorExplanation` |
| `route_request` | Nodo router: resolver `intent` y `selected_agent` |
| `route_after_router` | Arista condicional hacia el nodo del agente |
| `INTENT_TO_AGENT` | Registro extensible intent → agente |
| `build_tutor_node` | Nodo que ejecuta `TutorAgentExecutor` |
| `TutorAgentExecutor` | Ejecución ADK del Tutor (tools RAG + MySQL) |
| `TutorService` | Fachada REST; delega en orquestador |

---

### 6. Dependencias

```
api/v1/tutor.py
  → TutorService (fachada)
    → OrchestratorService
      → LangGraph StateGraph
        → router (reglas)
        → tutor → TutorAgentExecutor
          → Google ADK Agent + tools
          → RAGService (ChromaDB) + QuestionRepository (MySQL)
```

**Paquete nuevo:**

| Paquete | Uso |
|---------|-----|
| `langgraph>=0.2.0` | Grafo de estados, routing condicional |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| LG-01 | Grafo compilado por request (con `Session`) | El nodo tutor necesita sesión SQLAlchemy inyectada |
| LG-02 | Router por reglas (no LLM) | Solo existe un intent/agente; clasificador LLM cuando haya más casos |
| LG-03 | `TutorService` como fachada | No romper `api/v1/tutor.py` ni contratos existentes |
| LG-04 | `executor.py` separado del servicio | El grafo invoca al ejecutor; el orquestador no conoce ADK en detalle |
| LG-05 | `registry.py` centralizado | Añadir Motivador/Padres = nueva entrada en mapa + nodo en grafo |
| LG-06 | `OrchestratorState` tipado | Estado explícito para depuración y extensión multi-agente |
| LG-07 | Errores de routing como `OrchestratorRoutingError` | Distingue fallo de enrutamiento vs fallo del LLM/agente |

---

### 8. Posibles mejoras futuras

- Router con LLM para clasificar intención cuando existan Motivador y Padres.
- Checkpointing LangGraph (memoria de conversación multi-turno).
- Endpoint genérico `/api/v1/agents/run` además de `/tutor/explain`.
- Nodos paralelos (ej. tutor + motivador) con `ParallelAgent` o ramas del grafo.
- Métricas/trazas del grafo (LangSmith, OpenTelemetry).
- Persistir `OrchestratorState` en Redis para sesiones largas.

---

### 9. Próximo paso recomendado

1. **Docker Compose** — API + MySQL + volumen ChromaDB.
2. **Seed UNSA** — preguntas + material RAG.
3. Probar flujo orquestado:
   ```bash
   POST /api/v1/tutor/explain {"question_id": 1}
   # → router elige tutor → ADK genera explicación
   ```
4. **Siguiente agente** — Motivador o Padres: registrar en `registry.py`, añadir nodo al grafo y endpoint o intent.

**Criterio de aceptación Etapa 8.1:**

```bash
POST /api/v1/tutor/explain {"question_id": 1}
# → misma respuesta que Etapa 8, pero pasando por LangGraph (router → tutor)
```

---

*Última actualización: 2026-06-26 — Etapa 8.1 completada (LangGraph orquestador).*

---

## Etapa 8.2 — Agentes Diagnóstico, Motivador y Padres

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Tres agentes ADK independientes que comparten MySQL, ChromaDB y LLM vía infraestructura común. Integrados al orquestador LangGraph.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Tutor ADK | ✅ |
| Orquestador LangGraph | ✅ 4 agentes |
| Agente Diagnóstico | ✅ `agents/diagnostic/` |
| Agente Motivador | ✅ `agents/motivator/` |
| Agente Padres | ✅ `agents/parents/` |
| Infraestructura compartida | ✅ `agents/shared/` |
| Endpoints `/agents/*` | ✅ |
| Endpoint `/tutor/explain` | ✅ Sin cambios de contrato |

---

### 2. Qué se implementó

- **`agents/shared/`** — código reutilizable:
  - `config.py` — `AgentConfig`, `resolve_adk_model`, `resolve_model_label`
  - `runtime.py` — `AgentRuntimeContext` (MySQL + ChromaDB)
  - `adk_runner.py` — `run_adk_agent()` (ejecutor ADK único)
  - `tools.py` — `search_subtopic_material`, `get_exam_diagnostic_report`, `get_study_plan_summary`
- **Agente Diagnóstico** — interpreta el perfil post-examen con IA + RAG en debilidades.
- **Agente Motivador** — mensaje motivacional basado en diagnóstico y plan de estudio.
- **Agente Padres** — informe accesible para padres/tutores.
- Cada agente con estructura ADK: `agent.py`, `config.py`, `instructions.py`, `tools.py`, `executor.py`.
- **Orquestador ampliado** — router enruta a `tutor`, `diagnostic`, `motivator`, `parents`.
- **API nueva** — `POST /api/v1/agents/diagnostic/analyze`, `/motivator/encourage`, `/parents/report`.
- **Tutor refactorizado** — usa `agents/shared` (sin duplicar runner ni tools RAG).

---

### 3. Flujo actualizado

```
POST /api/v1/agents/diagnostic/analyze  { "student_exam_id": 42 }
        │
        ▼
┌───────────────────────┐
│ OrchestratorService   │  agent_name=diagnostic
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ LangGraph router      │  → nodo diagnostic
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ DiagnosticAgentExecutor│
│  ADK + tools:         │
│  - get_exam_diagnostic_report  → MySQL (DiagnosticService)
│  - search_subtopic_material    → ChromaDB
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ AgentResponse         │  content + rag_sources + metadata
└───────────────────────┘
```

#### Grafo LangGraph (4 agentes)

```
START → router → [tutor | diagnostic | motivator | parents] → END
```

| Agente | Entrada | Tools principales |
|--------|---------|-------------------|
| `tutor` | `question_id` | `get_question_context`, `search_subtopic_material` |
| `diagnostic` | `student_exam_id` | `get_exam_diagnostic_report`, `search_subtopic_material` |
| `motivator` | `student_exam_id` | `get_exam_diagnostic_report`, `get_study_plan_summary` |
| `parents` | `student_exam_id` | `get_exam_diagnostic_report`, `get_study_plan_summary` |

---

### 4. Archivos creados

```
backend/app/
├── agents/
│   ├── shared/
│   │   ├── __init__.py
│   │   ├── adk_runner.py
│   │   ├── config.py
│   │   ├── runtime.py
│   │   └── tools.py
│   ├── diagnostic/          # agent, config, instructions, tools, executor
│   ├── motivator/
│   └── parents/
├── api/v1/
│   └── agents.py
└── schemas/
    └── agents.py
```

**Modificados:** `orchestrator/*`, `agents/tutor/*`, `agents/types.py`, `api/v1/router.py`.  
**Eliminado:** `agents/tutor/runtime.py` (reemplazado por `agents/shared/runtime.py`).

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `AgentRuntimeContext` | Inyectar `Session` + `RAGService` en todas las tools |
| `run_adk_agent` | Ejecutar cualquier agente ADK sin duplicar lógica |
| `get_exam_diagnostic_report` | Tool compartida: `DiagnosticService` → MySQL |
| `get_study_plan_summary` | Tool compartida: `RecommendationService` → MySQL |
| `search_subtopic_material` | Tool compartida: `RAGService` → ChromaDB |
| `DiagnosticAgentExecutor` | Agente IA de interpretación diagnóstica |
| `MotivatorAgentExecutor` | Agente IA motivacional |
| `ParentsAgentExecutor` | Agente IA informe para padres |
| `OrchestratorService` | Routing y métodos por agente |
| `api/v1/agents.py` | Endpoints HTTP de los 3 agentes nuevos |

---

### 6. Dependencias

```
api/v1/agents.py
  → OrchestratorService
    → LangGraph
      → [diagnostic | motivator | parents]
        → run_adk_agent (shared)
          → Google ADK Agent
            → shared/tools (MySQL + ChromaDB)
            → LLM (Gemini / OpenAI vía shared/config)
```

**Servicios de dominio reutilizados (sin duplicar):**

| Servicio existente | Uso en agentes |
|--------------------|----------------|
| `DiagnosticService` | Diagnóstico, Motivador, Padres |
| `RecommendationService` | Motivador, Padres |
| `RAGService` | Tutor, Diagnóstico |
| `QuestionRepository` | Tutor |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| AG-01 | Carpeta `agents/shared/` | Evitar duplicar runner ADK, runtime y tools MySQL/RAG |
| AG-02 | Un folder por agente (ADK completo) | Independencia; cada agente evoluciona por separado |
| AG-03 | Tools compartidas en `shared/tools.py` | Un solo acceso a MySQL/ChromaDB para todos |
| AG-04 | `AgentResponse` genérico | Contrato uniforme para agentes no-tutor |
| AG-05 | Tutor mantiene `TutorExplanation` | No romper `/tutor/explain` existente |
| AG-06 | Router por `agent_name` explícito | Desambiguación cuando hay `student_exam_id` |
| AG-07 | Diagnóstico REST (`/diagnostics`) intacto | El agente IA es capa adicional, no reemplazo |
| AG-08 | Temperatura distinta por agente | Motivador más creativo (0.5); resto 0.3 |

---

### 8. Posibles mejoras futuras

- Router con LLM para clasificar intención en lenguaje natural.
- Endpoint unificado `POST /agents/run` con `agent_name` en body.
- Streaming SSE para respuestas largas (informes padres).
- Agente Diagnóstico con acceso a historial multi-examen del estudiante.
- Cache de informes por `student_exam_id`.
- Auth JWT para restringir agente Padres a tutores vinculados.

---

### 9. Próximo paso recomendado

1. **Docker Compose** — API + MySQL + volumen ChromaDB.
2. **Seed UNSA** — examen completado de prueba para probar agentes.
3. Probar flujo multi-agente:
   ```bash
   POST /api/v1/student-exams/{id}/finish
   POST /api/v1/agents/diagnostic/analyze {"student_exam_id": 1}
   POST /api/v1/agents/motivator/encourage {"student_exam_id": 1}
   POST /api/v1/agents/parents/report {"student_exam_id": 1}
   POST /api/v1/tutor/explain {"question_id": 1}
   ```
4. **Flutter** — consumir endpoints de agentes según pantalla (estudiante vs padres).

**Criterio de aceptación Etapa 8.2:**

```bash
# Examen completado con student_exam_id=1
POST /api/v1/agents/diagnostic/analyze {"student_exam_id": 1}
# → content con análisis narrativo + rag_sources si aplica

POST /api/v1/agents/motivator/encourage {"student_exam_id": 1, "student_message": "Me desanimé"}
# → mensaje motivacional personalizado

POST /api/v1/agents/parents/report {"student_exam_id": 1}
# → informe para padres en lenguaje accesible
```

---

*Última actualización: 2026-06-26 — Etapa 8.2 completada (agentes Diagnóstico, Motivador, Padres).*

---

## Etapa 9 — CU-01 Auth JWT (registro + inicio de sesión)

**Fecha:** 2026-06-26  
**Responsable:** Sesión de implementación con Cursor  
**Alcance:** Registro e inicio de sesión de estudiantes con JWT. Sin onboarding, Home ni IA.

---

### 1. Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Tabla `users` + vínculo `students.user_id` | ✅ |
| Registro estudiante (`POST /auth/register`) | ✅ |
| Login (`POST /auth/login`) | ✅ |
| Perfil autenticado (`GET /auth/me`) | ✅ |
| JWT Bearer + dependencias FastAPI | ✅ |
| Protección de endpoints de exámenes | No implementado (CU-02) |
| Registro padres / vínculo padre–hijo | No implementado |
| Onboarding / Home Flutter | No implementado |

---

### 2. Qué se implementó

- **Entidad `User`** — credenciales (`email`, `password_hash`, `role`, `is_active`).
- **Entidad `Student` ampliada** — `user_id` FK opcional hacia `users` (1:1 estudiante).
- **`UserRole`** — `student` \| `parent` (padre reservado para etapas futuras).
- **`AuthService`** — `register_student`, `login`, `get_user_by_id`.
- **`UserRepository`** / **`StudentRepository`** — consultas por email y `user_id`.
- **Hash bcrypt** (`passlib`) y **JWT HS256** (`python-jose`).
- **Endpoints** bajo `/api/v1/auth`.
- **Dependencias** `get_current_user`, `get_current_student_id` en `core/dependencies.py`.
- **Migración SQL** `database/migrations/001_cu01_auth.sql` y actualización de `database/schema.sql`.
- Variables `JWT_SECRET_KEY`, `JWT_ALGORITHM`, `JWT_EXPIRE_MINUTES` en config.

---

### 3. Flujo actualizado

```
POST /api/v1/auth/register  { email, password, full_name }
        │
        ▼
┌───────────────────────┐
│ AuthService           │  Valida email único
└───────────┬───────────┘
            ├─► INSERT users (role=student, password_hash)
            ├─► INSERT students (user_id, email, full_name)
            ▼
┌───────────────────────┐
│ JWT access_token      │  sub, role, student_id, exp
└───────────────────────┘

POST /api/v1/auth/login  { email, password }
        │
        ▼
  Verificar bcrypt → emitir JWT

GET /api/v1/auth/me  Authorization: Bearer <token>
        │
        ▼
  decode JWT → AuthService.get_user_by_id → UserResponse
```

**Integración con el resto del sistema (aún sin middleware global):**

```
Flutter / cliente
  → POST /auth/login
  → Bearer token en cabeceras (CU-02+)
  → exam_engine / diagnostics / agents (protección pendiente)
```

---

### 4. Archivos creados

```
backend/app/
├── auth/
│   ├── __init__.py
│   ├── auth_service.py
│   ├── exceptions.py
│   ├── jwt_tokens.py
│   └── password.py
├── models/
│   └── user.py
├── repositories/
│   └── user_repository.py
├── schemas/
│   └── auth.py
└── api/v1/
    └── auth.py

database/migrations/
└── 001_cu01_auth.sql
```

**Modificados:** `models/student.py`, `models/enums.py`, `models/__init__.py`, `repositories/student_repository.py`, `core/config.py`, `core/dependencies.py`, `api/v1/router.py`, `requirements.txt`, `.env.example`, `database/schema.sql`.

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `User` | Credenciales y rol de autenticación |
| `Student` | Perfil académico vinculado al usuario |
| `AuthService` | Registro atómico user+student, login, resolución de perfil |
| `UserRepository` | Persistencia y búsqueda por email |
| `password.py` | Hash y verificación bcrypt |
| `jwt_tokens.py` | Crear y decodificar access tokens |
| `get_current_user` | Validar Bearer y cargar `AuthUser` |
| `get_current_student_id` | Extraer `student_id` del usuario autenticado (listo para CU-02) |
| `api/v1/auth.py` | Contrato HTTP registro, login, me |

---

### 6. Dependencias

```
api/v1/auth.py
  → AuthService
    → UserRepository + StudentRepository (MySQL)
    → passlib[bcrypt]
    → python-jose (JWT)
  → get_current_user (solo /me)

core/dependencies.py
  → HTTPBearer → jwt_tokens.decode → AuthService
```

**Paquetes nuevos:**

| Paquete | Uso |
|---------|-----|
| `python-jose[cryptography]` | JWT encode/decode |
| `passlib[bcrypt]` | Hash de contraseñas |
| `email-validator` | `EmailStr` en schemas |

**Variables de entorno:**

| Variable | Descripción |
|----------|-------------|
| `JWT_SECRET_KEY` | Clave secreta HS256 (obligatoria en producción) |
| `JWT_ALGORITHM` | Default `HS256` |
| `JWT_EXPIRE_MINUTES` | TTL del access token (default 1440) |

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| AU-01 | Tabla `users` separada de `students` | Escalable a padres y otros roles sin duplicar credenciales |
| AU-02 | JWT stateless (sin sesión en servidor) | Permite escalar API horizontalmente sin sticky sessions |
| AU-03 | `student_id` en claims del token | Evita JOIN en cada request de exámenes (CU-02) |
| AU-04 | Registro solo estudiante en CU-01 | Alcance explícito; `UserRole.PARENT` reservado |
| AU-05 | Transacción user+student en un commit | Consistencia; no hay usuario huérfano sin perfil |
| AU-06 | Endpoints legacy sin auth obligatoria | No romper flujos existentes; protección incremental en CU-02 |
| AU-07 | `get_current_student_id` como dependencia | Reutilizable en routers de exámenes sin repetir lógica JWT |
| AU-08 | Migración SQL manual (`001_cu01_auth.sql`) | Compatible con bases ya creadas antes de CU-01 |

---

### 8. Posibles mejoras futuras

**Funcionalidad**

- Refresh tokens y rotación de claves.
- Registro/login de padres y tabla `parent_student_links`.
- Proteger rutas de escritura (exámenes, RAG ingest) con `Depends(get_current_user)`.
- Rate limiting en `/auth/login` y `/auth/register`.
- Verificación de email (opcional).
- OAuth2 password flow documentado en OpenAPI (`OAuth2PasswordBearer`).

**Escalabilidad**

| Área | Enfoque actual | Evolución recomendada |
|------|----------------|----------------------|
| **API** | JWT stateless, sin estado en memoria | Múltiples réplicas FastAPI detrás de load balancer |
| **Tokens** | Access token único HS256 | RS256 con clave pública/privada; refresh en Redis si se necesita revocación |
| **Base de datos** | `users.email` UNIQUE indexado | Read replicas para consultas de perfil; pool SQLAlchemy ajustado por réplica |
| **Contraseñas** | bcrypt (coste configurable) | Mantener bcrypt; considerar argon2 si el volumen de registros crece |
| **Sesiones** | No hay tabla de sesiones | Solo necesaria si se exige logout global o lista negra de tokens |
| **Identidad** | 1 user → 1 student | Modelo extensible a N hijos por padre sin cambiar el contrato JWT base |

La arquitectura actual **no introduce estado de sesión en servidor**, lo que facilita desplegar N instancias de la API. El cuello de botella predecible será MySQL (escrituras en registro) y, en fases IA, ChromaDB/LLM — no el módulo auth.

---

### 9. Próximo paso recomendado

**CU-02** (siguiente caso de uso tras auth):

1. Proteger creación de `student_exams` con `Depends(get_current_student_id)`.
2. Asignar `student_id` desde el JWT (no desde body).
3. Pantalla Flutter: login/registro → token en almacenamiento seguro.
4. Ejecutar migración en entornos existentes:
   ```bash
   mysql -u pitagoras -p pitagoras < database/migrations/001_cu01_auth.sql
   ```
5. Configurar `JWT_SECRET_KEY` fuerte en `.env` antes de demo pública.

**Criterio de aceptación CU-01:**

```bash
POST /api/v1/auth/register
{"email":"ana@example.com","password":"secret123","full_name":"Ana García"}
# → 201 + access_token + user.student_id

POST /api/v1/auth/login
{"email":"ana@example.com","password":"secret123"}
# → access_token

GET /api/v1/auth/me
Authorization: Bearer <token>
# → user con role=student y student_id
```

---

*Última actualización: 2026-06-26 — Etapa 9 / CU-01 completada (Auth JWT).*
