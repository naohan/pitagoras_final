import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/dto/answer_dto.dart';
import '../../../data/dto/exam_dto.dart';
import '../../../data/dto/saved_answer_dto.dart';
import '../../../data/models/answer_model.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/results_model.dart';
import '../../../data/models/saved_answer_model.dart';
import '../../../data/repositories/exam_repository.dart';

/// Coordina el flujo de examen (plantilla, sesión, respuestas, tiempo).
class ExamProvider {
  ExamProvider({required ExamRepository repository}) : _repository = repository;

  final ExamRepository _repository;

  Future<ExamTemplate> getExamTemplate(int templateId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.examTemplate(templateId));
    }
    return _repository.getExamTemplate(templateId);
  }

  Future<ExamTemplate> getDefaultTemplateForCareer(int careerId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.examTemplate(AppConfig.examTemplateId));
    }
    return _repository.getDefaultTemplateForCareer(careerId);
  }

  Future<ExamTemplate> getDefaultTemplateForAdmissionProcess(
    int admissionProcessId,
  ) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.examTemplate(AppConfig.examTemplateId));
    }
    return _repository.getDefaultTemplateForAdmissionProcess(admissionProcessId);
  }

  Future<List<ExamTemplate>> listExamTemplatesForCareer(int careerId) {
    if (AppConfig.offlineMode) {
      return Future.value([OfflineData.examTemplate(AppConfig.examTemplateId)]);
    }
    return _repository.listExamTemplatesForCareer(careerId);
  }

  Future<StudentExam> startStudentExam(StartStudentExamRequestDto request) {
    if (AppConfig.offlineMode) {
      OfflineData.resetExamClock();
      return Future.value(OfflineData.studentExam());
    }
    return _repository.startStudentExam(request);
  }

  Future<StudentExam> startAdaptiveStudentExam(
    StartAdaptiveStudentExamRequestDto request,
  ) {
    if (AppConfig.offlineMode) {
      OfflineData.resetExamClock();
      return Future.value(OfflineData.studentExam());
    }
    return _repository.startAdaptiveStudentExam(request);
  }

  Future<StudentExam> getStudentExam(int studentExamId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.studentExam(id: studentExamId));
    }
    return _repository.getStudentExam(studentExamId);
  }

  Future<ExamTimeStatus> getExamTimeStatus(int studentExamId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.examTimeStatus(studentExamId));
    }
    return _repository.getExamTimeStatus(studentExamId);
  }

  Future<StudentAnswer> submitAnswer(
    int studentExamId,
    SubmitAnswerRequestDto request,
  ) {
    if (AppConfig.offlineMode) {
      final optionId = request.selectedOptionId;
      if (optionId == null) {
        return Future.error(ArgumentError('selectedOptionId requerido'));
      }
      return Future.value(
        OfflineData.submitAnswer(
          studentExamId: studentExamId,
          questionId: request.questionId,
          selectedOptionId: optionId,
        ),
      );
    }
    return _repository.submitAnswer(studentExamId, request);
  }

  Future<StudentExamResult> finishStudentExam(int studentExamId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.finishStudentExam(studentExamId));
    }
    return _repository.finishStudentExam(studentExamId);
  }

  Future<StudentAnswer> toggleSaveAnswer(
    int studentExamId,
    int questionId, {
    required bool isSaved,
  }) {
    if (AppConfig.offlineMode) {
      return Future.value(
        StudentAnswer(
          id: 0,
          studentExamId: studentExamId,
          questionId: questionId,
          isSaved: isSaved,
          createdAt: DateTime.now(),
        ),
      );
    }
    return _repository.toggleSaveAnswer(
      studentExamId,
      questionId,
      SaveAnswerRequestDto(isSaved: isSaved),
    );
  }

  Future<List<SavedAnswerItem>> listSavedAnswers(
    int studentId, {
    String correctness = 'all',
  }) {
    if (AppConfig.offlineMode) {
      return Future.value(const []);
    }
    return _repository.listSavedAnswers(studentId, correctness: correctness);
  }

  Future<List<SavedAnswerItem>> getExamReview(
    int studentExamId, {
    String correctness = 'all',
  }) {
    if (AppConfig.offlineMode) {
      return Future.value(const []);
    }
    return _repository.getExamReview(studentExamId, correctness: correctness);
  }
}

final examProvider = Provider<ExamProvider>((ref) {
  return ExamProvider(repository: ref.watch(examRepositoryProvider));
});
