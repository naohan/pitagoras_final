# Plan de implementación Flutter — Pitágoras

**Fuente de verdad:** [`FIGMA_ANALYSIS.md`](FIGMA_ANALYSIS.md)  
**Proyecto frontend:** `frontend/` (paquete `pitagoras_ia`)  
**Rúbrica:** Evaluación Inteligente y Feedback en Tiempo Real  
**Fecha:** 2026-06-26

---

## Alcance

Este documento planifica la implementación del cliente Flutter durante la hackathon. Solo incluye pantallas clasificadas como **✅ Obligatoria** o **🟡 Importante** en `FIGMA_ANALYSIS.md`.

**Convenciones del proyecto frontend:**

| Elemento | Ubicación propuesta |
|----------|---------------------|
| Pantallas | `frontend/lib/screens/` |
| Widgets compartidos | `frontend/lib/widgets/` |
| DTOs / modelos | `frontend/lib/data/models/` |
| Cliente HTTP | `frontend/lib/data/api/` |
| Repositorios | `frontend/lib/data/repositories/` |
| Estado global | `frontend/lib/core/providers/` |
| Tema (existente) | `frontend/lib/core/theme/` |
| Documentación UX | `frontend/docs/FIGMA_ANALYSIS.md` (copia de referencia) |

**Base URL API:** configurable vía `--dart-define=API_BASE_URL=http://localhost:8000` o archivo de entorno local.

**Constantes de demo (seed):** `EXAM_TEMPLATE_ID` hardcodeado según seed UNSA (sin endpoint de listado).

---

## Arquitectura Flutter recomendada

```
UI (Screens / Widgets)
    ↓
Providers (Riverpod) — estado y orquestación
    ↓
Repositories — mapeo DTO ↔ dominio UI
    ↓
ApiClient (Dio/http) — JWT en interceptor
    ↓
FastAPI /api/v1
```

**Gestión de estado global recomendada:** **Riverpod** (`flutter_riverpod`) — ligero, testeable, adecuado para hackathon. Alternativa aceptable: **Provider** si el equipo ya lo domina.

**Sesión:** `AuthSessionProvider` persiste `access_token`, `student_id`, `full_name` (vía `flutter_secure_storage` en móvil; `shared_preferences` en web demo).

---

## Pantallas — detalle de implementación

---

### 1. Splash

| Campo | Detalle |
|-------|---------|
| **Orden** | 1 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `Scaffold`, logo Pitágoras, `CircularProgressIndicator`, fondo con gradiente de marca |
| **Componentes reutilizables** | `PitagorasLogo`, `LoadingOverlay` |
| **Endpoint** | `GET /api/v1/auth/me` (solo si hay token en almacenamiento) |
| **DTO** | `UserResponse` |
| **Modelo** | `AuthUser` (id, email, role, studentId, fullName) |
| **Estado** | **Stateful** (timer + async check) |
| **Gestión de estado** | `SplashController` (Riverpod `AsyncNotifier`) o lógica local mínima |
| **Validaciones** | Token presente y no expirado (401 → limpiar sesión) |
| **Loading** | Indicador central 1–2 s mínimo + mientras valida token |
| **Errores** | 401/403 → borrar token, ir a Login; sin red → ir a Login con snackbar opcional |
| **Navegación** | Token válido → `Elegir simulacro`; sin token → `Login` (o `Bienvenida` si Fase 1 la incluye) |
| **Dependencias** | Ninguna pantalla previa; requiere `AuthSessionProvider` y `ApiClient` con interceptor |

---

### 2. Bienvenida

| Campo | Detalle |
|-------|---------|
| **Orden** | 2 (alternativa a Splash directo → Login) |
| **Prioridad** | 🟡 Importante |
| **Widgets principales** | Hero con mascota (`MascotHero` existente), título, subtítulo, `ElevatedButton` «Iniciar sesión», `OutlinedButton` «Registrarse» |
| **Componentes reutilizables** | `MascotHero`, `PrimaryButton`, `SecondaryButton` |
| **Endpoint** | Ninguno |
| **DTO** | — |
| **Modelo** | — |
| **Estado** | **Stateless** |
| **Gestión de estado** | Ninguna |
| **Validaciones** | — |
| **Loading** | No aplica |
| **Errores** | No aplica |
| **Navegación** | → `Login` / → `Registro` |
| **Dependencias** | Opcional tras `Splash`; puede fusionarse con Splash si hay prisa (FIGMA_ANALYSIS §2) |

---

### 3. Login

| Campo | Detalle |
|-------|---------|
| **Orden** | 3 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `Form`, `TextFormField` (email, password), `ElevatedButton`, enlace a Registro, `LoginHeader`, `LoginBottomCard` (widgets existentes en `lib/screens/auth/`) |
| **Componentes reutilizables** | `AuthTextField`, `PasswordField`, `PrimaryButton`, `AuthScaffold` |
| **Endpoint** | `POST /api/v1/auth/login` |
| **DTO request** | `LoginRequest` { email, password } |
| **DTO response** | `TokenResponse` { access_token, token_type, expires_in, user } |
| **Modelo** | `AuthSession`, `AuthUser` |
| **Estado** | **Stateful** (`Form` + submit) |
| **Gestión de estado** | `AuthNotifier` (Riverpod) — login, logout, persistencia |
| **Validaciones** | Email formato válido; password no vacío; mensajes en español |
| **Loading** | Botón deshabilitado + `CircularProgressIndicator` en submit |
| **Errores** | 401 → «Correo o contraseña incorrectos»; 403 → cuenta inactiva; timeout → reintentar |
| **Navegación** | Éxito → `Elegir simulacro` (reemplaza stack) |
| **Dependencias** | `Splash` o `Bienvenida`; provee sesión a todas las pantallas siguientes |

---

### 4. Registro

| Campo | Detalle |
|-------|---------|
| **Orden** | 4 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `Form`, campos `full_name`, `email`, `password`, confirmación password (solo UI), `ElevatedButton`, enlace a Login |
| **Componentes reutilizables** | `AuthTextField`, `PasswordField`, `PrimaryButton`, `AuthScaffold` |
| **Endpoint** | `POST /api/v1/auth/register` |
| **DTO request** | `RegisterRequest` { email, password, full_name } — password min 8 chars |
| **DTO response** | `TokenResponse` |
| **Modelo** | `AuthSession`, `AuthUser` |
| **Estado** | **Stateful** |
| **Gestión de estado** | `AuthNotifier.register()` |
| **Validaciones** | full_name ≥ 2 chars; email válido; password ≥ 8; confirmación coincide |
| **Loading** | Igual que Login |
| **Errores** | 409 → «El correo ya está registrado»; 400 → detalle del backend |
| **Navegación** | Éxito → `Elegir simulacro` (saltar Onboarding) |
| **Dependencias** | Alternativa a Login; comparte `AuthNotifier` |

---

### 5. Elegir simulacro

| Campo | Detalle |
|-------|---------|
| **Orden** | 5 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `AppBar` con logout, tarjeta `SimulacroCard` (nombre UNSA, duración, N preguntas), `ElevatedButton` «Comenzar simulacro» |
| **Componentes reutilizables** | `SimulacroCard`, `InfoChip` (duración, preguntas), `PrimaryButton`, `AppBarWithLogout` |
| **Endpoints** | `GET /api/v1/exam-templates/{template_id}` · `POST /api/v1/student-exams` |
| **DTO request** | `StartStudentExamRequest` { student_id, exam_template_id } |
| **DTO response** | `ExamTemplateResponse`, `StudentExamResponse` |
| **Modelo** | `ExamTemplate`, `StudentExam` (id, status, questions[]) |
| **Estado** | **Stateful** o **ConsumerStateful** |
| **Gestión de estado** | `ExamSetupNotifier` — carga plantilla + inicia sesión |
| **Validaciones** | `student_id` desde sesión no nulo; `template_id` desde constante de config |
| **Loading** | Skeleton de tarjeta al cargar plantilla; overlay al crear `student-exam` |
| **Errores** | 404 plantilla → mensaje «Simulacro no disponible»; 400 → detalle API |
| **Navegación** | «Comenzar» → `Examen en curso` con `studentExamId` |
| **Dependencias** | Requiere `Login` o `Registro` (JWT + student_id); instrucciones fusionadas aquí (FIGMA_ANALYSIS §8) |

---

### 6. Examen en curso

| Campo | Detalle |
|-------|---------|
| **Orden** | 6 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `AppBar` con timer, `LinearProgressIndicator` (pregunta X de N), `QuestionCard` (stem), lista `OptionTile` (radio), botones «Anterior» / «Siguiente» / «Finalizar» |
| **Componentes reutilizables** | `ExamTimer`, `QuestionCard`, `OptionTile`, `ExamProgressBar`, `PrimaryButton` |
| **Endpoints** | `GET /api/v1/student-exams/{id}` · `GET .../time` · `POST .../answers` |
| **DTO request** | `SubmitAnswerRequest` { question_id, selected_option_id, time_seconds? } |
| **DTO response** | `StudentExamResponse`, `ExamTimeStatusResponse`, `StudentAnswerResponse` |
| **Modelo** | `StudentExam`, `QuestionForExam`, `QuestionOption`, `ExamTimeStatus`, `StudentAnswer` |
| **Estado** | **Stateful** |
| **Gestión de estado** | `ExamSessionNotifier` — índice pregunta, respuestas locales, polling timer |
| **Validaciones** | Opción seleccionada antes de submit; bloquear submit si examen expirado (409) |
| **Loading** | Spinner breve al enviar respuesta; timer actualizado cada 5–10 s vía polling |
| **Errores** | 409 `exam_time_expired` → forzar diálogo finalizar; 400 opción inválida |
| **Navegación** | Última pregunta → diálogo `Finalizar examen`; durante examen → modal `Tutor IA` |
| **Dependencias** | `Elegir simulacro` (studentExamId); integra **Feedback respuesta** inline |

---

### 7. Feedback respuesta (inline en Examen)

| Campo | Detalle |
|-------|---------|
| **Orden** | 7 (mismo flujo que Examen; no es ruta separada) |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `Banner` / `AnimatedContainer` verde (correcto) o rojo (incorrecto), icono ✓/✗, texto breve, `TextButton` «Preguntar al Tutor» si `is_correct == false` |
| **Componentes reutilizables** | `AnswerFeedbackBanner`, `TutorCtaButton` |
| **Endpoint** | `POST /api/v1/student-exams/{id}/answers` (campo `is_correct` en response) |
| **DTO** | `StudentAnswerResponse` |
| **Modelo** | `StudentAnswer` (isCorrect, questionId) |
| **Estado** | **Stateful** (estado local en `ExamSessionNotifier`) |
| **Gestión de estado** | Parte de `ExamSessionNotifier` |
| **Validaciones** | Mostrar solo tras submit exitoso |
| **Loading** | Inline en botón «Confirmar respuesta» |
| **Errores** | Hereda errores de submit del examen |
| **Navegación** | CTA Tutor → abre modal `Tutor IA` con `questionId` + `selectedOptionId` |
| **Dependencias** | `Examen en curso`; precede opcionalmente `Tutor IA` |

---

### 8. Tutor IA

| Campo | Detalle |
|-------|---------|
| **Orden** | 8 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | `ModalBottomSheet` o `Dialog` fullscreen, contexto académico (área/subtema), `TextField` opcional (duda), área scroll con explicación Markdown/texto, chips `RagSourceChip`, botón cerrar |
| **Componentes reutilizables** | `TutorSheet`, `AiLoadingIndicator`, `RagSourceList`, `AcademicContextHeader`, `MarkdownBody` (opcional) |
| **Endpoint** | `POST /api/v1/tutor/explain` |
| **DTO request** | `TutorExplainRequest` { question_id, selected_option_id?, student_message?, top_k? } |
| **DTO response** | `TutorExplainResponse` { explanation, academic_context, rag_sources[], llm_model, llm_provider } |
| **Modelo** | `TutorExplanation`, `AcademicContext`, `RagSource` |
| **Estado** | **Stateful** |
| **Gestión de estado** | `TutorNotifier` — `AsyncValue<TutorExplanation>` |
| **Validaciones** | `question_id` obligatorio |
| **Loading** | Skeleton + mensaje «El tutor está analizando…» (LLM lento, 5–30 s) |
| **Errores** | 404 pregunta; 502/503 LLM → «Tutor no disponible, intenta más tarde»; timeout extendido |
| **Navegación** | Cerrar → vuelve a `Examen en curso` |
| **Dependencias** | `Feedback respuesta` o selección manual de pregunta; requiere RAG indexado en backend |

---

### 9. Finalizar examen

| Campo | Detalle |
|-------|---------|
| **Orden** | 9 |
| **Prioridad** | 🟡 Importante |
| **Widgets principales** | `AlertDialog` confirmación, texto advertencia omisiones, botones «Cancelar» / «Finalizar» |
| **Componentes reutilizables** | `ConfirmDialog`, `PrimaryButton`, `SecondaryButton` |
| **Endpoint** | `POST /api/v1/student-exams/{id}/finish` |
| **DTO response** | `StudentExamResultResponse` |
| **Modelo** | `StudentExamResult`, `ExamResult` |
| **Estado** | **Stateless** (diálogo) + loading en padre |
| **Gestión de estado** | `ExamSessionNotifier.finishExam()` |
| **Validaciones** | Confirmación explícita del usuario |
| **Loading** | Overlay fullscreen «Calificando examen…» |
| **Errores** | 409 examen ya completado → ir a Resultados; 400 estado inválido |
| **Navegación** | Éxito → `Resultados` (pantalla unificada) con `studentExamId` |
| **Dependencias** | `Examen en curso`; precede `Resultados`, `Diagnóstico`, agentes IA |

---

### 10. Resultados

| Campo | Detalle |
|-------|---------|
| **Orden** | 10 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | Score circular o grande (%), lista `AreaScoreTile` con barras de progreso, pestañas o secciones para navegar a diagnóstico/IA |
| **Componentes reutilizables** | `ScoreHeader`, `AreaBreakdownList`, `BreakdownBar`, `TabSection` |
| **Endpoint** | `GET /api/v1/student-exams/{id}/results` |
| **DTO** | `StudentExamResultResponse` { exam_result, area_breakdown, component_breakdown, … } |
| **Modelo** | `ExamResult`, `BreakdownItem` |
| **Estado** | **Stateful** (pestañas) |
| **Gestión de estado** | `ResultsNotifier` — carga paralela de resultados + diagnóstico + recomendaciones + agentes |
| **Validaciones** | Examen debe estar `completed` |
| **Loading** | `Shimmer` o skeleton en score y barras |
| **Errores** | 404 → «Resultados no encontrados» |
| **Navegación** | Punto de entrada post-examen; hospeda secciones Diagnóstico, Plan, IA |
| **Dependencias** | `Finalizar examen`; padre de pestañas 11–17 |

---

### 11. Diagnóstico

| Campo | Detalle |
|-------|---------|
| **Orden** | 11 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | Listas «Fortalezas» / «Debilidades», `DiagnosticLevelChip` (strength/neutral/weakness), barras por área/subtema |
| **Componentes reutilizables** | `StrengthWeaknessList`, `DiagnosticItemTile`, `LevelBadge` |
| **Endpoints** | `GET /api/v1/diagnostics/student-exams/{id}` · opcional `.../areas`, `.../subtopics` |
| **DTO** | `DiagnosticReportResponse` (global_score_percent, strengths[], weaknesses[], areas[], subtopics[]) |
| **Modelo** | `DiagnosticReport`, `DiagnosticItem` |
| **Estado** | **Stateless** si datos vienen del padre; **Stateful** si carga independiente |
| **Gestión de estado** | `ResultsNotifier` o `DiagnosticNotifier` |
| **Validaciones** | — |
| **Loading** | Sección dentro de Resultados; spinner si carga async |
| **Errores** | 404 / examen no completado |
| **Navegación** | Pestaña o sección dentro de `Resultados` |
| **Dependencias** | `Resultados`; complementa antes de `Análisis IA` |

---

### 12. Plan de estudio

| Campo | Detalle |
|-------|---------|
| **Orden** | 12 |
| **Prioridad** | 🟡 Importante |
| **Widgets principales** | `estimated_days`, lista agrupada por `by_resource_type` (Video, Ejercicios, Simulacro), `RecommendationTile` con mensaje y subtema |
| **Componentes reutilizables** | `RecommendationTile`, `ResourceTypeSection`, `StudyPlanHeader` |
| **Endpoint** | `GET /api/v1/recommendations/student-exams/{id}` |
| **DTO** | `StudyPlanResponse` { recommendations[], by_resource_type, focus_subtopics[], estimated_days } |
| **Modelo** | `StudyPlan`, `StudyRecommendation` |
| **Estado** | **Stateless** (sección) |
| **Gestión de estado** | `ResultsNotifier` |
| **Validaciones** | — |
| **Loading** | Inline en sección |
| **Errores** | Mostrar mensaje vacío si no hay recomendaciones |
| **Navegación** | Pestaña «Plan de estudio» en `Resultados` |
| **Dependencias** | `Resultados`; sin URLs reales (solo mensajes) |

---

### 13. Análisis IA (Agente Diagnóstico)

| Campo | Detalle |
|-------|---------|
| **Orden** | 13 |
| **Prioridad** | ✅ Obligatoria |
| **Widgets principales** | Tarjeta con icono IA, texto narrativo scrollable, badge «Generado por IA», botón «Regenerar» opcional |
| **Componentes reutilizables** | `AiInsightCard`, `AiLoadingIndicator`, `AgentBadge` |
| **Endpoint** | `POST /api/v1/agents/diagnostic/analyze` |
| **DTO request** | `AgentRunRequest` { student_exam_id, student_message? } |
| **DTO response** | `AgentRunResponse` { content, agent_name, rag_sources[], metadata } |
| **Modelo** | `AgentInsight` |
| **Estado** | **Stateful** |
| **Gestión de estado** | `DiagnosticAgentNotifier` — auto-fetch al entrar en Resultados o bajo demanda |
| **Validaciones** | `student_exam_id` obligatorio |
| **Loading** | Card con spinner y texto «Analizando tu perfil…» (10–40 s) |
| **Errores** | 409 examen no completado; 502 LLM; mostrar fallback con datos de Diagnóstico reglas |
| **Navegación** | Sección en `Resultados` |
| **Dependencias** | `Finalizar examen` + `Diagnóstico` (datos base); requiere API key LLM |

---

### 14. Motivador

| Campo | Detalle |
|-------|---------|
| **Orden** | 14 |
| **Prioridad** | 🟡 Importante |
| **Widgets principales** | Tarjeta motivacional con tono positivo, `TextField` opcional para mensaje del estudiante, botón «Recibir ánimo» |
| **Componentes reutilizables** | `MotivatorCard`, `AiInsightCard`, `AiLoadingIndicator` |
| **Endpoint** | `POST /api/v1/agents/motivator/encourage` |
| **DTO request** | `AgentRunRequest` { student_exam_id, student_message? } |
| **DTO response** | `AgentRunResponse` |
| **Modelo** | `AgentInsight` |
| **Estado** | **Stateful** |
| **Gestión de estado** | `MotivatorNotifier` |
| **Validaciones** | — |
| **Loading** | Bajo demanda al pulsar botón o auto al expandir sección |
| **Errores** | Igual que Análisis IA |
| **Navegación** | Tarjeta al pie de `Resultados` |
| **Dependencias** | `Resultados`; opcionalmente después de `Análisis IA` |

---

### 15. Vista padres / Informe

| Campo | Detalle |
|-------|---------|
| **Orden** | 15 |
| **Prioridad** | 🟡 Importante |
| **Widgets principales** | `Switch` «Vista padres», tarjeta con tono formal/accesible, informe estructurado (resumen, fortalezas, mejoras, cómo apoyar) |
| **Componentes reutilizables** | `ParentsReportCard`, `AiInsightCard`, `ViewModeToggle` |
| **Endpoint** | `POST /api/v1/agents/parents/report` |
| **DTO request** | `AgentRunRequest` { student_exam_id } |
| **DTO response** | `AgentRunResponse` |
| **Modelo** | `AgentInsight` |
| **Estado** | **Stateful** |
| **Gestión de estado** | `ParentsAgentNotifier` — carga al activar toggle |
| **Validaciones** | — |
| **Loading** | Spinner en tarjeta al activar vista padres |
| **Errores** | Igual que otros agentes; sin auth padre (endpoint público hoy) |
| **Navegación** | Toggle en `Resultados`; sin flujo login padre |
| **Dependencias** | `Resultados`; última sección opcional de Fase 4 |

---

## Componentes reutilizables — catálogo global

| Componente | Usado en |
|------------|----------|
| `PitagorasLogo` | Splash, Bienvenida |
| `MascotHero` | Bienvenida, Login (existente) |
| `AuthTextField` / `PasswordField` | Login, Registro |
| `PrimaryButton` / `SecondaryButton` | Todas las pantallas |
| `LoadingOverlay` | Login, Registro, Elegir simulacro, Finalizar |
| `AppBarWithLogout` | Elegir simulacro, Examen, Resultados |
| `ExamTimer` | Examen en curso |
| `QuestionCard` / `OptionTile` | Examen en curso |
| `AnswerFeedbackBanner` | Feedback inline |
| `TutorSheet` | Tutor IA |
| `AiLoadingIndicator` | Tutor, Análisis IA, Motivador, Padres |
| `AiInsightCard` | Análisis IA, Motivador, Padres |
| `ScoreHeader` / `BreakdownBar` | Resultados |
| `DiagnosticItemTile` / `LevelBadge` | Diagnóstico |
| `RecommendationTile` | Plan de estudio |
| `ConfirmDialog` | Finalizar examen |

---

## Planificación por fases

### Fase 0 — Fundación (prerrequisito, ~4 h)

**No es pantalla; bloquea todo lo demás.**

- Estructura de carpetas en `frontend/lib/`
- Dependencias: `flutter_riverpod`, `dio`, `flutter_secure_storage` (o `shared_preferences`), `json_annotation` + `build_runner`
- `ApiClient` con base URL y interceptor JWT (`Authorization: Bearer`)
- `AuthSessionProvider` + persistencia de token
- Modelos/DTOs base: `AuthUser`, `TokenResponse`
- Copiar `docs/FIGMA_ANALYSIS.md` → `frontend/docs/FIGMA_ANALYSIS.md`
- Router: `go_router` o `Navigator 2.0` simplificado

---

### Fase 1 — Autenticación (~6 h)

| Pantalla | Notas |
|----------|-------|
| Splash | Timer + validación token |
| Bienvenida | Opcional; reutilizar mascota y tema existente |
| Login | Adaptar `login_page.dart` existente al contrato API |
| Registro | Nueva pantalla o adaptar `phone_page.dart` al flujo email |

**Entregable:** usuario puede registrarse, iniciar sesión y llegar a ruta protegida.

---

### Fase 2 — Simulacro y evaluación en vivo (~10 h)

| Pantalla | Notas |
|----------|-------|
| Elegir simulacro | `template_id` fijo; fusionar instrucciones |
| Examen en curso | Timer polling + navegación preguntas |
| Feedback respuesta | Inline en examen |
| Finalizar examen | Diálogo + `POST .../finish` |

**Entregable:** flujo completo hasta calificación sin IA.

---

### Fase 3 — Resultados, diagnóstico y Tutor IA (~10 h)

| Pantalla | Notas |
|----------|-------|
| Resultados | Score + desglose por área |
| Diagnóstico | Pestaña en Resultados |
| Tutor IA | Modal desde feedback de error |

**Entregable:** demo cubre rúbrica C1–C4 (evaluación + feedback tiempo real + tutor RAG).

---

### Fase 4 — Agentes IA y cierre (~8 h)

| Pantalla | Notas |
|----------|-------|
| Análisis IA | Agente Diagnóstico — prioridad máxima de fase |
| Plan de estudio | Pestaña recomendaciones |
| Motivador | Tarjeta en Resultados |
| Vista padres | Toggle opcional si hay tiempo |

**Entregable:** demo 3 minutos completa según FIGMA_ANALYSIS (Registro → examen → tutor → resultados → IA → motivador).

---

## Mapa de rutas (go_router sugerido)

| Ruta | Pantalla | Auth |
|------|----------|------|
| `/` | Splash | No |
| `/welcome` | Bienvenida | No |
| `/login` | Login | No |
| `/register` | Registro | No |
| `/simulacro` | Elegir simulacro | Sí |
| `/examen/:id` | Examen en curso | Sí |
| `/resultados/:id` | Resultados (tabs) | Sí |

Modales (no rutas): `TutorSheet`, `ConfirmFinishDialog`.

---

## Riesgos técnicos

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| **CORS** en web Flutter | Bloqueo de API | Configurar CORS en FastAPI para origen dev; probar en emulador Android si web falla |
| **Latencia LLM** (Tutor, agentes) | UX pobre en demo | Loading explícito; ensayar con API key válida; timeout 60 s; mensaje de espera |
| **RAG vacío** | Tutor genérico | Indexar material vía Swagger/script antes de demo (FIGMA_ANALYSIS §24) |
| **Sin listado de plantillas** | UI rígida | `EXAM_TEMPLATE_ID` en config/seed documentado |
| **`student_id` manual en body** | Desincronización sesión | Leer siempre de `AuthUser.studentId` del JWT |
| **Polling timer** | Batería / requests | Intervalo 10 s; cancelar timer al salir de examen |
| **Examen expirado (409)** | Flujo roto | Diálogo forzado a finalizar |
| **Auth no obligatoria en exámenes** | Riesgo de seguridad demo | Enviar JWT igualmente; preparar CU-02 sin bloquear hackathon |
| **Proyecto Flutter sin capa API** | Retraso Fase 2+ | Completar Fase 0 antes de pantallas |
| **`phone_page.dart` existente** | Confusión con Registro email | Renombrar o reemplazar según contrato `RegisterRequest` |

---

## Dependencias

### Dependencias Flutter (añadir a `pubspec.yaml`)

| Paquete | Uso |
|---------|-----|
| `flutter_riverpod` | Estado global |
| `dio` | Cliente HTTP |
| `flutter_secure_storage` | Token (móvil) |
| `shared_preferences` | Token (web fallback) |
| `go_router` | Navegación declarativa |
| `json_annotation` + `json_serializable` | DTOs |
| `intl` | Formato de porcentajes y tiempo |

### Dependencias entre pantallas

```
Splash → Login/Registro → Elegir simulacro → Examen (+ Feedback) ⇄ Tutor IA
                                              ↓
                                    Finalizar → Resultados
                                                  ├─ Diagnóstico
                                                  ├─ Plan de estudio
                                                  ├─ Análisis IA
                                                  ├─ Motivador
                                                  └─ Vista padres
```

### Dependencias externas (backend / infra)

| Dependencia | Requerida para |
|-------------|----------------|
| API FastAPI en marcha | Todas las pantallas excepto Bienvenida |
| MySQL con seed UNSA | Elegir simulacro, Examen |
| `GEMINI_API_KEY` o `OPENAI_API_KEY` | Tutor IA, Análisis IA, Motivador, Padres |
| ChromaDB con RAG indexado | Tutor IA, Análisis IA (calidad) |
| Migración `001_cu01_auth.sql` | Login, Registro |

---

## Orden recomendado de desarrollo

| # | Tarea | Fase |
|---|-------|------|
| 1 | Fase 0: ApiClient + AuthSession + router | 0 |
| 2 | Splash + Login + Registro | 1 |
| 3 | DTOs de examen + `ExamSetupNotifier` | 2 |
| 4 | Elegir simulacro | 2 |
| 5 | Examen en curso + timer + submit | 2 |
| 6 | Feedback inline + diálogo finalizar | 2 |
| 7 | Resultados + DTOs de breakdown | 3 |
| 8 | Diagnóstico (pestaña) | 3 |
| 9 | Tutor IA modal + DTOs tutor | 3 |
| 10 | Análisis IA (agente) | 4 |
| 11 | Plan de estudio (pestaña) | 4 |
| 12 | Motivador + Vista padres | 4 |
| 13 | Bienvenida (si hay tiempo) | 1 |
| 14 | Pulido: errores, loading, logout, ensayo demo 3 min | 4 |

---

## Criterio de aceptación hackathon

Flujo ejecutable en `frontend` sin nuevos endpoints:

```
Splash → Registro → Elegir simulacro → Examen
  → (fallar pregunta) → Feedback → Tutor IA
  → Finalizar → Resultados → Diagnóstico
  → Análisis IA → [Motivador] → [Vista padres]
```

**5 rutas principales, 15 piezas de UI** (incluyendo modales y secciones), alineadas con `FIGMA_ANALYSIS.md`.

---

*Documento generado para `frontend` — hackathon Pitágoras 2026.*

---

## Fase 0.5 — Capa de comunicación con FastAPI

**Fecha:** 2026-06-26  
**Alcance:** Cliente HTTP, DTOs y clases API por dominio. Sin Providers, Repositories, pantallas ni consumo desde UI.

---

### 1. Estado del proyecto

| Componente | Estado |
|------------|--------|
| `ApiClient` + `request` / `requestList` | ✅ |
| `ApiException` + `ApiErrorHandler` | ✅ |
| `JwtInterceptor` (`AuthInterceptor`) | ✅ |
| `ErrorInterceptor` | ✅ |
| `BaseResponse<T>` | ✅ |
| `AuthApi` | ✅ 3 métodos |
| `ExamApi` | ✅ 6 métodos |
| `TutorApi` | ✅ 1 método |
| `ResultsApi` | ✅ 10 métodos |
| DTOs alineados a Pydantic backend | ✅ |
| Providers de dominio | No implementado (Fase 1+) |
| Repositories | No implementado (Fase 1+) |

---

### 2. Qué se implementó

#### Infraestructura HTTP

- **`ApiClient.request`** / **`requestList`** — envoltorio uniforme que devuelve `BaseResponse<T>` o lanza `ApiException`.
- **`ApiPaths`** — rutas relativas a `AppConfig.apiRoot` (`/api/v1`).
- **`jwt_interceptor.dart`** — alias `JwtInterceptor` → `AuthInterceptor`.

#### Clases API (un método por endpoint)

| Clase | Métodos |
|-------|---------|
| `AuthApi` | `register`, `login`, `getMe` |
| `ExamApi` | `getExamTemplate`, `startStudentExam`, `getStudentExam`, `getExamTimeStatus`, `submitAnswer`, `finishStudentExam` |
| `TutorApi` | `explain` |
| `ResultsApi` | `getStudentExamResults`, `getDiagnostic`, `getDiagnosticAreas`, `getDiagnosticComponents`, `getDiagnosticTopics`, `getDiagnosticSubtopics`, `getStudyPlan`, `analyzeDiagnostic`, `encourageStudent`, `parentReport` |

#### DTOs (`lib/data/dto/`)

| Archivo | Contenido |
|---------|-----------|
| `auth_dto.dart` | Login/Register request, Token/User response |
| `exam_dto.dart` | Plantilla, sesión, respuestas, tiempo, resultados |
| `tutor_dto.dart` | Tutor explain request/response, RAG sources |
| `results_dto.dart` | Diagnóstico, plan de estudio, agentes IA |
| `json_parse.dart` | Helpers `parseDecimal`, `parseDateTime` |

---

### 3. Flujo de una llamada API

```
AuthApi / ExamApi / TutorApi / ResultsApi
        ↓
ApiClient.request() o requestList()
        ↓
Dio (+ JwtInterceptor + ErrorInterceptor)
        ↓
FastAPI /api/v1
        ↓
BaseResponse<T>  |  throw ApiException
```

---

### 4. Archivos creados

```
frontend/lib/data/
├── api/
│   ├── api_paths.dart
│   ├── base_response.dart
│   ├── auth_api.dart
│   ├── exam_api.dart
│   ├── tutor_api.dart
│   ├── results_api.dart
│   └── interceptors/jwt_interceptor.dart
└── dto/
    ├── auth_dto.dart
    ├── exam_dto.dart
    ├── tutor_dto.dart
    ├── results_dto.dart
    ├── json_parse.dart
    └── dto.dart
```

**Modificados:** `api_client.dart`, `api.dart`.

---

### 5. Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| `BaseResponse<T>` | Envolver `data` + `statusCode` en respuestas exitosas |
| `ApiClient` | Dio, interceptores, `request` uniforme |
| `*Api` | Un método HTTP por endpoint; sin lógica de UI |
| `*_dto.dart` | Serialización JSON ↔ contratos FastAPI |
| `ApiException` | Error de dominio HTTP para capas superiores |

---

### 6. Dependencias

```
AuthApi / ExamApi / TutorApi / ResultsApi
  → ApiClient
    → SessionManager (JWT)
    → Dio
      → FastAPI
```

**Próxima capa (Fase 1):** Providers que instancien `*Api` vía `apiClientProvider` y persistan sesión tras `AuthApi.login` / `register`.

---

### 7. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| C-01 | `ResultsApi` agrupa resultados + diagnóstico + recomendaciones + agentes | Alineado al prompt; todo es post-examen |
| C-02 | DTOs manuales (`fromJson`/`toJson`) | Sin `build_runner` en bootstrap; suficiente para hackathon |
| C-03 | `request` / `requestList` centralizados | Manejo uniforme de `ApiException` |
| C-04 | Rutas en `ApiPaths` | Evita strings duplicados en cada API |
| C-05 | Sin Providers ni Repositories en esta fase | Alcance explícito del prompt |

---

### 8. Posibles mejoras futuras

- `json_serializable` + `build_runner` para DTOs extensos.
- `AuthApiProvider`, `ExamApiProvider`, etc. en Fase 1.
- Repositories que mapeen DTO → modelos UI.
- Tests unitarios con `MockAdapter` de Dio.

---

### 9. Próximo paso recomendado

**Fase 1 — Auth UI:** `AuthNotifier` que use `AuthApi.login` / `register` / `getMe` y persista token con `SessionManager`.

---

### Actualización orden de desarrollo

| # | Tarea | Fase | Estado |
|---|-------|------|--------|
| 0.5 | Capa API + DTOs | 0.5 | ✅ |
| 0.6 | Modelos + Mappers por dominio | 0.6 | ✅ |
| 0.7 | Repositories (Api → Model) | 0.7 | ✅ |
| 0.8 | Providers Riverpod | 0.8 | ✅ |
| 1 | Fase 0: ApiClient + AuthSession + router | 0 | ✅ |
| 2 | Splash + Login + Registro | 1 | Pendiente |

---

## Fase 0.7 — Repositories

**Fecha:** 2026-06-26  
**Alcance:** Repositorios que delegan en `*Api`, mapean DTO → Model y devuelven modelos de dominio. Sin Providers, pantallas ni lógica visual.

---

### 1. Estado del proyecto

| Componente | Estado |
|------------|--------|
| `AuthRepository` | ✅ 3 métodos → `AuthApi` |
| `ExamRepository` | ✅ 6 métodos → `ExamApi` |
| `TutorRepository` | ✅ 1 método → `TutorApi` |
| `ResultsRepository` | ✅ 10 métodos → `ResultsApi` |
| Providers de dominio | No implementado (Fase 1+) |
| Pantallas | No implementado (Fase 1+) |

---

### 2. Mapeo Repository ↔ Api

| Repository | Api | Métodos |
|------------|-----|---------|
| `AuthRepository` | `AuthApi` | `register`, `login`, `getMe` |
| `ExamRepository` | `ExamApi` | `getExamTemplate`, `startStudentExam`, `getStudentExam`, `getExamTimeStatus`, `submitAnswer`, `finishStudentExam` |
| `TutorRepository` | `TutorApi` | `explain` |
| `ResultsRepository` | `ResultsApi` | `getStudentExamResults`, `getDiagnostic`, `getDiagnosticAreas/Components/Topics/Subtopics`, `getStudyPlan`, `analyzeDiagnostic`, `encourageStudent`, `parentReport` |

**Nota:** No existe `QuestionApi` en el cliente; las preguntas en contexto de examen llegan vía `ExamRepository.getStudentExam`. Los dominios Answer, Diagnostic y Agents se exponen a través de `ExamRepository` y `ResultsRepository` respectivamente, alineados a sus APIs HTTP.

---

### 3. Flujo de un Repository

```
Provider [Fase 1+]
    ↓
Repository.method(dto / params)
    ↓
*Api → BaseResponse<Dto>
    ↓
*Mapper.to*(dto.data)
    ↓
Model (o ApiException propagada)
```

---

### 4. Archivos creados

```
frontend/lib/data/repositories/
├── base_repository.dart
├── auth_repository.dart
├── exam_repository.dart
├── tutor_repository.dart
├── results_repository.dart
└── repositories.dart
```

**Modificado:** `base_repository.dart` — marcador sin `ApiClient` (cada repo recibe su `*Api`).

---

### 5. Responsabilidades

| Capa | Responsabilidad |
|------|-----------------|
| `*Api` | HTTP + parseo JSON → DTO |
| `*Repository` | Orquestar Api + Mapper; retornar `Model` |
| `*Mapper` | DTO → Model |
| Provider [pendiente] | Estado, sesión, navegación |

---

### 6. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| R-01 | 4 repositorios = 4 clases Api | Una API por repositorio; sin acoplar repos entre sí |
| R-02 | Requests con DTO existentes | Alineado al prompt; responses con Model |
| R-03 | `finishStudentExam` en `ExamRepository` | Endpoint en `ExamApi`; resultado mapeado con `ResultsMapper` |
| R-04 | Diagnóstico y agentes en `ResultsRepository` | Todos los endpoints viven en `ResultsApi` |
| R-05 | Sin `QuestionRepository` | No hay `QuestionApi` en el cliente hackathon |

---

### 7. Próximo paso recomendado

**Fase 1 — Auth UI:** Providers (`authRepositoryProvider`, `authNotifierProvider`) que instancien repos y persistan sesión tras `AuthRepository.login` / `register`.

---

*Última actualización: 2026-06-26 — Fase 0.7 completada (repositories).*

---

## Fase 0.6 — Modelos y DTOs por dominio

**Fecha:** 2026-06-26  
**Alcance:** DTOs completos alineados a Pydantic, modelos de dominio UI y mappers DTO → Model. Sin Providers, Repositories, pantallas ni lógica visual.

---

### 1. Estado del proyecto

| Componente | Estado |
|------------|--------|
| DTOs Auth | ✅ `LoginRequest`, `RegisterRequest`, `UserResponse`, `TokenResponse` |
| DTOs Exam | ✅ plantilla, sesión, tiempo (+ `template_questions`) |
| DTOs Question | ✅ CRUD + variantes examen (`QuestionForExam`) |
| DTOs Answer | ✅ `SubmitAnswerRequest`, `StudentAnswerResponse` |
| DTOs Results | ✅ resultados, breakdown, plan de estudio |
| DTOs Diagnostic | ✅ reporte + ítems por nivel |
| DTOs Tutor | ✅ explain request/response, RAG |
| DTOs Agents | ✅ `AgentRunRequest`, `AgentRunResponse` |
| Enums compartidos | ✅ `QuestionLevel`, `StudentExamStatus`, `UserRole`, `PerformanceLevel` |
| Models (8 dominios) | ✅ |
| Mappers (8 dominios) | ✅ |
| Providers / Repositories | No implementado (Fase 1+) |

---

### 2. Estructura de archivos

```
frontend/lib/data/
├── enums.dart
├── dto/
│   ├── auth_dto.dart
│   ├── exam_dto.dart
│   ├── question_dto.dart
│   ├── answer_dto.dart
│   ├── results_dto.dart
│   ├── diagnostic_dto.dart
│   ├── tutor_dto.dart
│   ├── agents_dto.dart
│   └── dto.dart
├── models/
│   ├── auth_model.dart      → AuthUser, AuthSession
│   ├── exam_model.dart      → ExamTemplate, StudentExam, ExamTimeStatus
│   ├── question_model.dart  → Question, QuestionForExam, QuestionOption*
│   ├── answer_model.dart    → StudentAnswer
│   ├── results_model.dart   → ExamResult, BreakdownItem, StudentExamResult, StudyPlan
│   ├── diagnostic_model.dart→ DiagnosticReport, DiagnosticItem
│   ├── tutor_model.dart     → TutorExplanation, AcademicContext, RagSource
│   ├── agents_model.dart    → AgentInsight
│   └── models.dart
└── mappers/
    ├── auth_mapper.dart
    ├── exam_mapper.dart
    ├── question_mapper.dart
    ├── answer_mapper.dart
    ├── results_mapper.dart
    ├── diagnostic_mapper.dart
    ├── tutor_mapper.dart
    ├── agents_mapper.dart
    └── mappers.dart
```

---

### 3. Flujo DTO → Model

```
FastAPI JSON
    ↓
*ResponseDto.fromJson()     (capa serialización)
    ↓
*Mapper.to*()               (capa dominio UI)
    ↓
Model (inmutable, enums tipados)
    ↓
[Fase 1+] Repository / Provider → pantallas
```

---

### 4. Mapeo DTO ↔ Model por dominio

| Dominio | DTO principal | Model | Mapper |
|---------|---------------|-------|--------|
| Auth | `TokenResponseDto`, `UserResponseDto` | `AuthSession`, `AuthUser` | `AuthMapper` |
| Exam | `ExamTemplateResponseDto`, `StudentExamResponseDto`, `ExamTimeStatusResponseDto` | `ExamTemplate`, `StudentExam`, `ExamTimeStatus` | `ExamMapper` |
| Question | `QuestionResponseDto`, `QuestionForExamDto` | `Question`, `QuestionForExam` | `QuestionMapper` |
| Answer | `StudentAnswerResponseDto` | `StudentAnswer` | `AnswerMapper` |
| Results | `StudentExamResultResponseDto`, `StudyPlanResponseDto` | `StudentExamResult`, `StudyPlan` | `ResultsMapper` |
| Diagnostic | `DiagnosticReportResponseDto`, `DiagnosticItemResponseDto` | `DiagnosticReport`, `DiagnosticItem` | `DiagnosticMapper` |
| Tutor | `TutorExplainResponseDto` | `TutorExplanation` | `TutorMapper` |
| Agents | `AgentRunResponseDto` | `AgentInsight` | `AgentsMapper` |

---

### 5. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| M-01 | DTOs separados por dominio (8 archivos) | Alineado al prompt; evita archivos monolíticos |
| M-02 | `QuestionForExam` en `question_dto` / `question_model` | Variante de pregunta; exam DTO solo referencia |
| M-03 | `StudyPlan` en dominio Results | Contrato en `schemas/recommendation.py`; consumido por `ResultsApi` |
| M-04 | Enums Dart con `fromString` | Strings del backend → tipos seguros en modelos |
| M-05 | Mappers estáticos sin dependencias | Sin Providers; listos para Repositories en Fase 1 |
| M-06 | `ExamTemplateResponseDto` incluye `template_questions` | Campo faltante corregido según `schemas/exam.py` |

---

### 6. Distinciones importantes (no mezclar)

| Par backend | Uso Flutter |
|-------------|-------------|
| `QuestionResponse` vs `QuestionForExam` | CRUD de contenido vs vista de examen activo |
| `BreakdownItemResponse` vs `DiagnosticItemResponse` | Resultados (`id`) vs diagnóstico (`entity_id`, `name`, `level`) |
| `RagSourceResponse` (Tutor) vs `rag_sources: dict[]` (Agents) | Tipado en tutor; dinámico en agentes |

---

### 7. Próximo paso recomendado

**Fase 1 — Auth UI:** Repositories que usen `*Api` + `*Mapper`; `AuthNotifier` con `AuthMapper.toSession`.

---

*Última actualización: 2026-06-26 — Fase 0.6 completada (modelos, DTOs y mappers por dominio).*

---

## Fase 0.8 — Providers Riverpod

**Fecha:** 2026-06-26  
**Alcance:** Providers de dominio que coordinan Repositories. Sin pantallas, widgets ni lógica visual.

---

### 1. Estado del proyecto

| Componente | Estado |
|------------|--------|
| `authRepositoryProvider` … `resultsRepositoryProvider` | ✅ |
| `AuthProvider` + `authProvider` | ✅ |
| `ExamProvider` + `examProvider` | ✅ |
| `TutorProvider` + `tutorProvider` | ✅ |
| `ResultsProvider` + `resultsProvider` | ✅ |
| `DiagnosticProvider` + `diagnosticProvider` | ✅ |
| `AgentsProvider` + `agentsProvider` | ✅ |
| Pantallas / widgets | No implementado (Fase 1+) |

---

### 2. Mapeo Provider ↔ Repository

| Provider (clase) | Riverpod | Repository | Métodos expuestos |
|------------------|----------|------------|-------------------|
| `AuthProvider` | `authProvider` | `AuthRepository` + `SessionManager` | `register`, `login`, `getMe`, `hasSession`, `logout` |
| `ExamProvider` | `examProvider` | `ExamRepository` | plantilla, sesión, tiempo, respuestas, finish |
| `TutorProvider` | `tutorProvider` | `TutorRepository` | `explain` |
| `ResultsProvider` | `resultsProvider` | `ResultsRepository` | `getStudentExamResults`, `getStudyPlan` |
| `DiagnosticProvider` | `diagnosticProvider` | `ResultsRepository` | diagnóstico completo + breakdown por nivel |
| `AgentsProvider` | `agentsProvider` | `ResultsRepository` | `analyzeDiagnostic`, `encourageStudent`, `parentReport` |

---

### 3. Flujo de dependencias

```
authProvider / examProvider / …
    ↓
*RepositoryProvider
    ↓
*Api(apiClientProvider)
    ↓
ApiClient(sessionManagerProvider)
```

`AuthProvider` es el único que además coordina `SessionManager` (persistir token tras login/register).

---

### 4. Archivos creados

```
frontend/lib/
├── core/providers/
│   ├── repository_providers.dart
│   └── providers.dart                    (barrel actualizado)
└── features/
    ├── auth/providers/auth_provider.dart
    ├── exam/providers/exam_provider.dart
    ├── tutor/providers/tutor_provider.dart
    ├── results/providers/
    │   ├── results_provider.dart
    │   └── diagnostic_provider.dart
    └── agents/providers/agents_provider.dart
```

---

### 5. Uso desde pantallas [Fase 1+]

```dart
// Ejemplo — sin implementar aún en UI
final auth = ref.read(authProvider);
final session = await auth.login(LoginRequestDto(...));
```

Cada `*Provider` expone métodos `Future<Model>`; el estado de carga/error lo gestionarán Notifiers o `AsyncValue` en la capa de pantallas.

---

### 6. Decisiones tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| P-01 | Clase `*Provider` + `final *Provider` Riverpod | Nombre explícito del prompt; DI vía `Provider<T>` |
| P-02 | `DiagnosticProvider` y `AgentsProvider` usan `ResultsRepository` | Alineado a `ResultsApi`; separación por dominio de negocio |
| P-03 | Sin `AsyncNotifier` en esta fase | Coordinación pura; estado async en Fase 1 UI |
| P-04 | `AuthProvider` persiste sesión | Única coordinación extra (repo + `SessionManager`) |
| P-05 | Repository providers en `core/providers/` | Infra compartida; domain providers en `features/` |

---

### 7. Próximo paso recomendado

**Fase 1 — Auth UI:** Conectar `login_page.dart` a `authProvider`; Splash con `hasSession` + `getMe`; rutas GoRouter.

---

*Última actualización: 2026-06-26 — Fase 0.8 completada (providers Riverpod).*
