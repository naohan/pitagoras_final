class AppStrings {
  AppStrings._();

  static const String appName = 'PITÁGORAS';
  static const String appNameAccent = 'IA';
  static const String slogan = 'Aprende. Practica. Avanza.';

  static const String loginGreeting = '¡Hola! 👋';
  static const String loginWelcome =
      'Bienvenido a tu compañero\ninteligente de estudio.';

  static const String loginTitle = 'Inicia sesión para continuar';
  static const String loginSubtitle =
      'Accede a tu cuenta y sigue aprendiendo';

  static const String emailLabel = 'Correo electrónico';
  static const String emailHint = 'tu@correo.com';
  static const String passwordLabel = 'Contraseña';
  static const String passwordHint = 'Tu contraseña';
  static const String loginButton = 'Iniciar sesión';
  static const String loginSubmitting = 'Iniciando…';
  static const String loginLinkRegister = '¿No tienes cuenta? Regístrate';
  static const String logout = 'Cerrar sesión';

  static const String emailRequired = 'Ingresa tu correo electrónico';
  static const String emailInvalid = 'Ingresa un correo válido';
  static const String passwordRequired = 'Ingresa tu contraseña';
  static const String loginErrorInvalidCredentials =
      'Correo o contraseña incorrectos';
  static const String loginErrorInactive = 'Cuenta inactiva';

  static const String registerGreeting = '¡Únete! 🚀';
  static const String registerWelcome =
      'Crea tu cuenta y comienza\na practicar con IA.';
  static const String registerTitle = 'Crea tu cuenta';
  static const String registerSubtitle =
      'Regístrate para acceder a los simulacros';
  static const String fullNameLabel = 'Nombre completo';
  static const String fullNameHint = 'Tu nombre';
  static const String registerPasswordHint = 'Mínimo 8 caracteres';
  static const String confirmPasswordLabel = 'Confirmar contraseña';
  static const String confirmPasswordHint = 'Repite tu contraseña';
  static const String registerButton = 'Crear cuenta';
  static const String registerSubmitting = 'Creando cuenta…';
  static const String registerLinkLogin = '¿Ya tienes cuenta? Inicia sesión';

  static const String fullNameRequired = 'Ingresa tu nombre completo';
  static const String fullNameTooShort = 'El nombre debe tener al menos 2 caracteres';
  static const String passwordMinLength = 'La contraseña debe tener al menos 8 caracteres';
  static const String confirmPasswordRequired = 'Confirma tu contraseña';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';
  static const String registerErrorEmailTaken = 'Este correo ya está registrado';

  static const String simulacroTitle = 'Elegir simulacro';
  static const String simulacroGreeting = 'Hola';
  static const String simulacroSubtitle = 'Estás a un paso de practicar';
  static const String simulacroAdaptiveSubtitle =
      'Preguntas elegidas según tu diagnóstico, libros y banco Rubiños';
  static const String simulacroOrdinarioSubtitle =
      'Examen tipo UNSA Ordinario 2026-I — 20 preguntas variadas. El Tutor usa RAG (PDF + Rubiños).';
  static const String simulacroInsufficientBank =
      'El banco tiene pocas preguntas. En el backend ejecuta: '
      'python -m scripts.seed_extra_questions y '
      'python -m scripts.seed_rubinos_questions';
  static const String simulacroAdaptiveName = 'Simulacro personalizado IA';
  static const String simulacroDuration = 'Duración';
  static const String simulacroQuestions = 'Preguntas';
  static const String simulacroMinutes = 'min';
  static const String startSimulacro = 'Comenzar simulacro';
  static const String startingSimulacro = 'Preparando…';
  static const String simulacroLoadError = 'No se pudo cargar el simulacro';
  static const String simulacroNoStudent = 'Sesión inválida. Inicia sesión de nuevo.';
  static const String retry = 'Reintentar';

  static const String examTitle = 'Examen';
  static const String examLoadError = 'No se pudo cargar el examen';
  static const String examTemplateNotFound =
      'Esta carrera aún no tiene simulacro en el servidor. Elige otra carrera o ejecuta: python -m scripts.seed_demo';
  static const String examSubmitError = 'No se pudo guardar tu respuesta';
  static const String examNoQuestions = 'No hay preguntas en este examen';
  static const String examPrevious = 'Anterior';
  static const String examNext = 'Siguiente';
  static const String examTimeExpired = 'El tiempo del examen ha finalizado';
  static const String examFinish = 'Finalizar examen';
  static const String examFinishTitle = '¿Finalizar simulacro?';
  static const String examFinishBody =
      'Una vez finalizado no podrás cambiar tus respuestas.';
  static const String examFinishConfirm = 'Finalizar y ver resultados';
  static const String examFinishCancel = 'Seguir examen';
  static const String examFinishing = 'Calificando tu simulacro…';
  static const String examFinishError = 'No se pudo finalizar el examen';
  static const String examAnswerCorrect = '¡Correcto! Buen trabajo.';
  static const String examAnswerWrong =
      'Incorrecto. Revisa en qué paso fallaste (sin ver la clave aún).';
  static const String examAnswerWrongAtEnd =
      'Incorrecto. Al finalizar podrás ver la guía en ejercicios incorrectos.';
  static const String examAnswerWrongDiagnostic =
      'Incorrecto. Pide una pista para seguir sin ver la respuesta.';
  static const String examAnswerSaved = 'Respuesta registrada.';
  static const String examAskTutor = 'Ver guía de error';
  static const String examAskHelpDiagnostic = 'Pedir ayuda';
  static const String examSaveQuestion = 'Guardar';
  static const String examSavedQuestion = 'Guardada';
  static const String examUnsaveQuestion = 'Quitar de guardadas';
  static const String examResolutionTip = 'Tip de resolución';

  static const String tipTitle = 'Tip de resolución';
  static const String tipLoading = 'Buscando una pista para esta pregunta…';
  static const String tipError = 'No se pudo cargar el tip. Intenta de nuevo.';
  static const String tipExtended = 'Explicación extendida';

  static const String examReviewTitle = 'Revisión de respuestas';
  static const String examReviewSubtitle =
      'Repasa cada pregunta de este examen con tu resultado';
  static const String examReviewTabSaved = 'Guardadas';
  static const String examReviewEmpty = 'No hay preguntas en este filtro.';
  static const String examReviewLoadError = 'No se pudo cargar la revisión.';
  static const String resultsReviewAnswers = 'Revisar respuestas';

  static const String savedAnswersTitle = 'Respuestas guardadas';
  static const String savedAnswersSubtitle =
      'Preguntas que marcaste para repasar después';
  static const String savedAnswersEmpty =
      'Aún no guardaste preguntas. Durante el examen usa el botón Guardar.';
  static const String savedAnswersTabAll = 'Todas';
  static const String savedAnswersTabCorrect = 'Correctas';
  static const String savedAnswersTabIncorrect = 'Incorrectas';
  static const String savedAnswersViewResolution = 'Ver resolución';
  static const String reviewErrorGuidance = 'Ver guía del error';
  static const String savedAnswersCorrect = 'Correcta';
  static const String savedAnswersIncorrect = 'Incorrecta';
  static const String savedAnswersYourAnswer = 'Tu respuesta';
  static const String savedAnswersCorrectAnswer = 'Respuesta correcta';

  static const String tutorTitle = 'Tutor IA';
  static const String tutorLoading = 'El tutor está analizando tu pregunta…';
  static const String tutorError = 'El tutor no está disponible. Intenta de nuevo.';
  static const String tutorClose = 'Cerrar';
  static const String tutorOptionalHint = '¿Qué parte no entiendes? (opcional)';

  static const String resultsTitle = 'Tus resultados';
  static const String resultsLoadError = 'No se pudieron cargar los resultados';
  static const String resultsScoreSection = 'Puntaje';
  static const String resultsCorrectLabel = 'Correctas';
  static const String resultsAreasSection = 'Desglose por área';
  static const String resultsDiagnosticSection = 'Diagnóstico académico';
  static const String resultsStrengths = 'Fortalezas';
  static const String resultsWeaknesses = 'Debilidades';
  static const String resultsStudyPlanSection = 'Plan de estudio';
  static const String resultsEstimatedDays = 'Días estimados';
  static const String resultsFocusSubtopics = 'Subtemas a reforzar';
  static const String resultsAiSection = 'Análisis con IA';
  static const String resultsAgentDiagnostic = 'Análisis diagnóstico';
  static const String resultsAgentMotivator = 'Cachimbito';

  static const String motivatorPageTitle = 'Cachimbito';
  static const String motivatorPageGreeting = '¡Hola!';
  static const String motivatorPageSubtitle =
      'Cuéntame cualquier duda, miedo o cómo te sientes con tu preparación.';
  static const String motivatorInputHint = 'Escribe tu duda o cómo te sientes…';
  static const String motivatorNeedDiagnostic =
      'Para personalizar mis respuestas, primero completa el examen de diagnóstico inicial.';
  static const String motivatorWelcome =
      '¡Hola! Soy Cachimbito. Puedes contarme cualquier duda o cómo te sientes estudiando.';
  static const String motivatorCardTitle = 'Cachimbito';
  static const String motivatorCardSubtitle =
      'Dudas, ánimo y consejos según tu progreso en la admisión.';
  static const String motivatorCardCta = 'Chatear con Cachimbito';

  static const String hubSectionSupport = 'Apoyo con IA';
  static const String hubSectionResources = 'Recursos';
  static const String hubSectionTechniques = 'Técnicas de estudio';
  static const String hubSectionPractice = 'Practicar exámenes';
  static const String hubSectionHistory = 'Historial';
  static const String resultsAgentParents = 'Informe para padres';
  static const String resultsAgentGenerate = 'Generar';
  static const String resultsAgentLoading = 'Generando…';
  static const String resultsBackToSimulacro = 'Nuevo simulacro';
  static const String resultsBackToHome = 'Ir al inicio';
  static const String resultsNoData = 'Sin datos disponibles';
  static const String resultsNoStrengthsYet =
      'En este examen ningún subtema superó el 70%. Sigue practicando.';
  static const String resultsNoWeaknessesYet =
      'No se detectaron debilidades marcadas (por debajo del 50%).';
  static const String resultsSubtopicDetail = 'Detalle por tema y subtema';
  static const String resultsTopicDetail = 'Detalle por tema';
  static const String resultsOtherTopics = 'Otros temas';
  static String resultsTopicSubtopicCount(int count) =>
      '$count subtema${count == 1 ? '' : 's'} evaluado${count == 1 ? '' : 's'}';

  static const String navHome = 'Inicio';
  static const String navStudy = 'Estudiar';
  static const String navEvaluations = 'Evaluaciones';
  static const String navRanking = 'Ranking';
  static const String navProfile = 'Perfil';
  static const String comingSoon = 'Pronto';

  static const String homeTitle = 'Mi espacio';
  static const String homeGreeting = 'Hola';
  static const String inicioGreetingSuffix = 'Listo para seguir avanzando 👋';
  static const String inicioCareerLabel = 'Carrera';
  static const String inicioPostulanteLabel = 'Postulante a:';
  static const String inicioAreaLabel = 'Área:';
  static const String inicioAreaDefault = 'Ingenierías';
  static const String inicioAiToolsTitle = 'Herramientas con IA';
  static const String inicioToolTasks = 'Tareas con IA';
  static const String inicioToolSummaries = 'Resúmenes Inteligentes';
  static const String inicioToolMaps = 'Mapas Conceptuales';
  static const String inicioToolFlashcards = 'Flashcards';
  static const String inicioToolMore = 'Más';
  static const String inicioWeeklyProgress = 'Tu progreso semanal';
  static const String inicioStudyStreak = 'Racha de estudio';
  static String inicioStreakDays(int days) => '$days días';
  static String inicioMetaTitleFor(String? universityCodeOrName) {
    final value = universityCodeOrName?.trim();
    if (value == null || value.isEmpty) return 'Meta de ingreso';
    return 'Meta $value';
  }

  static const String inicioMetaTitle = 'Meta de ingreso';
  static const String inicioMetaFocusMath =
      'Enfócate en Matemática para mejorar tu puntaje.';
  static String inicioMetaGap(double gap) =>
      'Te faltan ${gap.toStringAsFixed(1)} puntos. Enfócate en Matemática.';
  static const String inicioSimulacroTitle = 'Simulacros IA';
  static const String inicioSimulacroBadge = 'IA';
  static const String inicioSimulacroBody =
      'Practica con exámenes personalizados';
  static const String inicioSimulacroFeature1 = 'Simulacros personalizados';
  static const String inicioSimulacroFeature1Sub =
      'Preguntas adaptadas a tu nivel';
  static const String inicioSimulacroFeature2 = 'Análisis inteligente';
  static const String inicioSimulacroFeature2Sub =
      'Detecta fortalezas y debilidades';
  static const String inicioSimulacroFeature3 = 'Ranking de postulantes';
  static const String inicioSimulacroFeature3Sub = 'Compara tu rendimiento';
  static const String inicioSimulacroCta = 'Ir a simulacros';
  static const String inicioDiagnosticTitle = 'Examen de diagnóstico';
  static const String inicioDiagnosticBadge = 'Una vez';
  static const String inicioDiagnosticBody =
      'Mide tu nivel inicial en todas las áreas. Solo se realiza una vez al empezar.';
  static const String inicioDiagnosticCta = 'Ir al diagnóstico';
  static const String inicioSimulacroLockedBody =
      'Completa el diagnóstico inicial para desbloquear los simulacros de práctica.';
  static const String inicioSimulacroLockedCta = 'Simulacro (requiere diagnóstico)';
  static const String simulacroRequiresDiagnostic =
      'Primero completa el examen de diagnóstico para medir tu nivel inicial.';
  static const String simulacroGoDiagnostic = 'Ir al diagnóstico';
  static const String inicioRoutineTitle = 'Tu rutina de estudio';
  static const String inicioRoutineCta = 'Crear rutina';
  static const String inicioSupportTitle = 'Accesos rápidos';
  static const String inicioSupportStudy = 'Estudiar';
  static const String inicioSupportEvaluations = 'Evaluaciones';
  static const String inicioSupportMotivator = 'Cachimbito';
  static const String inicioSupportRanking = 'Ranking';
  static const String inicioAiTip =
      'Los temas alineados a tu carrera son los más importantes.';
  static const String inicioTipIaTitle = 'Tip IA';
  static const String inicioRecommendTitle = 'Hoy te recomendamos';
  static const String inicioRecommendWeak = 'Repasa tus temas débiles';
  static const String inicioRecommendWeakSub =
      'Rinde mejor en tu próximo simulacro';
  static const String inicioRecommendRoutine = 'Crea tu rutina';
  static const String inicioRecommendRoutineSub =
      'Organiza tu estudio esta semana';
  static const String inicioSetupCareer =
      'Elige si quieres ingresar a una universidad o aprender un tema';
  static const String inicioLearningCtaTitle = 'Ir a Estudiar';
  static const String inicioLearningCtaSub =
      'Material, Pomodoro y Feynman para dominar tu tema.';

  static const String inicioBannerSetupTitle = 'Configura tu perfil';
  static const String inicioBannerSetupBody =
      'Elige universidad y carrera para personalizar tu preparación.';
  static const String inicioBannerDiagnosticTitle = 'Completa tu diagnóstico';
  static const String inicioBannerDiagnosticBody =
      '5 preguntas para conocer tu nivel y armar tu plan.';
  static const String inicioBannerReadyTitle = '¡Sigue practicando!';
  static const String inicioBannerReadyBody =
      'Tu plan está listo. Continúa con simulacros y repaso.';

  static const String studyTabTitle = 'Estudiar';
  static const String studyTabSubtitle =
      'Material, repaso y técnicas. Los exámenes están en Evaluaciones.';
  static const String studyTabLearningSubtitle =
      'Aprende el tema a tu ritmo: material, Pomodoro y técnica Feynman.';
  static String studyTabLearningFocus(String topic) => 'Tema: $topic';
  static const String studyTabLearningFocusSub =
      'Base escolar (CNEB). Toca para cambiar de tema.';
  static const String studyTabLearningTheoryTitle = 'Ver teoría del tema';
  static const String studyTabLearningTheorySub =
      'Repasa la explicación detallada: conceptos, desarrollo y fuentes.';
  static const String studyTabLearningTheoryLoading =
      'Cargando la teoría del tema…';
  static const String studyTabLearningTheoryError =
      'No se pudo cargar la teoría. Intenta de nuevo.';
  static const String studyTabLearningMaterialSub =
      'Sube un PDF o apuntes del tema que estás estudiando.';
  static const String studyTabLockedTitle = 'Completa el diagnóstico inicial';
  static const String studyTabLockedSubtitle =
      'Es una sola evaluación para medir tu nivel. Luego podrás hacer todos los simulacros que quieras.';
  static const String studyTabHeroReady = 'Sigue practicando';
  static const String studyTabHeroReadyBody =
      'Haz simulacros, repasa errores y refuerza con flashcards y técnicas de estudio.';
  static const String studyTabHeroPending = 'Diagnóstico inicial pendiente';
  static const String studyTabHeroPendingBody =
      'Una sola vez para conocer tu nivel. Después el foco son los simulacros.';
  static const String studyTabSimulacroTitle = 'Nuevo simulacro';
  static const String studyTabSimulacroSubtitle =
      'Practica con un examen completo y mide tu avance.';
  static const String studyTabFlashcardsTitle = 'Flashcards';
  static const String studyTabFlashcardsSubtitle =
      'Repasa errores y subtemas débiles de tu diagnóstico.';
  static const String studyTabMapsTitle = 'Árbol de dominio';
  static const String studyTabMapsSubtitle =
      'Jerarquía académica con puntajes por subtema según tu diagnóstico.';
  static const String flashcardsPageTitle = 'Flashcards';
  static const String flashcardsEmpty =
      'No hay tarjetas disponibles. Completa el diagnóstico y responde preguntas.';
  static const String flashcardsTapHint = 'Toca la tarjeta para ver la respuesta';
  static const String flashcardsSourceWrong = 'Error en examen';
  static const String flashcardsSourceWeak = 'Subtema débil';
  static const String flashcardsPrev = 'Anterior';
  static const String flashcardsNext = 'Siguiente';
  static const String conceptMapPageTitle = 'Árbol de dominio';
  static const String conceptMapEmpty =
      'No hay datos del árbol académico para este examen.';
  static const String conceptMapLegend = 'Verde: fortaleza · Naranja: neutro · Rojo: debilidad';
  static const String studyToolsNoExam =
      'Necesitas completar el diagnóstico para usar esta herramienta.';

  static const String studyTechniquesTitle = 'Técnicas de estudio';
  static const String feynmanTitle = 'Técnica Feynman';
  static const String feynmanSubtitle =
      'Explica el tema con tus palabras, como si le enseñaras a otra persona.';
  static const String feynmanTopicLabel = 'Tema';
  static String feynmanPrompt(String topic) =>
      'Explícame «$topic» con tus propias palabras:';
  static const String feynmanHint =
      'Usa pasos, un ejemplo y por qué funciona el procedimiento…';
  static const String feynmanTooShort = 'Escribe al menos 2–3 oraciones.';
  static const String feynmanAnalyze = 'Analizar mi explicación';
  static String feynmanScore(double percent) => 'Comprensión estimada: $percent%';
  static const String feynmanStrengths = 'Lo que quedó claro';
  static const String feynmanGaps = 'Huecos detectados';
  static const String feynmanSuggestions = 'Cómo mejorar';
  static const String feynmanCardTitle = 'Técnica Feynman';
  static const String feynmanCardSubtitle =
      'Explica un tema y detecta conceptos incompletos (sin LLM).';

  static const String errorLearningTitle = 'Aprende del error';
  static const String errorLearningStep = 'Dónde revisar';
  static const String errorLearningConcept = 'Concepto relacionado';
  static const String errorLearningSimilar = 'Ejercicio similar (más fácil)';
  static const String errorLearningRetry = 'Intentar de nuevo';
  static const String errorLearningNoAnswer =
      'La respuesta correcta se mostrará al terminar el examen o al acertar en un reintento.';

  static const String diagnosticHelpTitle = '¿Cómo quieres continuar?';
  static const String diagnosticHelpSubtitle =
      'No mostramos la clave. Elige una opción para seguir estudiando.';
  static const String diagnosticHelpTip = 'Ver pista breve';
  static const String diagnosticHelpConcept = 'Repaso del concepto';
  static const String diagnosticHelpBases = 'Consultar mis bases (IA)';
  static const String diagnosticHelpBasesHint =
      'Usamos tus materiales indexados mientras ampliamos el banco de ejercicios.';
  static const String diagnosticTipTitle = 'Pista de resolución';
  static const String diagnosticTipNoAnswer =
      'Esta pista no incluye la respuesta correcta.';

  static const String pomodoroTitle = 'Pomodoro';
  static const String pomodoroSubtitle =
      '25 min estudio · 5 min descanso · descanso largo cada 4 ciclos.';
  static const String pomodoroFocus = 'Enfoque';
  static const String pomodoroShortBreak = 'Descanso corto';
  static const String pomodoroLongBreak = 'Descanso largo';
  static String pomodoroCycleProgress(int done) => 'Ciclos en esta ronda: $done/4';
  static const String pomodoroPoints = 'Puntos totales';
  static const String pomodoroReward = 'Por sesión';
  static const String pomodoroStart = 'Iniciar';
  static const String pomodoroPause = 'Pausar';
  static const String pomodoroReset = 'Reiniciar';
  static const String pomodoroCardTitle = 'Pomodoro';
  static const String pomodoroCardSubtitle =
      'Temporizador 25/5 y puntos por cada sesión completada.';

  static const String evaluationsTabTitle = 'Evaluaciones';
  static const String evaluationsTabSubtitle =
      'Diagnóstico, simulacros y revisión de tus exámenes.';
  static const String evaluationsTabSimulacroSubtitle =
      'Examen adaptativo según tus debilidades del diagnóstico.';
  static const String evaluationsTabReviewTitle = 'Revisar respuestas';
  static const String evaluationsTabReviewSubtitle =
      'Filtra correctas, incorrectas y preguntas guardadas.';
  static const String evaluationsTabBannerTitle = 'Practica con propósito';
  static const String evaluationsTabBannerSetup = 'Primero elige tu carrera';
  static const String evaluationsTabBannerBody =
      'Cada evaluación alimenta tu diagnóstico y el feedback en tiempo real.';

  static const String rankingTabTitle = 'Ranking';
  static const String rankingTabSubtitle =
      'Compara tu progreso con otros aspirantes de tu universidad.';
  static const String rankingTabLeaderboard = 'Top estudiantes';
  static const String rankingTabPoints = 'puntos';
  static const String rankingTabPointsLabel = 'PUNTOS';
  static const String rankingTabEncouragement = '✨ Sigue así, vas por buen camino';
  static const String rankingTabDemoNote =
      'Datos de demostración — ranking en vivo próximamente.';
  static String rankingTabYourPosition(int rank) => 'Posición #$rank esta semana';

  static const String profileTabGuest = 'Estudiante';
  static const String profileTabDiagnosticStatus = 'Diagnóstico';
  static const String profileTabDiagnosticDone = 'Completado';
  static const String profileTabDiagnosticPending = 'Pendiente';
  static const String profileTabCareer = 'Carrera';
  static const String profileTabUniversity = 'Universidad';
  static const String profileTabExamTarget = 'Examen objetivo';
  static const String profileTabExamTargetUnset = 'Sin definir';
  static const String profileTabEditCareer = 'Cambiar universidad o carrera';
  static const String profileTabEditExamTarget = 'Cambiar examen objetivo';
  static const String homeSubtitle = 'Continúa tu preparación desde aquí';
  static const String homeCompleteOnboardingTitle = 'Completa tu perfil';
  static const String homeCompleteOnboardingSubtitle =
      'Elige universidad y carrera para personalizar tu plan';
  static const String homeViewPlanTitle = 'Mi plan personalizado';
  static const String homeViewPlanSubtitle =
      'Recomendaciones, fortalezas y análisis con IA';
  static const String homeViewResultsTitle = 'Últimos resultados';
  static const String homeViewResultsSubtitle =
      'Puntaje, diagnóstico y agentes de tu último examen';
  static const String homePracticeSimulacroTitle = 'Simulacro de práctica';
  static const String homePracticeSimulacroSubtitle =
      'Examen extra sin repetir el flujo de diagnóstico';
  static const String homeRepeatDiagnosticTitle = 'Ver diagnóstico inicial';
  static const String homeRepeatDiagnosticSubtitle =
      'Consulta tu resultado y plan de estudio del diagnóstico';
  static const String homeContinueDiagnosticTitle = 'Continuar diagnóstico';
  static const String homeContinueDiagnosticSubtitle =
      'Completa el examen inicial para desbloquear tu plan';
  static const String homeFlowHint =
      'Ruta: registro → universidad → carrera → diagnóstico → inicio';
  static const String homeStudyMaterialTitle = 'Material de estudio (PDF)';
  static const String homeStudyMaterialSubtitle =
      'Sube apuntes para el Tutor IA y genera diagramas visuales';
  static const String homeSavedAnswersTitle = 'Respuestas guardadas';
  static const String homeSavedAnswersSubtitle =
      'Repasa las preguntas que marcaste durante el examen';

  static const String studyMaterialTitle = 'Material de estudio';
  static const String studyMaterialBannerTitle = 'Personaliza el Tutor IA';
  static const String studyMaterialBannerBody =
      'Tus PDF se guardan en una base de conocimiento (RAG). El Tutor IA los consulta '
      'al explicarte — no entrena el modelo desde cero, pero usa tus apuntes en cada respuesta.';
  static const String studyMaterialOfflineHint =
      'Modo offline: la subida es simulada. Conecta el backend para indexar material real.';
  static String studyMaterialIndexedChunks(int count) =>
      'Fragmentos indexados en el servidor: $count';
  static const String studyMaterialHowItWorks = '¿Cómo funciona?';
  static const String studyMaterialHowItWorksBody =
      '1. Toca «Elegir PDF o texto» y selecciona tu archivo.\n'
      '2. Pon un título (opcional).\n'
      '3. Toca «Subir e indexar» y espera (la primera vez puede tardar 1–2 min).\n'
      '4. El PDF debe tener texto seleccionable (no solo imágenes escaneadas).\n'
      '5. Tras indexar, genera un diagrama visual de tus apuntes.';
  static const String studyMaterialTitleLabel = 'Título del material';
  static const String studyMaterialTitleHint = 'Ej. Álgebra - ecuaciones';
  static const String studyMaterialSubtopicLabel = 'ID de subtema (opcional)';
  static const String studyMaterialSubtopicHelper =
      'Opcional. Asocia el material a un subtema de tu carrera.';
  static const String studyMaterialPickFile = 'Elegir PDF o texto';
  static const String studyMaterialUpload = 'Subir e indexar';
  static const String studyMaterialNoFile = 'Selecciona un archivo primero.';
  static const String studyMaterialPickError = 'No se pudo leer el archivo.';
  static const String studyMaterialInvalidSubtopic =
      'El ID de subtema debe ser un número.';
  static const String studyMaterialUploadError =
      'No se pudo indexar el PDF. Revisa que el backend esté activo y que el PDF tenga texto.';
  static const String studyMaterialPdfNoText =
      'El PDF no tiene texto seleccionable (puede ser un escaneo). '
      'Prueba con un PDF con texto copiable o sube un archivo .txt.';
  static const String studyMaterialSuggestedSubtopic = 'Subtema sugerido para tu carrera';
  static const String curriculumOriginCneb = 'Base escolar (CNEB)';
  static const String curriculumOriginAdmission =
      'Temario / balotario de admisión';
  static const String studyMaterialPasteTitle = 'O pega texto directamente';
  static const String studyMaterialPasteHint =
      'Copia un capítulo del libro y pégalo aquí si el PDF falla.';
  static const String studyMaterialPasteButton = 'Indexar texto pegado';
  static String studyMaterialFileSizeHint(double mb) =>
      'Archivo seleccionado: ${mb.toStringAsFixed(1)} MB (máx. recomendado 25 MB).';
  static const String studyMaterialUploadingHint =
      'Indexando… puede tardar 1–3 min. No cierres esta pantalla.';
  static const String studyMaterialUploadTimeout =
      'La indexación tardó demasiado. La primera vez descarga el modelo de IA; intenta de nuevo.';
  static const String studyMaterialUploadSuccess = 'Material indexado';
  static String studyMaterialUploadSuccessDetail(int chunks, String source) =>
      'Se indexaron $chunks fragmentos de «$source».';
  static const String studyMaterialUploadSuccessHint =
      'Durante el examen, pide ayuda al Tutor IA. Si usó tu PDF verás la sección «Fuentes».';
  static const String studyMaterialGenerateDiagram = 'Generar diagrama de apuntes';
  static const String studyMaterialViewDiagrams = 'Ver diagramas de mi material';
  static const String materialDiagramTitle = 'Diagrama de apuntes';
  static const String materialDiagramSubtitle =
      'Estructura visual generada desde el contenido indexado de tu PDF o texto.';
  static const String materialDiagramLoading = 'Construyendo diagrama desde tu material…';
  static const String materialDiagramEmpty =
      'No hay suficiente contenido indexado. Sube un PDF o pega texto primero.';
  static const String materialDiagramChunksUsed = 'Fragmentos analizados';
  static const String materialDiagramExport = 'Exportar';
  static const String materialDiagramExportCopy = 'Copiar texto';
  static const String materialDiagramExportSave = 'Guardar archivo .txt';
  static const String materialDiagramExportSuccess = 'Diagrama copiado al portapapeles';
  static const String materialDiagramExportSaved = 'Diagrama guardado';
  static const String materialDiagramExportError = 'No se pudo exportar el diagrama';
  static const String materialDiagramExportEmpty = 'No hay diagrama para exportar';

  static const String onboardingPurposeTitle =
      '¿Qué quieres hacer en Pitágoras?';
  static const String onboardingPurposeSubtitle =
      'Puedes prepararte para ingresar a una universidad o aprender un tema a tu ritmo.';
  static const String onboardingPurposeAdmissionTitle =
      'Prepararme para ingresar';
  static const String onboardingPurposeAdmissionBody =
      'Elige universidad, carrera y modalidad. Usa el temario / balotario de admisión.';
  static const String onboardingPurposeLearningTitle = 'Aprender un tema';
  static const String onboardingPurposeLearningBody =
      'Estudia desde la base escolar (CNEB): matemática, comunicación, ciencia y más.';
  static const String onboardingTopicTitle = 'Elige un tema para estudiar';
  static const String onboardingTopicTheoryTitle = 'Teoría del tema';
  static const String onboardingTopicSelectTheory = 'Elegir este tema';
  static const String onboardingTopicTheoryClose = 'Cerrar';
  static const String onboardingTopicTheoryEmpty =
      'Aún no hay teoría detallada para este tema. Ejecuta el enriquecimiento en el backend.';
  static const String onboardingTopicTapTheory =
      'Toca para ver la teoría detallada';
  static const String onboardingTopicSubtitle =
      'Áreas y cursos completos. Al tocar un tema verás la teoría detallada.';
  static const String onboardingTopicContinue = 'Empezar a estudiar';
  static const String onboardingTopicEmpty =
      'Aún no hay temas CNEB cargados. Ejecuta el seed del backend.';
  static const String onboardingTopicLoadError =
      'No se pudieron cargar los temas. Intenta de nuevo.';
  static String onboardingTopicCourseLabel(String courseName) =>
      'Curso: $courseName';
  static String onboardingTopicAreaHeader(String areaName) => areaName;
  static String onboardingTopicAreaMeta(int courses, int topics) =>
      '$courses cursos · $topics temas';
  static String onboardingTopicAreaCoursesOnly(int courses) =>
      courses == 1 ? '1 curso' : '$courses cursos';
  static String onboardingTopicCourseTitle(String courseName) => courseName;
  static String onboardingTopicCourseMeta(int topics) =>
      topics == 1 ? '1 tema' : '$topics temas';
  static const String onboardingUniversityTitle =
      'Escoge la universidad o instituto para la que te prepararás.';

  static String onboardingExamTargetTitle(String universityName) =>
      '¿A qué examen de la $universityName te preparas?';
  static const String onboardingExamTargetSubtitle =
      'Personalizamos la vista y los simulacros según tu meta de postulación.';
  static const String onboardingExamTargetNote =
      'Puedes cambiar esta meta después desde tu perfil. No altera tu cuenta en el servidor.';
  static const String onboardingExamTargetContinue = 'Continuar a carrera';
  static const String onboardingExamTargetEmpty =
      'Esta universidad aún no tiene modalidades cargadas. Continúa eligiendo carrera.';

  static const String preparationGoalTitle = 'Te preparas para';
  static String preparationSimulacroTitle(String examLabel) =>
      'Simulacro — $examLabel';
  static String preparationSimulacroSubtitle(String examLabel) =>
      'Practica con preguntas alineadas a tu meta: $examLabel.';

  static String onboardingAreaTitle(String universityName) =>
      '¿A qué área aplicarás en la $universityName?';

  static const String onboardingAreaSubtitle =
      'Personalizaremos tu experiencia y contenidos según tu objetivo.';
  static String onboardingAreaFromBackend(String areaName) =>
      'Área académica del simulacro: $areaName';
  static const String onboardingNoUniversities =
      'No hay universidades disponibles. Ejecuta el seed del backend e intenta de nuevo.';

  static const String onboardingNotSureYet = 'No estoy seguro aún';

  static String onboardingCareerTitle(String universityName) =>
      '¿Qué carrera postulas en la $universityName?';

  static const String onboardingCareerSubtitle =
      'El diagnóstico y el simulacro se personalizarán según tu carrera.';
  static const String onboardingCareerEmpty =
      'No se pudieron cargar carreras del servidor. Verifica que el backend esté en http://127.0.0.1:8000 y reintenta.';
  static const String retryAction = 'Reintentar';

  static const String onboardingCareerMascotDefault =
      'Perfecto. Ajustaré todo para tu perfil. ¡Vamos a ello!';

  static String onboardingCareerMascot(String careerName) =>
      'Perfecto. Ajustaré todo para el perfil de $careerName. ¡Vamos a ello!';

  static const String diagnosticTitle = 'Diagnóstico académico';
  static const String diagnosticDescription =
      'Evaluación inicial de tu base en matemáticas y áreas clave. '
      'No es el perfil vocacional: mide lo que sabes hoy para armar tu plan.';
  static const String diagnosticQuestionsSubtitle =
      'Preguntas de opción múltiple';
  static const String diagnosticTimeSubtitle = 'Tiempo máximo';
  static const String diagnosticAreasSubtitle = 'Ver detalle de áreas';
  static const String diagnosticAreasLink = 'Ver detalle';
  static const String diagnosticStartButton = 'Comenzar examen';
  static const String diagnosticTimerNote =
      'El temporizador iniciará al comenzar';

  static String diagnosticQuestionProgress(int current) =>
      'Pregunta $current de 60';

  static const String diagnosticPrevious = 'Anterior';
  static const String diagnosticMark = 'Marcar';
  static const String diagnosticNext = 'Siguiente';

  static const String diagnosticProcessingTitle =
      'Analizando tus respuestas...';
  static const String diagnosticProcessingSubtitle =
      'Estamos evaluando tu desempeño en cada área.';
  static const String diagnosticProcessingNote =
      'Esto tomará solo unos segundos 🙂';

  static const String diagnosticResultTitle = 'Resultado del Diagnóstico';
  static const String diagnosticYourScore = 'Tu puntaje obtenido';
  static const String diagnosticInZone = 'En zona de ingreso';
  static const String diagnosticPerformanceByArea = 'Desempeño por áreas';
  static const String diagnosticViewRecommendations = 'Ver recomendaciones IA';

  static const String diagnosticAiHighlight =
      'Tu mayor oportunidad de mejora está en Ciencia y Tecnología. ';
  static const String diagnosticAiBody =
      'Recomendamos dedicarle 3 sesiones por semana.';
  static const String diagnosticStrengths = 'Fortalezas';
  static const String diagnosticWeaknesses = 'Debilidades';
  static const String diagnosticCreatePlan = 'Ir al inicio';
}
