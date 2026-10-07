import '../../data/enums.dart';

import '../../features/exam/providers/exam_provider.dart';

import '../services/session_manager.dart';

import 'route_paths.dart';



/// Decide la pantalla correcta según el progreso del usuario.

///

/// Secuencia esperada:

/// Login/Registro → Onboarding → Diagnóstico → Examen → Procesando

/// → Resultado → Recomendaciones → Inicio

class AppFlowResolver {

  AppFlowResolver._();



  static Future<bool> hasStudyProfile(SessionManager session) async {
    final purpose = await session.getStudyPurpose();
    if (purpose == 'topic_learning') {
      final topic = await session.getFocusSubtopicName();
      return topic != null && topic.isNotEmpty;
    }

    final career = await session.getCareerName();
    final university = await session.getUniversityName();
    return career != null &&
        career.isNotEmpty &&
        university != null &&
        university.isNotEmpty;
  }



  static Future<({String career, String university})> _profileLabels(

    SessionManager session,

  ) async {

    final career = await session.getCareerName();

    final university = await session.getUniversityName();

    return (

      career: career != null && career.isNotEmpty ? career : 'Tu carrera',

      university: university != null && university.isNotEmpty

          ? university

          : 'Tu universidad',

    );

  }



  /// Tras splash o login de usuario existente.

  static Future<String> resolve(

    SessionManager session, {

    ExamProvider? examService,

  }) async {

    if (!await hasStudyProfile(session)) {
      final purpose = await session.getStudyPurpose();
      if (purpose == 'topic_learning') {
        return RoutePaths.onboardingTopic;
      }
      return RoutePaths.onboardingPurpose;
    }



    final profile = await _profileLabels(session);

    final diagnosticCompleted = await session.isDiagnosticCompleted();



    if (examService != null) {

      final resumeRoute = await _resumeExamRoute(

        session: session,

        examService: examService,

        careerName: profile.career,

        universityName: profile.university,

        diagnosticCompleted: diagnosticCompleted,

      );

      if (resumeRoute != null) return resumeRoute;

    }



    if (!diagnosticCompleted) {

      return RoutePaths.home;

    }



    return RoutePaths.home;

  }



  /// Tras registro (usuario nuevo): siempre onboarding.

  /// Tras login: continúa donde corresponda.

  static Future<String> resolveAfterAuth(

    SessionManager session, {

    required bool isNewUser,

    ExamProvider? examService,

  }) async {

    if (isNewUser) return RoutePaths.onboardingPurpose;

    return resolve(session, examService: examService);

  }



  static Future<String?> _resumeExamRoute({

    required SessionManager session,

    required ExamProvider examService,

    required String careerName,

    required String universityName,

    required bool diagnosticCompleted,

  }) async {

    final examId = await session.getStudentExamId();

    if (examId == null) return null;



    try {

      final exam = await examService.getStudentExam(examId);



      if (exam.status == StudentExamStatus.inProgress ||

          exam.status == StudentExamStatus.pending) {

        if (!diagnosticCompleted) {

          return RoutePaths.examSessionWithFlow(

            studentExamId: examId,

            flow: 'diagnostic',

            careerName: careerName,

            universityName: universityName,

          );

        }

        return RoutePaths.examSession(examId);

      }



      if (exam.status == StudentExamStatus.completed && !diagnosticCompleted) {

        return RoutePaths.diagnosticProcessingPath(

          studentExamId: examId,

          careerName: careerName,

          universityName: universityName,

        );

      }

    } catch (_) {

      await session.clearStudentExamId();

    }



    return null;

  }

}

