/// Rutas relativas a [AppConfig.apiRoot] (`/api/v1`).
abstract final class ApiPaths {
  // Auth
  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const authMe = '/auth/me';

  // Exam engine
  static const examTemplates = '/exam-templates';
  static String examTemplate(int templateId) => '/exam-templates/$templateId';
  static const studentExams = '/student-exams';
  static const studentExamsAdaptive = '/student-exams/adaptive';
  static String studentExam(int studentExamId) => '/student-exams/$studentExamId';
  static String studentExamTime(int studentExamId) =>
      '/student-exams/$studentExamId/time';
  static String studentExamAnswers(int studentExamId) =>
      '/student-exams/$studentExamId/answers';
  static String studentExamAnswerSave(int studentExamId, int questionId) =>
      '/student-exams/$studentExamId/answers/$questionId/save';
  static String studentExamReview(int studentExamId) =>
      '/student-exams/$studentExamId/review';
  static String studentSavedAnswers(int studentId) =>
      '/students/$studentId/saved-answers';
  static String studentExamFinish(int studentExamId) =>
      '/student-exams/$studentExamId/finish';
  static String studentExamResults(int studentExamId) =>
      '/student-exams/$studentExamId/results';

  // Tutor
  static const tutorExplain = '/tutor/explain';
  static const tutorHint = '/tutor/hint';

  // Diagnostics
  static String diagnostic(int studentExamId) =>
      '/diagnostics/student-exams/$studentExamId';
  static String diagnosticAreas(int studentExamId) =>
      '/diagnostics/student-exams/$studentExamId/areas';
  static String diagnosticComponents(int studentExamId) =>
      '/diagnostics/student-exams/$studentExamId/components';
  static String diagnosticTopics(int studentExamId) =>
      '/diagnostics/student-exams/$studentExamId/topics';
  static String diagnosticSubtopics(int studentExamId) =>
      '/diagnostics/student-exams/$studentExamId/subtopics';

  // Recommendations
  static String studyPlan(int studentExamId) =>
      '/recommendations/student-exams/$studentExamId';

  // Agents
  static const agentDiagnosticAnalyze = '/agents/diagnostic/analyze';
  static const agentMotivatorEncourage = '/agents/motivator/encourage';
  static const agentParentsReport = '/agents/parents/report';

  // Demo hackathon
  static const hackathonProfile = '/demo/hackathon-profile';

  // Catálogo académico
  static const universities = '/universities';
  static const careers = '/careers';
  static const areas = '/areas';

  // Study tools (sin LLM)
  static String flashcards(int studentExamId, {int limit = 20}) =>
      '/study-tools/student-exams/$studentExamId/flashcards?limit=$limit';
  static String conceptMap(int studentExamId) =>
      '/study-tools/student-exams/$studentExamId/concept-map';

  // Técnicas de estudio (demo)
  static const feynmanAnalyze = '/study-techniques/feynman/analyze';
  static String errorGuidance(int questionId) =>
      '/study-techniques/questions/$questionId/error-guidance';

  // Racha de estudio
  static const studyActivity = '/study-activity';
  static const studyActivityStreak = '/study-activity/streak';

  // Currículo CNEB / temario
  static String curriculumSubtopic(int subtopicId) =>
      '/curriculum/subtopics/$subtopicId';
  static String learnableTopic(int subtopicId) =>
      '/curriculum/learnable-topics/$subtopicId';

  // Preparación / onboarding (diseño FE)
  static String universityExamTargets(int universityId) =>
      '/universities/$universityId/exam-targets';
  static const admissionProcesses = '/admission-processes';
  static const preparationProfile = '/students/me/preparation-profile';
  static const learnableTopics = '/curriculum/learnable-topics';
  static const curriculumCatalog = '/curriculum/catalog';

  // RAG
  static const ragIngestFile = '/rag/ingest/file';
  static const ragIngestText = '/rag/ingest/text';
  static const ragStats = '/rag/stats';
  static const ragDiagram = '/rag/diagram';
  static String ragContext(int careerId) => '/rag/context?career_id=$careerId';
}
