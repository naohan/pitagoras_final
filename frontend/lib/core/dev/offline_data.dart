import '../../data/enums.dart';
import '../../data/models/agents_model.dart';
import '../../data/models/answer_model.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/catalog_model.dart';
import '../../data/models/diagnostic_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/preparation_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/results_model.dart';
import '../../data/models/tutor_model.dart';

/// Datos mock para desarrollo sin backend.
///
/// Activar con: `flutter run --dart-define=OFFLINE_MODE=true`
class OfflineData {
  OfflineData._();

  static const String accessToken = 'offline-demo-token';
  static const int studentId = 1;
  static const int studentExamId = 9001;
  static const int durationMinutes = 90;

  static DateTime? _examStartedAt;
  static int _answerIdCounter = 1;
  static final Map<int, int> _selectedAnswers = {};
  static final Map<int, StudentAnswer> _submittedAnswers = {};
  static StudentExamResult? _cachedFinishResult;
  static bool _examFinished = false;

  /// Opción correcta por pregunta (ids de [QuestionOptionForExam]).
  static const Map<int, int> _correctOptionIds = {
    1: 12, // B → 7
    2: 22, // B → 30 cm²
    3: 31, // A → x+6
    4: 41, // A → 2⁵
    5: 53, // C → 348
  };

  static AuthSession authSession({
    required String email,
    String? fullName,
  }) {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: 'offline-demo-refresh',
      tokenType: 'bearer',
      expiresIn: 86400,
      user: AuthUser(
        id: 1,
        email: email,
        role: UserRole.student,
        studentId: studentId,
        fullName: fullName ?? email.split('@').first,
      ),
    );
  }

  static AuthUser authUserFromSession({
    required String email,
    String? fullName,
    int? studentId,
  }) {
    return AuthUser(
      id: 1,
      email: email,
      role: UserRole.student,
      studentId: studentId ?? OfflineData.studentId,
      fullName: fullName,
    );
  }

  static ExamTemplate examTemplate(int templateId) {
    final now = DateTime.now();
    return ExamTemplate(
      id: templateId,
      admissionProcessId: 1,
      name: 'Simulacro UNSA (demo offline)',
      durationMinutes: durationMinutes,
      questionCount: 5,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      templateQuestions: List.generate(
        5,
        (i) => ExamTemplateQuestion(
          id: i + 1,
          questionId: i + 1,
          displayOrder: i + 1,
        ),
      ),
    );
  }

  static void resetExamClock() {
    _examStartedAt = DateTime.now();
    _answerIdCounter = 1;
    _selectedAnswers.clear();
    _submittedAnswers.clear();
    _cachedFinishResult = null;
    _examFinished = false;
  }

  static const List<University> universities = [
    University(
      id: 1,
      code: 'UNSA',
      name: 'Universidad Nacional de San Agustín',
      country: 'PE',
      isActive: true,
    ),
    University(
      id: 2,
      code: 'UCSM',
      name: 'Universidad Católica de Santa María',
      country: 'PE',
      isActive: true,
    ),
  ];

  static const List<AcademicArea> areas = [
    AcademicArea(
      id: 1,
      admissionProcessId: 1,
      name: 'Matemáticas',
      displayOrder: 1,
      isActive: true,
    ),
  ];

  static List<Career> careersForUniversity(int universityId) {
    return [
      Career(
        id: 1,
        universityId: universityId,
        code: 'SIS',
        name: 'Ingeniería de Sistemas',
        isActive: true,
      ),
      Career(
        id: 2,
        universityId: universityId,
        code: 'CIV',
        name: 'Ingeniería Civil',
        isActive: true,
      ),
    ];
  }

  static StudentExam studentExam({int? id}) {
    final now = DateTime.now();
    _examStartedAt ??= now;
    final examId = id ?? studentExamId;
    final answers = _submittedAnswers.values.toList()
      ..sort((a, b) => a.questionId.compareTo(b.questionId));

    return StudentExam(
      id: examId,
      studentId: studentId,
      examTemplateId: 1,
      status: _examFinished
          ? StudentExamStatus.completed
          : StudentExamStatus.inProgress,
      startedAt: _examStartedAt,
      finishedAt: _examFinished ? now : null,
      createdAt: now,
      updatedAt: now,
      questions: _demoQuestions,
      answers: answers,
    );
  }

  static ExamTimeStatus examTimeStatus(int studentExamId) {
    final started = _examStartedAt ?? DateTime.now();
    _examStartedAt ??= started;
    final totalSeconds = durationMinutes * 60;
    final elapsed = DateTime.now().difference(started).inSeconds;
    final remaining = (totalSeconds - elapsed).clamp(0, totalSeconds);
    final expired = _examFinished || remaining == 0;

    return ExamTimeStatus(
      studentExamId: studentExamId,
      status: _examFinished
          ? StudentExamStatus.completed
          : remaining == 0
              ? StudentExamStatus.expired
              : StudentExamStatus.inProgress,
      startedAt: started,
      finishedAt: _examFinished ? DateTime.now() : null,
      durationMinutes: durationMinutes,
      elapsedSeconds: elapsed,
      remainingSeconds: remaining,
      isExpired: expired,
    );
  }

  static StudentAnswer submitAnswer({
    required int studentExamId,
    required int questionId,
    required int selectedOptionId,
  }) {
    final now = DateTime.now();
    _selectedAnswers[questionId] = selectedOptionId;
    final isCorrect = _correctOptionIds[questionId] == selectedOptionId;
    final answer = StudentAnswer(
      id: _answerIdCounter++,
      studentExamId: studentExamId,
      questionId: questionId,
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
      timeSeconds: 30,
      answeredAt: now,
      createdAt: now,
    );
    _submittedAnswers[questionId] = answer;
    return answer;
  }

  static int _countCorrect() {
    var correct = 0;
    for (final entry in _selectedAnswers.entries) {
      if (_correctOptionIds[entry.key] == entry.value) correct++;
    }
    return correct;
  }

  static StudentExamResult? cachedFinishResult(int studentExamId) {
    if (_cachedFinishResult?.studentExamId == studentExamId) {
      return _cachedFinishResult;
    }
    return null;
  }

  static StudentExamResult finishStudentExam(int studentExamId) {
    if (_cachedFinishResult?.studentExamId == studentExamId) {
      return _cachedFinishResult!;
    }

    final total = _demoQuestions.length;
    final correct = _countCorrect();
    final score = total == 0 ? 0.0 : (correct / total) * 100;
    final now = DateTime.now();

    _examFinished = true;

    _cachedFinishResult = StudentExamResult(
      studentExamId: studentExamId,
      status: StudentExamStatus.completed,
      result: ExamResult(
        id: 1,
        studentExamId: studentExamId,
        totalQuestions: total,
        correctAnswers: correct,
        scorePercent: score,
        durationSeconds: 600,
        calculatedAt: now,
        createdAt: now,
      ),
      areas: [
        BreakdownItem(
          id: 1,
          totalQuestions: total,
          correctAnswers: correct,
          scorePercent: score,
          areaId: 1,
        ),
      ],
      components: const [],
      topics: const [],
      subtopics: const [],
    );

    return _cachedFinishResult!;
  }

  static DiagnosticReport diagnosticReport(int studentExamId) {
    final total = _demoQuestions.length;
    final correct = _countCorrect();
    final score = total == 0 ? 0.0 : (correct / total) * 100;

    return DiagnosticReport(
      studentExamId: studentExamId,
      globalScorePercent: score,
      totalQuestions: total,
      correctAnswers: correct,
      areas: [
        DiagnosticItem(
          entityId: 1,
          name: 'Matemáticas',
          totalQuestions: total,
          correctAnswers: correct,
          scorePercent: score,
          level: score >= 70
              ? PerformanceLevel.strength
              : score >= 50
                  ? PerformanceLevel.neutral
                  : PerformanceLevel.weakness,
        ),
        DiagnosticItem(
          entityId: 2,
          name: 'Razonamiento',
          totalQuestions: 2,
          correctAnswers: correct >= 3 ? 2 : 1,
          scorePercent: correct >= 3 ? 100 : 50,
          level: PerformanceLevel.neutral,
        ),
      ],
      components: const [],
      topics: const [],
      subtopics: const [],
      strengths: correct >= 3
          ? const ['Álgebra básica', 'Operaciones numéricas']
          : const ['Comprensión de enunciados'],
      weaknesses: correct < total
          ? const ['Divisibilidad y patrones numéricos']
          : const [],
    );
  }

  static StudyPlan studyPlan(int studentExamId) {
    final total = _demoQuestions.length;
    final correct = _countCorrect();
    final score = total == 0 ? 0.0 : (correct / total) * 100;

    return StudyPlan(
      studentExamId: studentExamId,
      globalScorePercent: score,
      estimatedDays: score >= 70 ? 14 : 30,
      focusSubtopics: const ['Divisibilidad', 'Expresiones algebraicas'],
      recommendations: const [
        StudyRecommendation(
          entityType: 'subtopic',
          entityId: 1,
          entityName: 'Divisibilidad',
          scorePercent: 60,
          resourceType: 'video',
          ruleId: 'offline-1',
          message: 'Repasa reglas de divisibilidad con 2, 3 y 5.',
        ),
      ],
      byResourceType: const {},
    );
  }

  static AgentInsight agentInsight({
    required String agentName,
    required int studentExamId,
    required String content,
  }) {
    return AgentInsight(
      agentName: agentName,
      studentExamId: studentExamId,
      content: content,
      ragSources: const [],
      llmModel: 'offline-demo',
      llmProvider: 'mock',
      metadata: const {},
    );
  }

  static final List<QuestionForExam> _demoQuestions = [
    _question(
      id: 1,
      order: 1,
      stem: 'Si x + 5 = 12, ¿cuál es el valor de x?',
      options: [
        ('A', '5'),
        ('B', '7'),
        ('C', '17'),
        ('D', '60'),
      ],
    ),
    _question(
      id: 2,
      order: 2,
      stem: '¿Cuál es el área de un triángulo con base 10 cm y altura 6 cm?',
      options: [
        ('A', '16 cm²'),
        ('B', '30 cm²'),
        ('C', '60 cm²'),
        ('D', '120 cm²'),
      ],
    ),
    _question(
      id: 3,
      order: 3,
      stem: 'Simplifica la expresión: 3(x + 2) - 2x',
      options: [
        ('A', 'x + 6'),
        ('B', 'x + 2'),
        ('C', '5x + 6'),
        ('D', '3x + 4'),
      ],
    ),
    _question(
      id: 4,
      order: 4,
      stem: '¿Cuál es el valor de 2³ × 2²?',
      options: [
        ('A', '2⁵'),
        ('B', '2⁶'),
        ('C', '4⁵'),
        ('D', '8²'),
      ],
    ),
    _question(
      id: 5,
      order: 5,
      stem: 'Un número es divisible entre 3 si la suma de sus dígitos es divisible entre 3. ¿Cuál cumple esa condición?',
      options: [
        ('A', '124'),
        ('B', '235'),
        ('C', '348'),
        ('D', '457'),
      ],
    ),
  ];

  static QuestionForExam _question({
    required int id,
    required int order,
    required String stem,
    required List<(String, String)> options,
  }) {
    return QuestionForExam(
      id: id,
      subtopicId: 1,
      stem: stem,
      difficulty: 2,
      displayOrder: order,
      options: List.generate(
        options.length,
        (i) {
          final (label, text) = options[i];
          return QuestionOptionForExam(
            id: id * 10 + i + 1,
            label: label,
            text: text,
            displayOrder: i + 1,
          );
        },
      ),
    );
  }

  static TutorExplanation tutorExplanation(int questionId) {
    return TutorExplanation(
      questionId: questionId,
      explanation:
          'En modo offline, el tutor muestra una explicación de ejemplo. '
          'Conecta el backend y configura Gemini/OpenAI para respuestas reales con RAG.',
      academicContext: AcademicContext(
        questionId: questionId,
        subtopicId: 1,
        subtopicName: 'Operaciones básicas',
        topicName: 'Fundamentos',
        componentName: 'Álgebra y geometría',
        areaName: 'Matemáticas',
        admissionContext: 'Admisión demo',
      ),
      ragSources: const [],
      llmModel: 'offline',
      llmProvider: 'mock',
    );
  }

  static CurriculumCatalog curriculumCatalog() {
    const theory = '''
## 1. Marco para aprender

Las operaciones básicas (suma, resta, multiplicación y división) son la base de la aritmética escolar.

## 2. Desarrollo detallado

Empieza por dominar el significado de cada operación y luego practica con problemas cotidianos y de examen.

## 3. Qué debes dominar

- Explicar cada operación con un ejemplo.
- Resolver 3 ejercicios guiados y 3 independientes.
''';
    return const CurriculumCatalog(
      areas: [
        CurriculumArea(
          areaName: 'Matemática',
          courses: [
            CurriculumCourse(
              courseId: 1,
              courseName: 'Aritmética',
              topics: [
                LearnableTopic(
                  subtopicId: 1,
                  subtopicName: 'Operaciones básicas',
                  topicName: 'Números y operaciones',
                  courseName: 'Aritmética',
                  areaName: 'Matemática',
                  theoryText: theory,
                  originLabel: 'Base escolar (CNEB)',
                  externalLabel: 'Demo offline',
                ),
                LearnableTopic(
                  subtopicId: 2,
                  subtopicName: 'Porcentajes y regla de tres',
                  topicName: 'Proporciones',
                  courseName: 'Aritmética',
                  areaName: 'Matemática',
                  theoryText:
                      '## 1. Marco para aprender\n\nEl porcentaje expresa una cantidad como parte de 100.\n',
                  originLabel: 'Base escolar (CNEB)',
                  externalLabel: 'Demo offline',
                ),
              ],
            ),
            CurriculumCourse(
              courseId: 2,
              courseName: 'Álgebra',
              topics: [
                LearnableTopic(
                  subtopicId: 3,
                  subtopicName: 'Ecuaciones lineales',
                  topicName: 'Ecuaciones',
                  courseName: 'Álgebra',
                  areaName: 'Matemática',
                  theoryText:
                      '## 1. Marco para aprender\n\nUna ecuación lineal iguala una expresión de primer grado a un valor.\n',
                  originLabel: 'Base escolar (CNEB)',
                  externalLabel: 'Demo offline',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static LearnableTopic? learnableTopic(int subtopicId) {
    for (final area in curriculumCatalog().areas) {
      for (final course in area.courses) {
        for (final topic in course.topics) {
          if (topic.subtopicId == subtopicId) return topic;
        }
      }
    }
    return null;
  }
}
