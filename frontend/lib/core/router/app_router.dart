import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/shell/main_shell_page.dart';
import '../../screens/results/exam_review_page.dart';
import '../../screens/results/results_page.dart';
import '../../screens/saved_answers/saved_answers_page.dart';
import '../../screens/auth/login_page.dart';
import '../../screens/auth/register_page.dart';
import '../../screens/exam/exam_page.dart';
import '../../screens/exam/simulacro_page.dart';
import '../../screens/onboarding/area_page.dart';
import '../../screens/onboarding/exam_target_page.dart';
import '../../screens/onboarding/career_page.dart';
import '../../screens/onboarding/purpose_page.dart';
import '../../screens/onboarding/topic_learning_page.dart';
import '../../screens/onboarding/university_page.dart';
import '../../screens/diagnostic/diagnostic_exam_page.dart';
import '../../screens/diagnostic/diagnostic_page.dart';
import '../../screens/diagnostic/diagnostic_processing_page.dart';
import '../../screens/diagnostic/diagnostic_recommendations_page.dart';
import '../../screens/diagnostic/diagnostic_result_page.dart';
import '../../screens/study_material/study_material_page.dart';
import '../../screens/study_material/material_diagram_page.dart';
import '../../screens/study_techniques/feynman_page.dart';
import '../../screens/agents/motivator_page.dart';
import '../../screens/study_techniques/pomodoro_page.dart';
import '../../screens/study_tools/concept_map_page.dart';
import '../../screens/study_tools/flashcards_page.dart';
import '../../screens/splash/splash_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // Arranca en splash. Para saltar directo al onboarding (solo UI):
    // initialLocation: RoutePaths.onboardingUniversity,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.onboardingPurpose,
        name: 'onboarding-purpose',
        builder: (context, state) => const PurposePage(),
      ),
      GoRoute(
        path: RoutePaths.onboardingTopic,
        name: 'onboarding-topic',
        builder: (context, state) => const TopicLearningPage(),
      ),
      GoRoute(
        path: RoutePaths.onboardingUniversity,
        name: 'onboarding-university',
        builder: (context, state) => const UniversityPage(),
      ),
      GoRoute(
        path: RoutePaths.onboardingArea,
        name: 'onboarding-area',
        builder: (context, state) {
          final universityId = state.uri.queryParameters['universityId'] ?? 'unsa';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return AreaPage(
            universityId: universityId,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.onboardingExamTarget,
        name: 'onboarding-exam-target',
        builder: (context, state) {
          final universityId = state.uri.queryParameters['universityId'] ?? '1';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return ExamTargetPage(
            universityId: universityId,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.onboardingCareer,
        name: 'onboarding-career',
        builder: (context, state) {
          final universityId = state.uri.queryParameters['universityId'] ?? 'unsa';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          final areaId = state.uri.queryParameters['areaId'] ?? 'ingenierias';
          final areaName =
              state.uri.queryParameters['areaName'] ?? 'Ingenierías';
          return CareerPage(
            universityId: universityId,
            universityName: universityName,
            areaId: areaId,
            areaName: areaName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.diagnostic,
        name: 'diagnostic',
        builder: (context, state) {
          final careerName =
              state.uri.queryParameters['careerName'] ?? 'Ingeniería de Sistemas';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return DiagnosticPage(
            careerName: careerName,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.diagnosticExam,
        name: 'diagnostic-exam',
        builder: (context, state) {
          final careerName =
              state.uri.queryParameters['careerName'] ?? 'Ingeniería de Sistemas';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return DiagnosticExamPage(
            careerName: careerName,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.diagnosticProcessing,
        name: 'diagnostic-processing',
        builder: (context, state) {
          final studentExamId =
              int.parse(state.uri.queryParameters['studentExamId'] ?? '0');
          final careerName =
              state.uri.queryParameters['careerName'] ?? 'Ingeniería de Sistemas';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return DiagnosticProcessingPage(
            studentExamId: studentExamId,
            careerName: careerName,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.diagnosticResult,
        name: 'diagnostic-result',
        builder: (context, state) {
          final studentExamId =
              int.parse(state.uri.queryParameters['studentExamId'] ?? '0');
          final careerName =
              state.uri.queryParameters['careerName'] ?? 'Ingeniería de Sistemas';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return DiagnosticResultPage(
            studentExamId: studentExamId,
            careerName: careerName,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.diagnosticRecommendations,
        name: 'diagnostic-recommendations',
        builder: (context, state) {
          final studentExamId =
              int.parse(state.uri.queryParameters['studentExamId'] ?? '0');
          final careerName =
              state.uri.queryParameters['careerName'] ?? 'Ingeniería de Sistemas';
          final universityName =
              state.uri.queryParameters['universityName'] ?? 'UNSA';
          return DiagnosticRecommendationsPage(
            studentExamId: studentExamId,
            careerName: careerName,
            universityName: universityName,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return MainShellPage(initialTab: tab);
        },
      ),
      GoRoute(
        path: RoutePaths.simulacro,
        name: 'simulacro',
        builder: (context, state) => const SimulacroPage(),
      ),
      GoRoute(
        path: RoutePaths.studyMaterial,
        name: 'study-material',
        builder: (context, state) => const StudyMaterialPage(),
      ),
      GoRoute(
        path: RoutePaths.materialDiagram,
        name: 'material-diagram',
        builder: (context, state) {
          final subtopicRaw = state.uri.queryParameters['subtopicId'];
          return MaterialDiagramPage(
            title: state.uri.queryParameters['title'],
            source: state.uri.queryParameters['source'],
            subtopicId: subtopicRaw != null ? int.tryParse(subtopicRaw) : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.savedAnswers,
        name: 'saved-answers',
        builder: (context, state) => const SavedAnswersPage(),
      ),
      GoRoute(
        path: RoutePaths.flashcards,
        name: 'flashcards',
        builder: (context, state) {
          final studentExamId =
              int.parse(state.uri.queryParameters['studentExamId'] ?? '0');
          return FlashcardsPage(studentExamId: studentExamId);
        },
      ),
      GoRoute(
        path: RoutePaths.conceptMap,
        name: 'concept-map',
        builder: (context, state) {
          final studentExamId =
              int.parse(state.uri.queryParameters['studentExamId'] ?? '0');
          return ConceptMapPage(studentExamId: studentExamId);
        },
      ),
      GoRoute(
        path: RoutePaths.feynman,
        name: 'feynman',
        builder: (context, state) => const FeynmanPage(),
      ),
      GoRoute(
        path: RoutePaths.pomodoro,
        name: 'pomodoro',
        builder: (context, state) => const PomodoroPage(),
      ),
      GoRoute(
        path: RoutePaths.motivator,
        name: 'motivator',
        builder: (context, state) => const MotivatorPage(),
      ),
      GoRoute(
        path: '${RoutePaths.exam}/:studentExamId',
        name: 'exam',
        builder: (context, state) {
          final studentExamId = int.parse(state.pathParameters['studentExamId']!);
          return ExamPage(studentExamId: studentExamId);
        },
      ),
      GoRoute(
        path: '${RoutePaths.results}/:studentExamId',
        name: 'results',
        builder: (context, state) {
          final studentExamId = int.parse(state.pathParameters['studentExamId']!);
          return ResultsPage(studentExamId: studentExamId);
        },
        routes: [
          GoRoute(
            path: 'revision',
            name: 'exam-review',
            builder: (context, state) {
              final studentExamId =
                  int.parse(state.pathParameters['studentExamId']!);
              return ExamReviewPage(studentExamId: studentExamId);
            },
          ),
        ],
      ),
    ],
  );
});
