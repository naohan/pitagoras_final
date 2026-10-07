# Análisis Figma ↔ Backend — Pitágoras

**Rúbrica hackathon:** *Evaluación Inteligente y Feedback en Tiempo Real*  
**Fecha:** 2026-06-26  
**Rol:** UX Architect · Software Architect · Product Designer

---

## Alcance del documento

Este documento guía qué pantallas del diseño Figma implementar en Flutter durante la hackathon, mapeando cada una contra el backend (endpoints existentes **y extensiones añadidas en demo**).

> **Documento vivo:** al implementar una pantalla o un endpoint nuevo, actualiza la columna **Estado Flutter** y la tabla resumen al final de este archivo. Ver sección [Retroalimentación](#retroalimentación-cómo-mantener-figma--código-alineados).

**Fuentes utilizadas:**

| Fuente | Uso |
|--------|-----|
| Flujo funcional de Pitágoras | `docs/ARCHITECTURE.md`, `docs/IMPLEMENTATION_GUIDE.md`, visión KGAA |
| Backend implementado | `backend/app/api/v1/*`, servicios de dominio |
| Rúbrica | Evaluación inteligente + feedback en tiempo real |

**Nota:** Los frames del mockup de hackathon (pantallas 15–26: instrucciones, guardar pregunta, revisión, respuestas guardadas, análisis IA) están mapeados en la sección [Mapa mockup hackathon](#mapa-mockup-hackathon-frames-15–26). Si el Figma usa nombres distintos, este documento sigue siendo válido como mapa lógico pantalla → API.

**Leyenda de implementación (retroalimentación):**

| Estado | Significado |
|--------|-------------|
| ✅ Hecho | Pantalla/ruta Flutter + API conectados |
| 🟡 Parcial | UI o API incompleta respecto al mockup |
| ⬜ Pendiente | Documentado pero no implementado |
| ❌ Fuera MVP | Descartado para la demo |

**Leyenda de prioridad:**

| Símbolo | Significado |
|---------|-------------|
| ✅ Obligatoria | Imprescindible para la demo de hackathon |
| 🟡 Importante | Aporta valor; implementar si hay tiempo |
| ⚪ Opcional | Fuera del MVP; versión futura |
| ❌ Eliminar | Sin backend o sin valor en la demo |

---

## Flujo funcional de referencia (PROJECT_CONTEXT)

```
Registro / Login
    → Onboarding (universidad → área → carrera) — GET catálogo
    → Home / Mi espacio — hub de acciones
    → Diagnóstico (5 preguntas, plantilla seed)
    → Resultado + Recomendaciones IA
    → Simulacro adaptativo (15 preg, POST /student-exams/adaptive)
    → Examen en curso (respuestas + tiempo + guardar pregunta)
    → Feedback inmediato (is_correct) + Tutor IA bajo demanda
    → Finalizar
    → Resultados + Diagnóstico + Recomendaciones
    → Respuestas guardadas (repaso)
    → Agentes IA (Diagnóstico narrativo, Motivador)
    → [Vista Padres — auth parcial]
```

---

## Mapa mockup hackathon (frames 15–26)

Correspondencia entre los frames del mockup compartido en hackathon y el código actual.

| Frame Figma | Pantalla | Ruta Flutter | Endpoints | Estado Flutter |
|-------------|----------|--------------|-----------|----------------|
| 18 | Instrucciones pre-examen | `/diagnostico` (texto intro) | `GET /exam-templates` | 🟡 Parcial — sin pantalla dedicada de instrucciones |
| 19 | Examen en curso + **Guardar** | `/examen/:id` | `POST .../answers`, `PATCH .../answers/{q}/save` | ✅ Hecho — `exam_page.dart` |
| 20 | Tip de resolución (modal) | modal en examen | `POST /tutor/hint` | ✅ Hecho — `resolution_tip_sheet.dart` |
| 21 | Resultados generales | `/resultados/:id` | `GET .../results`, `GET /diagnostics/...` | ✅ Hecho — `results_page.dart` |
| 22 | Revisión de respuestas (tabs) | `/resultados/:id/revision` | `GET .../review?correctness=` | ✅ Hecho — `exam_review_page.dart` |
| 23 | Detalle respuesta incorrecta | sheet compartido | `GET .../review` | ✅ Hecho — `answer_review_detail_sheet.dart` |
| 24 | Explicación completa | Tutor IA (modal) | `POST /tutor/explain` | ✅ Hecho — `tutor_sheet.dart` |
| 25 | Respuestas guardadas | `/respuestas-guardadas` | `GET /students/{id}/saved-answers` | ✅ Hecho — `saved_answers_page.dart` |
| 26 | Análisis IA | sección en resultados | `POST /agents/diagnostic/analyze` | ✅ Hecho — `results_agents_section.dart` |

**Extensiones de API añadidas para la demo (actualizar si cambian):**

| Endpoint | Uso en mockup |
|----------|----------------|
| `POST /student-exams/adaptive` | Simulacro personalizado post-diagnóstico |
| `PATCH /student-exams/{id}/answers/{question_id}/save` | Botón Guardar (frame 19) |
| `GET /students/{id}/saved-answers` | Pantalla Respuestas guardadas (frame 25) |
| `POST /tutor/hint` | Tip breve durante examen (frame 20) |
| `GET /student-exams/{id}/review` | Revisión post-examen (frame 22) |
| RAG: `seed_rag_docs`, `seed_rag_urls` | Contexto del Tutor (libros + blog Rubiños) |

---

## Retroalimentación: cómo mantener Figma ↔ código alineados

Usa este documento como **contrato entre diseño y desarrollo**. Ciclo recomendado durante la hackathon:

```
Mockup Figma → FIGMA_ANALYSIS (mapear frame → ruta → API)
      ↓
Implementar Flutter + backend mínimo
      ↓
Marcar Estado Flutter (✅ / 🟡 / ⬜)
      ↓
Demo / prueba → anotar gaps en Observaciones
      ↓
Siguiente iteración (o versión futura)
```

### Cuándo actualizar el doc

| Evento | Qué cambiar aquí |
|--------|------------------|
| Nueva pantalla en Figma | Fila en tabla mockup + sección «Análisis por pantalla» |
| Nuevo endpoint | Tabla de extensiones + fila Backend de la pantalla |
| Pantalla terminada | `Estado Flutter` → ✅ y ruta en columna Flutter |
| UI simplificada vs Figma | Nota en Observaciones (ej. «fusionada con Resultados») |
| Descartado para demo | Prioridad → ❌ y motivo en una línea |

### Qué pegar cuando compartes mockups

Para que el mapeo sea útil, incluye por pantalla:

1. **Número de frame** Figma (ej. 19)
2. **Captura o link** Figma
3. **Acción principal** (ej. «Guardar pregunta»)
4. **Datos que muestra** (¿viene de API o es estático?)

Con eso se puede añadir una fila a la tabla sin reescribir todo el documento.

### Archivos Flutter de referencia rápida

| Pantalla lógica | Archivo |
|-----------------|---------|
| Examen + feedback + guardar | `frontend/lib/screens/exam/exam_page.dart` |
| Tutor IA | `frontend/lib/screens/exam/widgets/tutor_sheet.dart` |
| Simulacro adaptativo | `frontend/lib/screens/exam/simulacro_page.dart` |
| Resultados + IA | `frontend/lib/screens/results/results_page.dart` |
| Respuestas guardadas | `frontend/lib/screens/saved_answers/saved_answers_page.dart` |
| Home / hub | `frontend/lib/screens/home/home_page.dart` |

### Próximos gaps documentados (prioridad demo)

| Frame | Gap | Esfuerzo estimado |
|-------|-----|-------------------|
| 18 | Pantalla instrucciones dedicada antes del simulacro | ~30 min |

---

## Análisis por pantalla

---

### 1. Splash / Pantalla de marca

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Splash |
| **Objetivo** | Mostrar marca Pitágoras mientras se valida sesión local (token JWT) |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/auth/me` (si hay token guardado) |
| **Servicio** | `AuthService.get_user_by_id` vía `get_current_user` |
| **Modelos** | `User`, `Student` |
| **Caso de uso** | Auth — verificar sesión activa |

#### Inteligencia Artificial

| Campo | Valor |
|-------|-------|
| Agente | No |
| RAG | No |
| LangGraph | No |
| Google ADK | No |

#### Valor para la Hackathon

- Demuestra producto pulido y routing inicial.
- Rúbrica: preparación del flujo; no cubre IA directamente.
- Valor demo: **bajo** pero necesario para UX profesional.

#### Observaciones

- **Mantener igual** en apariencia; lógica mínima (timer 1–2 s + check token).
- No requiere llamadas API si no hay token; navegar a Login.

---

### 2. Bienvenida / Landing

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Bienvenida |
| **Objetivo** | Presentar valor de Pitágoras y CTA a registro o login |
| **Estado** | 🟡 Importante |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | Ninguno |
| **Servicio** | — |
| **Modelos** | — |
| **Caso de uso** | — |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Narrativa para el jurado antes del flujo técnico.
- Rúbrica: ningún criterio técnico directo.
- Valor demo: **medio** (storytelling).

#### Observaciones

- **Unir con Splash** si el tiempo es limitado: una sola pantalla con logo + botones «Iniciar sesión» / «Registrarse».
- Sin backend; solo navegación local.

---

### 3. Inicio de sesión

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Login |
| **Objetivo** | Autenticar estudiante y obtener JWT |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/auth/login` |
| **Servicio** | `AuthService.login` |
| **Modelos** | `User`, `Student` |
| **Caso de uso** | CU-01 Auth (registro e inicio de sesión) |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Entrada al flujo real con identidad de estudiante.
- Rúbrica: habilita evaluación personalizada (prerrequisito).
- Valor demo: **alto** (flujo E2E creíble).

#### Observaciones

- **Mantener igual**; guardar `access_token` y `user.student_id` en almacenamiento seguro.
- Enlace a pantalla Registro.

---

### 4. Registro de estudiante

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Registro |
| **Objetivo** | Crear cuenta estudiante y emitir JWT |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/auth/register` |
| **Servicio** | `AuthService.register_student` |
| **Modelos** | `User`, `Student` |
| **Caso de uso** | CU-01 Auth |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Permite demo en vivo con usuario nuevo ante el jurado.
- Rúbrica: identidad del evaluado.
- Valor demo: **alto**.

#### Observaciones

- **Mantener igual**; tras registro exitoso, ir directo al flujo de simulacro (saltar Onboarding).
- Campos: `email`, `password`, `full_name` (contrato Pydantic existente).

---

### 5. Onboarding — Universidad y carrera objetivo

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Onboarding (pasos 1–3) |
| **Objetivo** | Capturar universidad/carrera/meta del estudiante |
| **Estado** | ❌ Eliminar (hackathon) |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | Ninguno que persista preferencias de onboarding |
| **Servicio** | — |
| **Modelos** | — |
| **Caso de uso** | No implementado (explícito en Etapa 9) |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Estética agradable pero **sin persistencia**.
- Rúbrica: no aporta evaluación ni feedback.
- Valor demo: **nulo** en tiempo limitado.

#### Observaciones

- **Eliminar** del alcance hackathon.
- Tras login/registro, navegar directo a «Elegir simulacro» con datos UNSA hardcodeados en seed.
- Versión futura: podría leer `GET /universities`, `GET /careers` solo para display (sin guardar preferencia).

---

### 6. Home / Dashboard del estudiante

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Home |
| **Objetivo** | Hub con progreso, accesos rápidos e historial |
| **Estado** | ❌ Eliminar (hackathon) |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | No existe `GET /students/{id}/exams` ni agregados de historial |
| **Servicio** | — |
| **Modelos** | — |
| **Caso de uso** | CU-20 Historial — no implementado |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Requiere endpoints de historial inexistentes.
- Rúbrica: no demuestra IA ni feedback en tiempo real.
- Valor demo: **bajo** sin backend.

#### Observaciones

- **Eliminar**; reemplazar por navegación directa Login → Elegir simulacro.
- Versión futura: Home consume historial + último diagnóstico.

---

### 7. Elegir simulacro

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Elegir simulacro |
| **Objetivo** | Mostrar simulacro disponible (UNSA Ingeniería) e iniciar sesión de examen |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/exam-templates/{template_id}` · `POST /api/v1/student-exams` |
| **Servicio** | `ExamEngineService` · `ExamTemplateRepository` |
| **Modelos** | `ExamTemplate`, `StudentExam`, `Student` |
| **Caso de uso** | CU-04 Iniciar simulacro |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Punto de entrada al núcleo «Evaluación Inteligente».
- Rúbrica: C1 — evaluación estructurada por áreas UNSA.
- Valor demo: **alto**.

#### Observaciones

- **Simplificar:** una sola tarjeta de simulacro; `template_id` fijo del seed (no hay `GET /exam-templates` listado).
- `POST /student-exams` requiere `student_id` en body (auth en exámenes aún no obligatoria; usar `student_id` del JWT).
- Opcional display: `GET /universities/{id}` o `GET /careers/{id}` solo para etiquetas UI.

---

### 8. Instrucciones pre-examen

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Instrucciones |
| **Objetivo** | Mostrar duración, número de preguntas y reglas antes de empezar |
| **Estado** | ⚪ Opcional |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/exam-templates/{template_id}` (ya cargado en pantalla anterior) |
| **Servicio** | `ExamTemplateRepository` |
| **Modelos** | `ExamTemplate` |
| **Caso de uso** | CU-04 |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Claridad UX; datos ya disponibles en plantilla.
- Rúbrica: marginal.
- Valor demo: **bajo**.

#### Observaciones

- **Unir con «Elegir simulacro»:** botón «Comenzar» que llama `POST /student-exams` y navega al examen.
- Evita una pantalla extra.

---

### 9. Examen en curso

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Examen en curso |
| **Objetivo** | Presentar preguntas, registrar respuestas y mostrar tiempo restante |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/student-exams/{id}` · `GET .../time` · `POST .../answers` |
| **Servicio** | `ExamEngineService` |
| **Modelos** | `StudentExam`, `StudentAnswer`, `Question`, `QuestionOption` |
| **Caso de uso** | CU-05 Responder preguntas |

#### Inteligencia Artificial

Todo **No** (calificación determinística).

#### Valor para la Hackathon

- Corazón de la rúbrica: evaluación en vivo.
- Rúbrica: **C1** (evaluación) + **C3** (feedback inmediato vía `is_correct`).
- Valor demo: **muy alto**.

#### Observaciones

- **Mantener igual** en estructura; polling cada 5–10 s a `GET .../time`.
- Tras `POST .../answers`, mostrar feedback binario (✓/✗) usando `is_correct` del response.
- No mostrar respuesta correcta en `GET` del examen (backend oculta `is_correct` en opciones).
- Navegación pregunta a pregunta o lista; una pregunta por vista es más simple para hackathon.

---

### 10. Feedback inmediato de respuesta

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Feedback respuesta |
| **Objetivo** | Confirmar acierto/error justo al enviar la respuesta |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/student-exams/{id}/answers` (campo `is_correct` en respuesta) |
| **Servicio** | `ExamEngineService.submit_answer` |
| **Modelos** | `StudentAnswer` |
| **Caso de uso** | CU-05 + feedback tiempo real (decisión X-05) |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Demuestra **«Feedback en Tiempo Real»** de forma literal.
- Rúbrica: **C3** — núcleo de la rúbrica.
- Valor demo: **muy alto**.

#### Observaciones

- **No pantalla separada:** implementar como banner/snackbar/estado inline en «Examen en curso».
- Si `is_correct == false`, mostrar CTA «Preguntar al Tutor» → pantalla 11.
- **Estado Flutter:** ✅ `AnswerFeedbackBanner` en `exam_page.dart`.

---

### 10b. Guardar pregunta para repasar

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Guardar / Respuestas guardadas |
| **Objetivo** | Marcar preguntas durante el examen y repasarlas después con feedback |
| **Estado** | ✅ Obligatoria (mockup frame 19 + 25) |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `PATCH /api/v1/student-exams/{id}/answers/{question_id}/save` · `GET /api/v1/students/{id}/saved-answers` |
| **Servicio** | `ExamEngineService.toggle_save_answer` · `list_saved_answers` |
| **Modelos** | `StudentAnswer.is_saved` |
| **Caso de uso** | CU-05 + repaso personalizado |

#### Inteligencia Artificial

| Campo | Valor |
|-------|-------|
| Agente | **Tutor** (en detalle de pregunta guardada incorrecta) |
| RAG | Sí (al abrir «Ver resolución») |

#### Valor para la Hackathon

- Evaluación **continua**: el estudiante construye su propio banco de repaso.
- Rúbrica: **C2** (personalización) + **C3** (feedback diferido con tutor).
- Valor demo: **muy alto** — visible en mockup frames 19 y 25.

#### Observaciones

- Botón bookmark en examen; pantalla `/respuestas-guardadas` con tabs Todas/Correctas/Incorrectas.
- Migración DB: `python -m scripts.migrate_add_is_saved`.
- **Estado Flutter:** ✅ implementado.

---

### 11. Tutor IA — Explicación de pregunta

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Tutor IA |
| **Objetivo** | Explicar la pregunta fallida con contexto KGAA y material RAG |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/tutor/explain` |
| **Servicio** | `TutorService` → `OrchestratorService` → `TutorAgentExecutor` |
| **Modelos** | `Question`, jerarquía académica (`Subtopic` → `Area`) |
| **Caso de uso** | CU-10 Pedir explicación (Tutor IA) |

#### Inteligencia Artificial

| Campo | Valor |
|-------|-------|
| Agente | **Tutor** |
| RAG | **Sí** (ChromaDB vía `search_subtopic_material`) |
| LangGraph | **Sí** (orquestador enruta a nodo tutor) |
| Google ADK | **Sí** |

#### Valor para la Hackathon

- Demuestra IA real: RAG + LLM + contexto académico.
- Rúbrica: **C4** (tutoría inteligente) + refuerzo **C3** (feedback pedagógico).
- Valor demo: **muy alto** — pantalla estrella de IA.

#### Observaciones

- **Mantener igual** en Figma; modal o bottom sheet sobre el examen.
- Payload: `question_id`, `selected_option_id`, opcional `student_message`.
- Mostrar loading (LLM tarda); opcional listar `rag_sources` de la respuesta.
- Requiere material RAG indexado en demo.

---

### 12. Confirmación / Finalizar examen

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Finalizar examen |
| **Objetivo** | Confirmar envío y disparar calificación final |
| **Estado** | 🟡 Importante |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/student-exams/{id}/finish` |
| **Servicio** | `ExamEngineService.finish_exam` |
| **Modelos** | `StudentExam`, `ExamResult`, desgloses |
| **Caso de uso** | CU-06 Finalizar y calificar |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Cierra el ciclo de evaluación.
- Rúbrica: **C1**.
- Valor demo: **alto**.

#### Observaciones

- **Unir con última pregunta del examen** o con diálogo de confirmación simple.
- Tras `finish`, navegar a Resultados (pantalla 13).

---

### 13. Resultados globales

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Resultados |
| **Objetivo** | Mostrar puntaje global y desglose por área |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/student-exams/{id}/results` |
| **Servicio** | `ExamEngineService` / `ExamResultRepository` |
| **Modelos** | `ExamResult`, `ExamResultArea`, `ExamResultComponent`, etc. |
| **Caso de uso** | CU-06 Consultar calificación |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Visualiza la matriz de evaluación tipo admisión UNSA.
- Rúbrica: **C1** + **C2** (base numérica del diagnóstico).
- Valor demo: **muy alto**.

#### Observaciones

- **Mantener igual**; barras de progreso por área desde `area_breakdown`.
- Botones de navegación: «Ver diagnóstico», «Plan de estudio», «Análisis IA».

---

### 14. Diagnóstico académico (reglas)

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Diagnóstico |
| **Objetivo** | Mostrar fortalezas, debilidades y niveles por jerarquía KGAA |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/diagnostics/student-exams/{id}` · `.../areas` · `.../subtopics` |
| **Servicio** | `DiagnosticService` |
| **Modelos** | Snapshots `ExamResult*` |
| **Caso de uso** | CU-07 Consultar diagnóstico académico |

#### Inteligencia Artificial

Todo **No** (clasificación por umbrales).

#### Valor para la Hackathon

- Diferenciador de Pitágoras: perfil granular, no solo %.
- Rúbrica: **C2** — diagnóstico personalizado.
- Valor demo: **muy alto**.

#### Observaciones

- **Unir con Resultados** en una sola pantalla con pestañas «Puntaje» / «Diagnóstico» si hay poco tiempo.
- Usar `strengths` y `weaknesses` del reporte global.

---

### 15. Plan de estudio / Recomendaciones

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Plan de estudio |
| **Objetivo** | Listar recomendaciones por subtema débil y tipo de recurso |
| **Estado** | 🟡 Importante |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/recommendations/student-exams/{id}` |
| **Servicio** | `RecommendationService` |
| **Modelos** | `StudyPlan`, `StudyRecommendation` (DTOs) |
| **Caso de uso** | CU-08 Obtener plan de estudio |

#### Inteligencia Artificial

Todo **No** (reglas).

#### Valor para la Hackathon

- Cierra el arco «evaluación → acción».
- Rúbrica: **C5** — plan adaptativo.
- Valor demo: **alto**.

#### Observaciones

- **Simplificar:** mostrar lista de mensajes por subtema; sin URLs reales (tabla `resources` no implementada).
- Agrupar por `by_resource_type` (Video / Ejercicios / Simulacro).
- Puede ser sección dentro de Resultados.

---

### 16. Análisis IA — Agente Diagnóstico

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Análisis IA |
| **Objetivo** | Informe narrativo del perfil académico post-examen |
| **Estado** | ✅ Obligatoria |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/agents/diagnostic/analyze` |
| **Servicio** | `OrchestratorService.analyze_diagnostic` |
| **Modelos** | `DiagnosticReport` (vía tools), `StudentExam` |
| **Caso de uso** | CU-11 Análisis diagnóstico narrativo (IA) |

#### Inteligencia Artificial

| Campo | Valor |
|-------|-------|
| Agente | **Diagnóstico** |
| RAG | **Sí** (en debilidades) |
| LangGraph | **Sí** |
| Google ADK | **Sí** |

#### Valor para la Hackathon

- IA que interpreta datos, no solo los muestra.
- Rúbrica: **C6** — feedback narrativo inteligente.
- Valor demo: **muy alto**.

#### Observaciones

- **Mantener igual**; disparar automáticamente al entrar en Resultados o con botón «Generar análisis IA».
- Requiere examen `COMPLETED` y API key LLM.
- Mostrar `content` + indicador de carga.

---

### 17. Mensaje motivacional — Agente Motivador

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Motivador |
| **Objetivo** | Mensaje empático y próximos pasos tras el examen |
| **Estado** | 🟡 Importante |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/agents/motivator/encourage` |
| **Servicio** | `OrchestratorService.motivate_student` |
| **Modelos** | `DiagnosticReport`, `StudyPlan` (vía tools) |
| **Caso de uso** | CU-12 Mensaje motivacional |

#### Inteligencia Artificial

| Campo | Valor |
|-------|-------|
| Agente | **Motivador** |
| RAG | No (usa diagnóstico + plan) |
| LangGraph | **Sí** |
| Google ADK | **Sí** |

#### Valor para la Hackathon

- Demuestra multi-agente: rol distinto al Tutor y al Diagnóstico.
- Rúbrica: **C6** + **C7** (orquestación).
- Valor demo: **alto**.

#### Observaciones

- **Simplificar:** tarjeta al final de Resultados, no pantalla dedicada.
- Payload opcional: `student_message` si hay campo de texto.

---

### 18. Perfil del estudiante

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Perfil |
| **Objetivo** | Mostrar nombre, email y datos de cuenta |
| **Estado** | ⚪ Opcional |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `GET /api/v1/auth/me` |
| **Servicio** | `AuthService` |
| **Modelos** | `User`, `Student` |
| **Caso de uso** | CU-01 Auth |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Complemento; no demuestra rúbrica.
- Valor demo: **bajo**.

#### Observaciones

- **Eliminar o minimizar** a ícono en AppBar con menú logout.
- Versión futura: editar perfil (sin endpoint hoy).

---

### 19. Historial de simulacros

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Historial |
| **Objetivo** | Listar exámenes previos del estudiante |
| **Estado** | ❌ Eliminar |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | No existe listado de `student_exams` por estudiante |
| **Servicio** | — (`StudentExamRepository.list_by_student_id` existe pero sin API) |
| **Modelos** | — |
| **Caso de uso** | CU-20 — no implementado |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Sin endpoint; violaría regla de no inventar APIs.
- Valor demo: **nulo**.

#### Observaciones

- **Eliminar** del alcance hackathon.

---

### 20. Login padres

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Login padres |
| **Objetivo** | Autenticar cuenta con rol padre |
| **Estado** | ❌ Eliminar |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | No existe `POST /auth/register` para padres |
| **Servicio** | — |
| **Modelos** | `UserRole.PARENT` reservado sin flujo |
| **Caso de uso** | CU-15 — no implementado |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Sin backend de registro padre.
- Valor demo: **nulo**.

#### Observaciones

- **Eliminar**; versión futura con CU-15/CU-16.

---

### 21. Vincular estudiante (padres)

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Vincular hijo |
| **Objetivo** | Asociar cuenta padre con estudiante |
| **Estado** | ❌ Eliminar |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | Ninguno (`parent_student_links` no existe) |
| **Servicio** | — |
| **Modelos** | — |
| **Caso de uso** | CU-16 — no implementado |

#### Inteligencia Artificial

Todo **No**.

#### Observaciones

- **Eliminar** del alcance hackathon.

---

### 22. Informe para padres — Agente Padres

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Vista padres / Informe |
| **Objetivo** | Mostrar informe de progreso en lenguaje accesible |
| **Estado** | 🟡 Importante |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /api/v1/agents/parents/report` |
| **Servicio** | `OrchestratorService.parent_report` |
| **Modelos** | `DiagnosticReport`, `StudyPlan` (vía tools) |
| **Caso de uso** | CU-13 Informe para padres |

#### Inteligencia Artificial

| Campo | Valor |
|-------|-------|
| Agente | **Padres** |
| RAG | No directo (usa diagnóstico + plan) |
| LangGraph | **Sí** |
| Google ADK | **Sí** |

#### Valor para la Hackathon

- Demuestra cuarto agente y actor padre.
- Rúbrica: **C6** + **C7**.
- Valor demo: **alto** si hay tiempo; accesible sin auth padre (endpoint público hoy).

#### Observaciones

- **Simplificar:** pantalla accesible desde Resultados con toggle «Vista padres»; sin flujo de login padre.
- Mismo `student_exam_id` del simulacro recién completado.

---

### 23. Catálogo académico (exploración)

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Explorar KGAA |
| **Objetivo** | Navegar universidad → subtema |
| **Estado** | ❌ Eliminar |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | CRUD `/universities` … `/subtopics` (existe pero es admin) |
| **Servicio** | Repositorios académicos |
| **Modelos** | Jerarquía KGAA |
| **Caso de uso** | CU-01 Catálogo — API admin, no flujo estudiante |

#### Inteligencia Artificial

Todo **No**.

#### Valor para la Hackathon

- Desvía del flujo demo; catálogo es infraestructura de datos.
- Rúbrica: marginal (**C8**).
- Valor demo: **bajo**.

#### Observaciones

- **Eliminar** del Flutter hackathon; datos viven en seed MySQL.

---

### 24. Panel admin / RAG ingest

#### Información general

| Campo | Detalle |
|-------|---------|
| **Nombre** | Admin / Cargar material |
| **Objetivo** | Indexar PDFs y texto en ChromaDB |
| **Estado** | ❌ Eliminar (de Flutter) |

#### Backend asociado

| Campo | Detalle |
|-------|---------|
| **Endpoints** | `POST /rag/ingest/text` · `POST /rag/ingest/file` |
| **Servicio** | `RAGService` |
| **Modelos** | ChromaDB chunks |
| **Caso de uso** | CU-09 Indexar material |

#### Inteligencia Artificial

RAG en ingest; no agente.

#### Observaciones

- **No implementar en Flutter**; ejecutar ingest vía script o Swagger antes de la demo.
- Prerrequisito para que Tutor y Diagnóstico IA funcionen bien.

---

## Tabla resumen

| Pantalla | Prioridad | Endpoint(s) principal(es) | IA | RAG | Agente | Valor para demo |
| -------- | --------- | ------------------------- | -- | --- | ------ | --------------- |
| Splash | ✅ | `GET /auth/me` | No | No | — | Bajo |
| Bienvenida | 🟡 | — | No | No | — | Medio (story) |
| Login | ✅ | `POST /auth/login` | No | No | — | Alto |
| Registro | ✅ | `POST /auth/register` | No | No | — | Alto |
| Onboarding | ✅ | `GET /universities`, `/areas`, `/careers` | No | No | — | Alto |
| Home | ✅ | Hub local + sesión | No | No | — | Alto |
| Elegir simulacro | ✅ | `GET /exam-templates`, `POST /student-exams`, `POST /student-exams/adaptive` | No | No | — | Muy alto |
| Instrucciones | 🟡 | `GET /exam-templates` | No | No | — | Medio |
| Examen en curso | ✅ | `GET /student-exams/{id}`, `POST .../answers`, `PATCH .../save` | No | No | — | Muy alto |
| Feedback respuesta | ✅ | `POST .../answers` (`is_correct`) | No | No | — | Muy alto |
| Guardar / Repaso | ✅ | `PATCH .../save`, `GET /students/{id}/saved-answers` | Parcial | Sí | Tutor | Muy alto |
| Tutor IA | ✅ | `POST /tutor/explain` | Sí | Sí | Tutor | Muy alto |
| Finalizar examen | 🟡 | `POST .../finish` | No | No | — | Alto |
| Resultados | ✅ | `GET .../results` | No | No | — | Muy alto |
| Diagnóstico | ✅ | `GET /diagnostics/student-exams/{id}` | No | No | — | Muy alto |
| Plan de estudio | 🟡 | `GET /recommendations/student-exams/{id}` | No | No | — | Alto |
| Análisis IA | ✅ | `POST /agents/diagnostic/analyze` | Sí | Sí | Diagnóstico | Muy alto |
| Motivador | 🟡 | `POST /agents/motivator/encourage` | Sí | No | Motivador | Alto |
| Perfil | ⚪ | `GET /auth/me` | No | No | — | Bajo |
| Historial | 🟡 | `GET saved-answers` (parcial) | No | No | — | Medio |
| Login padres | ❌ | — | No | No | — | Nulo |
| Vincular hijo | ❌ | — | No | No | — | Nulo |
| Informe padres | 🟡 | `POST /agents/parents/report` | Sí | No | Padres | Alto |
| Explorar KGAA | ❌ | CRUD catálogo | No | No | — | Bajo |
| Admin RAG | ❌ | `POST /rag/ingest/*` | — | Sí | — | Nulo (Flutter) |

---

## Orden recomendado — Flujo Flutter hackathon

| Orden | Pantalla | Notas |
| ----- | -------- | ----- |
| 1 | Splash | Check token → Login o paso 4 |
| 2 | Login | |
| 3 | Registro | Alternativa a Login |
| 4 | Elegir simulacro | Adaptativo si hay diagnóstico: `POST /student-exams/adaptive` |
| 5 | Examen en curso | Timer + preguntas + submit + **Guardar** |
| 6 | Feedback respuesta | Inline; si error → CTA Tutor |
| 7 | Tutor IA | Modal sobre examen o post-respuesta |
| 8 | Finalizar examen | Diálogo → `POST .../finish` |
| 9 | Resultados + Diagnóstico | Pantalla unificada con pestañas |
| 10 | Respuestas guardadas | `/respuestas-guardadas` — repaso con tutor |
| 11 | Análisis IA | Auto o botón; agente Diagnóstico |
| 11 | Plan de estudio | Sección o pestaña en Resultados |
| 12 | Motivador | Tarjeta al pie de Resultados |
| 13 | Informe padres | Toggle «Vista padres» en Resultados (opcional) |

**Pantallas descartadas del flujo:** Historial completo, Login padres, Vincular hijo, Explorar KGAA, Admin RAG (solo script), Bienvenida (fusionada con Splash si hay prisa).

---

## Conclusiones

### Cuántas pantallas se implementarán

| Categoría | Cantidad |
|-----------|----------|
| Pantallas Figma analizadas | **24** |
| **A implementar en Flutter (hackathon)** | **8–10 vistas efectivas** |
| Obligatorias (✅) | **10** (algunas fusionadas en una sola vista) |
| Importantes (🟡) | **4** (integrar como secciones, no pantallas nuevas) |
| Opcionales (⚪) | **2** |
| Eliminar (❌) | **8** |

**Vistas Flutter recomendadas (conteo realista):**

1. Splash + auth (Login / Registro)
2. Elegir simulacro
3. Examen en curso (incluye feedback inmediato)
4. Tutor IA (modal)
5. Resultados unificados (puntaje + diagnóstico + plan + agentes IA + vista padres)

**Total: 5 rutas principales** (~8–10 si se separan Login/Registro y modales).

### Cuántas se eliminan

**8 pantallas** sin backend o sin valor demo: Historial completo, Login padres, Vincular hijo, Explorar KGAA, Admin RAG en Flutter, y Bienvenida (si se fusiona con Splash).

### Imprescindibles para la rúbrica

| Pantalla | Por qué |
|----------|---------|
| Login / Registro | Identidad del evaluado |
| Elegir simulacro + Examen | **Evaluación inteligente** (C1) |
| Feedback respuesta | **Feedback en tiempo real** (C3) |
| Tutor IA | Feedback pedagógico + RAG (C3, C4) |
| Guardar + Repaso | Evaluación continua y personalización (C2, C3) |
| Resultados + Diagnóstico | Perfil académico (C2) |
| Análisis IA | IA multi-agente post-examen (C6, C7) |

### Para versión futura

- Onboarding con persistencia de preferencias
- Home con historial (`GET /students/{id}/exams`)
- Flujo padres completo (auth + vínculo + dashboard)
- Perfil editable
- Exploración del KGAA para el estudiante
- WebSocket para countdown (mejora C3)
- Plan de estudio con URLs reales (`resources`)

### Pantallas que mejor muestran IA

| Ranking | Pantalla | Capacidad demostrada |
|---------|----------|----------------------|
| 1 | **Tutor IA** | ADK + RAG + KGAA + feedback en el momento del error |
| 2 | **Análisis IA** | Agente Diagnóstico + LangGraph + interpretación narrativa |
| 3 | **Motivador** | Segundo agente especializado; orquestación multi-rol |
| 4 | **Informe padres** | Tercer agente; mismo backend, distinta audiencia |

### Recomendación final de arquitecto UX

Priorizar un **único hilo demo de 3 minutos**:

```
Registro → Onboarding → Diagnóstico (5) → Resultados
→ Simulacro adaptativo (15) → Fallar 1 pregunta → Guardar otra
→ Tutor IA → Finalizar → Resultados → Respuestas guardadas
→ Análisis IA → Motivador
```

Ese flujo cubre la **rúbrica completa** incluyendo evaluación adaptativa y repaso. Actualiza este párrafo cuando cambie el guion de demo.

---

*Documento vivo — última retroalimentación código: 2026-06-27 (tip resolución, revisión post-examen, guardar pregunta).*
