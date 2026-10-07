# Plan UI/UX — Pitágoras IA

**Rol:** UX/UI Designer Senior  
**Fecha:** 2026-06-26  
**Proyecto:** `frontend` (Flutter)  
**Rúbrica hackathon:** *Evaluación Inteligente y Feedback en Tiempo Real*

**Fuentes de verdad:**

| Documento | Uso |
|-----------|-----|
| [`FIGMA_ANALYSIS.md`](FIGMA_ANALYSIS.md) | Prioridad de pantallas y mapeo backend |
| [`FLUTTER_IMPLEMENTATION_PLAN.md`](FLUTTER_IMPLEMENTATION_PLAN.md) | Arquitectura, providers y componentes técnicos |
| `frontend/lib/core/theme/` | Tokens de color y tipografía ya implementados |
| `frontend/lib/screens/auth/` | Referencia visual existente (Login) |

**Alcance:** Guía para diseñar en Figma las **8–10 vistas efectivas** del hackathon. No incluye pantallas eliminadas (Onboarding, Home, Historial, Admin RAG, etc.).

---

## 1. Principios de experiencia

### 1.1 Propuesta de valor visual

Pitágoras IA debe sentirse como un **acompañante de estudio inteligente**, no como un LMS corporativo. La interfaz combina:

- **Confianza académica** — tonos azul marino, estructura clara, jerarquía tipográfica fuerte.
- **Calidez pedagógica** — mascota, mensajes en segunda persona, feedback inmediato sin castigo.
- **Inteligencia visible** — badges IA, estados de carga explícitos, contexto académico (área → subtema) siempre visible en flujos de tutoría.

### 1.2 Personalidad de marca

| Atributo | Expresión en UI |
|----------|-----------------|
| Inteligente | Chips de contexto, narrativas IA, fuentes RAG colapsables |
| Cercano | Tuteo («Tu puntaje», «Pregúntale al tutor»), mascota en auth |
| Claro | Una acción primaria por vista; máximo 2 CTAs visibles |
| Motivador | Verde en aciertos, mensajes de ánimo, agente motivador con tono positivo |

### 1.3 Flujo demo (3 minutos — referencia jurado)

```
Splash → Registro/Login → Elegir simulacro → Examen
→ (fallar 1 pregunta) → Feedback + Tutor IA → Finalizar
→ Resultados → Diagnóstico → Análisis IA → [Motivador] → [Vista padres]
```

### 1.4 Arquitectura de navegación

```
[Splash]
   ├─ sin token → [Login] ↔ [Registro]
   └─ con token → [Elegir simulacro]
                        └─ [Examen en curso] ──modal── [Tutor IA]
                                    └─ dialog ── [Finalizar]
                                           └─ [Resultados] (hub con secciones)
                                                  ├─ Puntaje
                                                  ├─ Diagnóstico
                                                  ├─ Plan de estudio
                                                  ├─ Análisis IA
                                                  ├─ Motivador
                                                  └─ Vista padres
```

**Regla:** Resultados es **una sola ruta** con scroll vertical o pestañas; no crear 5 pantallas independientes para post-examen.

---

## 2. Sistema de diseño

### 2.1 Paleta de colores

#### Colores de marca (existentes en código)

| Token | Hex | Uso |
|-------|-----|-----|
| `primary` | `#2F6BEE` | CTAs principales, links, acentos IA, progress activo |
| `primaryLight` | `#5B8DEF` | Hover, gradientes, iconos secundarios |
| `navy` | `#1A2B5A` | Títulos, texto principal, AppBar |
| `navyLight` | `#2E4278` | Subtítulos, labels secundarios |
| `textMuted` | `#6B8FC7` | Placeholders, hints, metadata |
| `backgroundTop` | `#E8F2FF` | Inicio de gradiente (auth, splash) |
| `backgroundBottom` | `#FFFFFF` | Fondo base, cards |
| `card` | `#FFFFFF` | Superficies elevadas |
| `border` | `#E2E8F0` | Bordes de inputs y cards |
| `divider` | `#D8DEE8` | Separadores |
| `bubble` | `#F0F6FF` | Burbujas, fondos suaves de sección IA |
| `cloud` | `#FFFFFF` 20% | Decoración hero (nubes, overlays) |

#### Colores semánticos (definir en Figma — extensión del tema)

| Token | Hex sugerido | Uso |
|-------|--------------|-----|
| `success` | `#16A34A` | Respuesta correcta, fortalezas, chips `strength` |
| `successBg` | `#DCFCE7` | Banner feedback correcto |
| `error` | `#DC2626` | Respuesta incorrecta, errores de formulario |
| `errorBg` | `#FEE2E2` | Banner feedback incorrecto |
| `warning` | `#D97706` | Tiempo bajo (< 5 min), chips `neutral` |
| `warningBg` | `#FEF3C7` | Alertas de tiempo |
| `weakness` | `#EA580C` | Chips diagnóstico `weakness` |
| `aiAccent` | `#7C3AED` | Badge «Generado por IA», iconografía agentes |
| `aiBg` | `#F3E8FF` | Fondo tarjetas de agentes IA |

#### Gradientes

| Nombre | Definición | Pantallas |
|--------|------------|-----------|
| `gradientAuth` | `backgroundTop` → `backgroundBottom` (top→bottom, stop ~55%) | Splash, Login, Registro, Bienvenida |
| `gradientPrimary` | `primary` → `primaryLight` (left→right) | Botón primario opcional, score ring |
| `gradientExam` | `navy` 5% → `backgroundBottom` | AppBar examen (sutil) |

### 2.2 Tipografía

**Familia:** Poppins (ya en proyecto).

| Estilo Figma | Peso | Tamaño | Color | Uso |
|--------------|------|--------|-------|-----|
| Display / Hero | Bold 700 | 28–32 px | `navy` | Puntaje principal en Resultados |
| H1 / Greeting | Bold 700 | 26 px | `navy` | «¡Hola! 👋», títulos de pantalla |
| H2 / Card Title | Bold 700 | 18 px | `navy` | Títulos de tarjetas, preguntas |
| H3 / Section | SemiBold 600 | 16 px | `navy` | Encabezados de sección en Resultados |
| Body | Regular 400 | 14–15 px | `navyLight` | Párrafos, explicaciones tutor |
| Body Small | Regular 400 | 13 px | `textMuted` | Subtítulos, metadata |
| Label | Medium 500 | 12 px | `textMuted` | Labels de campos, chips |
| Button | SemiBold 600 | 14 px | blanco / `navy` | CTAs |
| Caption | Regular 400 | 11 px | `textMuted` | Slogan, disclaimers IA |
| Mono / Timer | SemiBold 600 | 16 px | `navy` | Countdown examen (opcional tabular nums) |

**Interlineado:** 1.4 en body; 1.2 en títulos.

### 2.3 Espaciado y grid

| Token | Valor | Uso |
|-------|-------|-----|
| `space-xs` | 4 px | Entre icono y texto |
| `space-sm` | 8 px | Padding interno chips |
| `space-md` | 16 px | Padding horizontal pantalla (estándar) |
| `space-lg` | 24 px | Entre bloques |
| `space-xl` | 32 px | Separación secciones |
| `radius-sm` | 8 px | Chips, badges |
| `radius-md` | 12 px | Inputs, botones secundarios |
| `radius-lg` | 16 px | Cards, bottom sheets |
| `radius-xl` | 24 px | Login bottom card, modales |

**Grid móvil:** 4 columnas, margen 16 px, gutter 16 px.  
**Ancho máximo contenido (web/tablet):** 480 px centrado en flujos de auth; 720 px en Resultados.

### 2.4 Elevación y superficies

| Nivel | Sombra Figma | Uso |
|-------|--------------|-----|
| 0 | Sin sombra | Fondo, AppBar transparente |
| 1 | `0 2 8 rgba(26,43,90,0.06)` | Cards, OptionTile |
| 2 | `0 4 16 rgba(26,43,90,0.10)` | Bottom sheet Tutor, LoginBottomCard |
| 3 | `0 8 24 rgba(26,43,90,0.14)` | Diálogos, overlay loading |

### 2.5 Iconografía

**Librería recomendada:** [Material Symbols Rounded](https://fonts.google.com/icons) — coherente con Flutter `Icons.*`.

| Contexto | Icono Material | Notas |
|----------|----------------|-------|
| Logo / marca | Custom (Pitágoras) | Asset SVG; triángulo + tipografía |
| Auth — email | `mail_outline` | Campo correo |
| Auth — password | `lock_outline` | Campo contraseña; toggle `visibility` |
| Auth — usuario | `person_outline` | Registro nombre |
| Navegación atrás | `arrow_back` | AppBar |
| Cerrar modal | `close` | Tutor, diálogos |
| Logout | `logout` | Menú AppBar |
| Tiempo / timer | `schedule` | ExamTimer |
| Pregunta | `help_outline` | Indicador de pregunta |
| Correcto | `check_circle` | Feedback ✓ — color `success` |
| Incorrecto | `cancel` | Feedback ✗ — color `error` |
| Tutor IA | `school` o `psychology` | CTA tutor |
| IA / agente | `auto_awesome` | Badge IA, Análisis, Motivador |
| RAG / fuente | `menu_book` | Fuentes bibliográficas |
| Resultados | `analytics` | Sección puntaje |
| Diagnóstico | `insights` | Sección diagnóstico |
| Fortaleza | `trending_up` | Lista strengths |
| Debilidad | `trending_down` | Lista weaknesses |
| Plan estudio | `calendar_today` | Plan de estudio |
| Video / recurso | `play_circle_outline` | Tipo recurso video |
| Motivación | `emoji_events` | Agente motivador |
| Padres | `family_restroom` | Vista padres |
| Error red | `wifi_off` | Estados error |
| Vacío | `inbox` | Sin datos |
| Loading | `progress_activity` (animado) | Spinner IA |

**Tamaños:** 20 px inline; 24 px en AppBar; 48 px en estados vacío/error.

### 2.6 Componentes reutilizables — catálogo Figma

Crear como **Component Set** en Figma con variantes (estado: default / hover / disabled / loading).

| Componente Figma | Variantes | Widget Flutter previsto |
|------------------|-----------|-------------------------|
| `PitagorasLogo` | horizontal, stacked | `PitagorasLogo` |
| `MascotHero` | default, small | `MascotHero` (existente) |
| `PrimaryButton` | default, loading, disabled | `ElevatedButton` → `PrimaryButton` |
| `SecondaryButton` | outlined | `OutlinedButton` → `SecondaryButton` |
| `TextLink` | default | `TextButton` |
| `AuthTextField` | default, focus, error, disabled | `TextFormField` → `AuthTextField` |
| `PasswordField` | + visible toggle | `PasswordField` |
| `AuthScaffold` | con gradiente | `Scaffold` + gradiente |
| `LoginHeader` | — | `LoginHeader` (existente) |
| `LoginBottomCard` | — | `LoginBottomCard` (existente) |
| `LoadingOverlay` | fullscreen | `Stack` + `ModalBarrier` |
| `AppBarWithLogout` | con título | `AppBar` custom |
| `InfoChip` | icon + label | `Chip` / `InfoChip` |
| `SimulacroCard` | loading skeleton | `SimulacroCard` |
| `ExamTimer` | normal, warning, expired | `ExamTimer` |
| `ExamProgressBar` | — | `LinearProgressIndicator` custom |
| `QuestionCard` | — | `QuestionCard` |
| `OptionTile` | default, selected, disabled | `OptionTile` (radio) |
| `AnswerFeedbackBanner` | success, error | `AnswerFeedbackBanner` |
| `TutorCtaButton` | — | `TextButton` con icono tutor |
| `TutorSheet` | loading, content, error | `ModalBottomSheet` / `DraggableScrollableSheet` |
| `AcademicContextHeader` | — | fila de chips área/subtema |
| `RagSourceChip` | — | `ActionChip` expandible |
| `AiLoadingIndicator` | con mensaje | `Column` + `CircularProgressIndicator` + texto |
| `AiInsightCard` | loading, content, error | `AiInsightCard` |
| `AgentBadge` | diagnostic, motivator, parents | `Chip` con color `aiAccent` |
| `ScoreHeader` | circular, linear | `ScoreHeader` |
| `BreakdownBar` | — | barra + % + label |
| `AreaScoreTile` | — | `ListTile` + barra |
| `LevelBadge` | strength, neutral, weakness | `LevelBadge` |
| `DiagnosticItemTile` | — | `DiagnosticItemTile` |
| `StrengthWeaknessList` | strengths / weaknesses | lista con iconos |
| `RecommendationTile` | por tipo recurso | `RecommendationTile` |
| `ResourceTypeSection` | — | encabezado + lista |
| `ConfirmDialog` | — | `AlertDialog` → `ConfirmDialog` |
| `EmptyState` | generic, no-results, no-network | `EmptyState` |
| `ErrorState` | retry | `ErrorState` |
| `SectionHeader` | con opcional acción | título + trailing |
| `TabSection` | 3–5 tabs | `TabBar` + `TabBarView` |
| `ViewModeToggle` | estudiante / padres | `Switch` + label |
| `Snackbar` | success, error, info | `SnackBar` temático |

---

## 3. Pantallas — especificación detallada

---

### 3.1 Splash

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Reforzar marca y decidir ruta inicial según sesión JWT almacenada |
| **Jerarquía visual** | 1. Logo Pitágoras (centro) → 2. Slogan → 3. Indicador de carga sutil |
| **Componentes** | `PitagorasLogo`, slogan, `CircularProgressIndicator` pequeño bajo logo, fondo `gradientAuth` |
| **Navegación** | Automática tras 1–2 s: token válido → Elegir simulacro; sin token → Login |
| **Botones** | Ninguno (transición automática) |
| **Campos** | Ninguno |
| **Mensajes** | Slogan: «Aprende. Practica. Avanza.» |
| **Loading** | Spinner 24 px, color `primary`, debajo del logo; duración mínima 1 s aunque la API responda rápido |
| **Vacío** | N/A |
| **Error** | 401 en `/auth/me` → limpiar sesión, ir a Login sin mostrar error (silencioso). Sin red → Login + snackbar opcional «Sin conexión» |

**Figma:** Frame 360×800, logo centrado verticalmente en tercio superior, animación opcional fade-in del logo.

---

### 3.2 Bienvenida (opcional — fusionable con Splash)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | 🟡 Importante (omitir si hay prisa) |
| **Objetivo** | Comunicar valor del producto antes de auth |
| **Jerarquía visual** | 1. Mascota → 2. Título valor → 3. Subtítulo → 4. CTAs |
| **Componentes** | `MascotHero`, título H1, body, `PrimaryButton`, `SecondaryButton`, `gradientAuth` |
| **Navegación** | «Iniciar sesión» → Login · «Registrarse» → Registro |
| **Botones** | Primario: «Iniciar sesión» · Secundario: «Crear cuenta» |
| **Campos** | Ninguno |
| **Mensajes** | Título: «Tu compañero inteligente para el examen de admisión» · Subtítulo: breve beneficio (simulacros + feedback + tutor IA) |
| **Loading** | N/A |
| **Vacío** | N/A |
| **Error** | N/A |

**Nota Figma:** Si se fusiona con Splash, añadir CTAs debajo del logo tras animación.

---

### 3.3 Login

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Autenticar al estudiante y obtener JWT |
| **Jerarquía visual** | 1. Header marca (`LoginHeader`) → 2. Saludo + mascota → 3. Card inferior con formulario |
| **Componentes** | `AuthScaffold`, `LoginHeader`, `MascotHero`, `LoginBottomCard`, `AuthTextField` ×2, `PasswordField`, `PrimaryButton`, `TextLink` |
| **Navegación** | Éxito → Elegir simulacro (reemplaza stack) · «¿No tienes cuenta?» → Registro |
| **Botones** | Primario: «Iniciar sesión» · Link: «Registrarse» |
| **Campos** | Correo electrónico (email, teclado email) · Contraseña (oculta, min 1 char) |
| **Mensajes** | Saludo: «¡Hola! 👋» · Welcome: «Bienvenido a tu compañero inteligente de estudio.» · Card title: «Inicia sesión para continuar» |
| **Loading** | Botón primario → spinner inline + label «Iniciando…»; campos deshabilitados |
| **Vacío** | N/A |
| **Error** | 401: «Correo o contraseña incorrectos» bajo formulario o en snackbar · 403: «Cuenta inactiva» · Timeout: «No pudimos conectar. Revisa tu red e intenta de nuevo.» · Validación: email inválido, contraseña vacía (inline en campos) |

**Figma:** Reutilizar layout existente en `login_page.dart`. Card inferior con `radius-xl` solo en esquinas superiores. Separador «o continúa con» puede omitirse en hackathon (sin OAuth).

---

### 3.4 Registro

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Crear cuenta estudiante y emitir JWT |
| **Jerarquía visual** | Igual que Login: header → hero reducido → card formulario |
| **Componentes** | Mismos que Login + campo nombre |
| **Navegación** | Éxito → Elegir simulacro · «¿Ya tienes cuenta?» → Login |
| **Botones** | Primario: «Crear cuenta» |
| **Campos** | Nombre completo (min 2) · Correo · Contraseña (min 8) · Confirmar contraseña (solo UI, no va al API) |
| **Mensajes** | Título card: «Crea tu cuenta» · Hint contraseña: «Mínimo 8 caracteres» |
| **Loading** | Igual que Login — «Creando cuenta…» |
| **Vacío** | N/A |
| **Error** | 409: «Este correo ya está registrado» · 400: mensaje del backend · Confirmación no coincide: inline |

---

### 3.5 Elegir simulacro

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Presentar el simulacro UNSA disponible e iniciar sesión de examen |
| **Jerarquía visual** | 1. AppBar con logout → 2. Saludo personalizado → 3. Tarjeta simulacro → 4. CTA fijo inferior |
| **Componentes** | `AppBarWithLogout`, saludo con nombre (`full_name`), `SimulacroCard`, `InfoChip` ×2 (duración, preguntas), `PrimaryButton` |
| **Navegación** | «Comenzar simulacro» → Examen en curso · Logout → Login |
| **Botones** | Primario: «Comenzar simulacro» (ancho completo, fijo abajo o bajo card) |
| **Campos** | Ninguno (datos de plantilla son read-only en card) |
| **Mensajes** | Saludo: «Hola, {nombre}» · Subtítulo: «Estás a un paso de practicar» · Card: nombre plantilla (ej. «Simulacro UNSA Ingeniería 2026») |
| **Loading** | Skeleton de `SimulacroCard` al cargar plantilla · Overlay «Preparando tu simulacro…» al `POST /student-exams` |
| **Vacío** | Si plantilla no carga: `EmptyState` «No hay simulacros disponibles» + botón reintentar |
| **Error** | 404 plantilla: «Simulacro no disponible. Contacta al administrador.» · 400: detalle API |

**Figma:** Una sola card destacada (no listado). Chips con iconos `schedule` y `quiz`.

---

### 3.6 Examen en curso

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Presentar preguntas una a una, registrar respuestas y mostrar tiempo restante |
| **Jerarquía visual** | 1. AppBar + `ExamTimer` → 2. `ExamProgressBar` (pregunta X de N) → 3. `QuestionCard` → 4. Lista `OptionTile` → 5. Barra inferior navegación |
| **Componentes** | `AppBarWithLogout` (sin logout o con confirmación), `ExamTimer`, `ExamProgressBar`, `QuestionCard`, `OptionTile` ×4, `PrimaryButton`, `SecondaryButton`, `AnswerFeedbackBanner` (inline) |
| **Navegación** | Anterior / Siguiente entre preguntas · Última pregunta: botón «Finalizar» abre `ConfirmDialog` · CTA tutor abre modal |
| **Botones** | «Anterior» (secundario, disabled en P1) · «Confirmar respuesta» o auto-submit al seleccionar · «Siguiente» · «Finalizar examen» (última) |
| **Campos** | Selección única por `OptionTile` (radio behavior) |
| **Mensajes** | Label progreso: «Pregunta {n} de {total}» · Timer: `MM:SS` restante · Al expirar: banner warning «Tiempo agotado» |
| **Loading** | Spinner breve en botón confirmar al enviar respuesta |
| **Vacío** | N/A (siempre hay preguntas del backend) |
| **Error** | 409 tiempo expirado: diálogo forzar finalizar · 400 opción inválida: snackbar · Fallo red al submit: conservar selección local + «Reintentar envío» |

**Comportamiento:** Tras submit exitoso, mostrar `AnswerFeedbackBanner` 2–3 s antes de habilitar «Siguiente». Polling timer cada 5–10 s.

---

### 3.7 Feedback respuesta (inline — no es ruta)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Confirmar acierto/error inmediatamente tras enviar respuesta (rúbrica C3) |
| **Jerarquía visual** | Banner entre opciones y botones de navegación |
| **Componentes** | `AnswerFeedbackBanner`, `TutorCtaButton` (solo si incorrecto) |
| **Navegación** | «Preguntar al Tutor» → modal Tutor IA |
| **Botones** | `TutorCtaButton`: «Pregúntale al tutor» (solo error) |
| **Campos** | Ninguno |
| **Mensajes** | Correcto: «¡Correcto! Buen trabajo.» + icono `check_circle` · Incorrecto: «Incorrecto. Puedes pedir ayuda al tutor.» + icono `cancel` |
| **Loading** | Hereda del botón confirmar |
| **Vacío** | N/A |
| **Error** | Hereda del submit |

**Figma:** Variante success (`successBg`) y error (`errorBg`). Animación slide-down 300 ms.

---

### 3.8 Tutor IA (modal / bottom sheet)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Explicar la pregunta fallida con contexto KGAA y contenido RAG |
| **Jerarquía visual** | 1. Handle + título → 2. `AcademicContextHeader` → 3. Área explicación (scroll) → 4. Fuentes RAG colapsables → 5. Input opcional |
| **Componentes** | `TutorSheet`, `AcademicContextHeader`, cuerpo texto/markdown, `RagSourceChip` lista, `TextField` opcional, `AiLoadingIndicator`, botón cerrar |
| **Navegación** | Cerrar (X o swipe down) → vuelve a Examen |
| **Botones** | «Enviar duda» (si hay texto en input) · «Cerrar» |
| **Campos** | «¿Qué parte no entiendes?» (opcional, multiline) |
| **Mensajes** | Título: «Tutor IA» · Loading: «El tutor está analizando tu pregunta…» · Badge: «Explicación personalizada» |
| **Loading** | `AiLoadingIndicator` full area contenido (5–30 s) — mensaje rotativo opcional |
| **Vacío** | Sin fuentes RAG: omitir sección o «Sin material de referencia indexado» |
| **Error** | 502/503: «El tutor no está disponible. Intenta en unos segundos.» + Reintentar · 404: «Pregunta no encontrada» |

**Figma:** Altura sheet ~85% viewport. Fondo `card`, esquinas superiores `radius-lg`. Contexto académico en chips: área, componente, tema, subtema.

---

### 3.9 Finalizar examen (diálogo)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | 🟡 Importante |
| **Objetivo** | Confirmar envío y disparar calificación |
| **Jerarquía visual** | Icono advertencia → Título → Body → Botones |
| **Componentes** | `ConfirmDialog` |
| **Navegación** | Confirmar → Resultados · Cancelar → vuelve a examen |
| **Botones** | Secundario: «Seguir examen» · Primario: «Finalizar y ver resultados» |
| **Campos** | Ninguno |
| **Mensajes** | Título: «¿Finalizar simulacro?» · Body: «Tienes {n} preguntas sin responder. Una vez finalizado no podrás cambiar tus respuestas.» (dinámico) |
| **Loading** | Tras confirmar: `LoadingOverlay` «Calificando tu simulacro…» |
| **Vacío** | N/A |
| **Error** | 409 ya completado: navegar a Resultados · 400: snackbar con detalle |

---

### 3.10 Resultados (hub post-examen)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Mostrar puntaje global y servir como contenedor de diagnóstico, plan e IA |
| **Jerarquía visual** | 1. `ScoreHeader` grande → 2. Resumen numérico (correctas/total) → 3. `AreaScoreTile` lista → 4. Navegación por secciones/pestañas |
| **Componentes** | `ScoreHeader`, `BreakdownBar`, `AreaScoreTile`, `TabSection` o anclas scroll, `SectionHeader` |
| **Navegación** | Scroll a secciones o tabs: Diagnóstico · Plan · IA · Motivador · Padres · No volver a examen (stack limpio) |
| **Botones** | Opcional: «Ver análisis IA» scroll-to · «Compartir» (futuro, oculto en hackathon) |
| **Campos** | Ninguno |
| **Mensajes** | Título: «Tus resultados» · Subtítulo: «Simulacro UNSA — {fecha}» · Score: «{n}%» grande |
| **Loading** | Skeleton en score + 3 barras al cargar `/results` |
| **Vacío** | 404: `EmptyState` «Resultados no disponibles» |
| **Error** | `ErrorState` con reintentar |

**Figma:** Score circular o tipografía Display 48 px con color según rango (&lt;50 error, 50–70 warning, &gt;70 success).

---

### 3.11 Diagnóstico (sección dentro de Resultados)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Mostrar fortalezas, debilidades y niveles por jerarquía KGAA |
| **Jerarquía visual** | 1. Listas Fortalezas/Debilidades → 2. Barras por área → 3. Detalle subtemas (expandible) |
| **Componentes** | `StrengthWeaknessList`, `DiagnosticItemTile`, `LevelBadge`, `BreakdownBar` |
| **Navegación** | Expandir subtemas in-place |
| **Botones** | Opcional: filtro por área (chips horizontales) |
| **Campos** | Ninguno |
| **Mensajes** | Sección: «Diagnóstico académico» · Fortalezas: lista con `trending_up` · Debilidades: `trending_down` |
| **Loading** | Spinner inline en sección o shimmer 3 filas |
| **Vacío** | Sin fortalezas: «Aún no hay fortalezas marcadas» · Igual debilidades |
| **Error** | Banner en sección + reintentar |

**LevelBadge colores:** `strength` → success · `neutral` → warning · `weakness` → weakness.

---

### 3.12 Plan de estudio (sección)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | 🟡 Importante |
| **Objetivo** | Mostrar recomendaciones agrupadas por tipo de recurso y días estimados |
| **Jerarquía visual** | 1. `StudyPlanHeader` (días estimados) → 2. Subtemas foco → 3. Grupos por `ResourceTypeSection` |
| **Componentes** | `StudyPlanHeader`, `ResourceTypeSection`, `RecommendationTile`, `InfoChip` |
| **Navegación** | Scroll vertical |
| **Botones** | Ninguno (sin URLs reales en hackathon) |
| **Campos** | Ninguno |
| **Mensajes** | Header: «Plan sugerido: {n} días» · Foco: «Prioriza: {subtopics}» |
| **Loading** | Shimmer 2 secciones |
| **Vacío** | «No hay recomendaciones específicas. ¡Sigue practicando!» |
| **Error** | Inline en sección |

---

### 3.13 Análisis IA — Agente Diagnóstico (sección)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | ✅ Obligatoria |
| **Objetivo** | Presentar interpretación narrativa del desempeño generada por IA |
| **Jerarquía visual** | 1. `AgentBadge` → 2. `AiInsightCard` con texto largo → 3. Fuentes/metadata colapsables |
| **Componentes** | `AiInsightCard`, `AiLoadingIndicator`, `AgentBadge` (diagnostic) |
| **Navegación** | Auto-fetch al entrar en Resultados o al hacer scroll a sección |
| **Botones** | «Regenerar análisis» (opcional, secundario) |
| **Campos** | Ninguno |
| **Mensajes** | Badge: «Generado por IA» · Loading: «Analizando tu perfil académico…» (10–40 s) |
| **Loading** | Card con skeleton párrafos + spinner |
| **Vacío** | N/A |
| **Error** | «No pudimos generar el análisis.» + fallback: enlace «Ver diagnóstico numérico» · 409: examen incompleto |

**Figma:** Borde izquierdo 4 px `aiAccent`. Fondo `aiBg` suave.

---

### 3.14 Motivador (sección)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | 🟡 Importante |
| **Objetivo** | Ofrecer mensaje motivacional personalizado post-resultados |
| **Jerarquía visual** | 1. Icono trofeo → 2. Input opcional → 3. Card respuesta |
| **Componentes** | `MotivatorCard`, `AiInsightCard`, `TextField`, `PrimaryButton` |
| **Navegación** | — |
| **Botones** | «Recibir ánimo» (dispara API) |
| **Campos** | «¿Cómo te sientes con tus resultados?» (opcional) |
| **Mensajes** | Título: «Un mensaje para ti» · Loading: «Preparando tu mensaje…» |
| **Loading** | En card tras pulsar botón |
| **Vacío** | Estado inicial sin contenido — solo input + CTA |
| **Error** | Igual que Análisis IA |

---

### 3.15 Vista padres / Informe (sección)

| Campo | Especificación |
|-------|----------------|
| **Prioridad** | 🟡 Importante |
| **Objetivo** | Mostrar informe comprensible para apoderados |
| **Jerarquía visual** | 1. `ViewModeToggle` → 2. Card formal con secciones: Resumen · Fortalezas · Mejoras · Cómo apoyar |
| **Componentes** | `ViewModeToggle`, `ParentsReportCard`, `AiInsightCard`, `AgentBadge` (parents) |
| **Navegación** | Toggle activa carga del informe |
| **Botones** | Switch «Vista para padres» |
| **Campos** | Ninguno |
| **Mensajes** | Tono formal en tercera persona («El estudiante…») · Loading: «Generando informe para la familia…» |
| **Loading** | Spinner dentro de card al activar toggle |
| **Vacío** | Toggle off: card colapsada con preview «Activa para ver el informe» |
| **Error** | Mensaje en card + reintentar |

---

## 4. Patrones transversales

### 4.1 Estados de carga — convenciones

| Contexto | Patrón visual | Duración esperada |
|----------|---------------|-------------------|
| Auth submit | Spinner en botón | &lt; 3 s |
| Cargar plantilla | Skeleton card | &lt; 2 s |
| Crear examen | Fullscreen overlay | &lt; 3 s |
| Submit respuesta | Spinner en botón | &lt; 2 s |
| Tutor IA | `AiLoadingIndicator` con copy | 5–30 s |
| Finalizar examen | Fullscreen overlay | 3–10 s |
| Resultados | Shimmer secciones | &lt; 3 s |
| Agentes IA | Skeleton + copy en card | 10–40 s |

**Regla:** Para LLM, **siempre** mostrar mensaje textual; nunca spinner solo.

### 4.2 Estados vacíos — copy estándar

| Contexto | Ilustración | Título | Acción |
|----------|-------------|--------|--------|
| Sin simulacros | `inbox` | «No hay simulacros disponibles» | Reintentar |
| Sin recomendaciones | `calendar_today` | «Sin plan por ahora» | — |
| Sin fortalezas | — | «Practica más para descubrir tus fortalezas» | — |
| Sin resultados | `analytics` | «Resultados no encontrados» | Volver |

### 4.3 Estados error — copy estándar

| Código | Mensaje usuario | Acción |
|--------|-----------------|--------|
| Red | «Sin conexión. Revisa tu internet.» | Reintentar |
| 401 | (silencioso en splash) / «Sesión expirada» en app | Ir a Login |
| 403 | «No tienes permiso para esta acción» | — |
| 404 | Contextual por pantalla | Reintentar o volver |
| 409 | Contextual (tiempo, ya completado) | CTA específico |
| 5xx / LLM | «Servicio no disponible. Intenta más tarde.» | Reintentar |

### 4.4 Feedback háptico y motion (Figma prototyping)

| Acción | Animación |
|--------|-----------|
| Respuesta correcta | Banner slide-down + scale icono 1.0→1.2 |
| Respuesta incorrecta | Banner + shake leve opcional |
| Cambio pregunta | Slide horizontal 300 ms |
| Abrir Tutor | Sheet slide-up 400 ms |
| Score reveal | Count-up numérico 1 s en Resultados |

### 4.5 Accesibilidad

- Contraste mínimo WCAG AA en texto `navy` sobre blanco.
- Áreas táctiles mínimo 48×48 px (`OptionTile`, botones).
- No depender solo del color en feedback (icono + texto).
- Timer con label accesible «Tiempo restante».
- Badge IA con texto, no solo icono.

---

## 5. Mapeo Figma → Flutter (referencia implementación)

Sin código; solo correspondencia para el equipo dev.

| Capa Figma | Capa Flutter |
|------------|--------------|
| Design tokens | `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart` |
| Componentes | `lib/widgets/shared/` |
| Pantallas auth | `lib/screens/auth/` (adaptar existentes) |
| Pantallas examen+resultados | `lib/screens/` por feature |
| Estado | `lib/features/*/providers/` (Riverpod) |
| Datos | Repositories → no tocar en diseño |

### Widgets existentes a reutilizar

| Widget actual | Pantallas |
|---------------|-----------|
| `LoginHeader` | Login, Registro |
| `MascotHero` | Login, Registro, Bienvenida |
| `LoginBottomCard` | Login (base para card de formulario) |
| Gradiente auth en `LoginPage` | Splash, Login, Registro, Bienvenida |

### Widgets nuevos prioritarios (orden diseño → dev)

1. `PrimaryButton` / `SecondaryButton`
2. `AuthTextField` / `PasswordField`
3. `SimulacroCard`
4. `ExamTimer` + `ExamProgressBar`
5. `QuestionCard` + `OptionTile`
6. `AnswerFeedbackBanner`
7. `TutorSheet` + `AcademicContextHeader`
8. `ScoreHeader` + `BreakdownBar`
9. `AiInsightCard` + `AiLoadingIndicator`
10. `LevelBadge` + `DiagnosticItemTile`

---

## 6. Pantallas excluidas del diseño hackathon

No diseñar en Figma (referencia para versión futura):

| Pantalla | Motivo |
|----------|--------|
| Onboarding universidad/carrera | Sin persistencia backend |
| Home / Dashboard | Sin endpoint historial |
| Historial de simulacros | Sin API |
| Login padres / Vincular hijo | Sin flujo auth padre |
| Explorar KGAA | CRUD admin, fuera de demo |
| Admin RAG ingest | Script/Swagger, no Flutter |
| Perfil editable | Solo logout en AppBar |
| Instrucciones pre-examen | Fusionada en Elegir simulacro |

---

## 7. Entregables Figma recomendados

### 7.1 Estructura de archivo

```
📁 Pitágoras IA — Hackathon
├── 🎨 Design System
│   ├── Colors
│   ├── Typography
│   ├── Icons
│   ├── Spacing
│   └── Components (con variantes)
├── 📱 Flow — Estudiante
│   ├── 01 Splash
│   ├── 02 Auth (Login, Registro)
│   ├── 03 Elegir simulacro
│   ├── 04 Examen (+ feedback inline)
│   ├── 05 Tutor IA (modal)
│   ├── 06 Finalizar (dialog)
│   └── 07 Resultados (todas las secciones)
├── 🔄 Prototype
│   └── Demo 3 min (enlace principal)
└── 📋 Specs
    └── Redlines y notas por componente
```

### 7.2 Frames mínimos a diseñar

| # | Frame | Variantes obligatorias |
|---|-------|------------------------|
| 1 | Splash | loading |
| 2 | Login | default, loading, error |
| 3 | Registro | default, loading, error validación |
| 4 | Elegir simulacro | loaded, skeleton, error |
| 5 | Examen | pregunta, post-feedback ✓, post-feedback ✗ |
| 6 | Tutor IA | loading, content, error |
| 7 | Finalizar dialog | — |
| 8 | Resultados | loading, loaded |
| 9 | Sección Diagnóstico | con datos |
| 10 | Sección Análisis IA | loading, content, error |
| 11 | Sección Motivador | empty, loaded |
| 12 | Vista padres | toggle on, loading |

**Total: ~15 frames** (+ componentes en library).

---

## 8. Checklist de validación UX (pre-implementación)

- [ ] Cada pantalla obligatoria tiene una sola acción primaria clara
- [ ] Feedback de respuesta es visible sin scroll
- [ ] Timer siempre visible durante el examen
- [ ] Estados LLM tienen mensaje textual (no spinner aislado)
- [ ] Colores semánticos success/error definidos en Figma
- [ ] Componentes con variantes loading/disabled/error
- [ ] Flujo prototipado completo Registro → Resultados en &lt; 8 taps
- [ ] Vista padres distinguible por tono y toggle
- [ ] Copy en español, tuteo consistente (excepto vista padres)
- [ ] Tokens alineados con `AppColors` y `AppTextStyles` existentes

---

*Documento generado para guiar el diseño en Figma — Pitágoras IA Hackathon 2026.*

*Última actualización: 2026-06-26.*
