import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/results_model.dart';
import '../../../data/repositories/results_repository.dart';

/// Coordina resultados de examen y plan de estudio.
class ResultsProvider {
  ResultsProvider({required ResultsRepository repository}) : _repository = repository;

  final ResultsRepository _repository;

  Future<StudentExamResult> getStudentExamResults(int studentExamId) {
    if (AppConfig.offlineMode) {
      final cached = OfflineData.cachedFinishResult(studentExamId);
      if (cached != null) return Future.value(cached);
      return Future.value(OfflineData.finishStudentExam(studentExamId));
    }
    return _repository.getStudentExamResults(studentExamId);
  }

  Future<StudyPlan> getStudyPlan(int studentExamId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.studyPlan(studentExamId));
    }
    return _repository.getStudyPlan(studentExamId);
  }
}

final resultsProvider = Provider<ResultsProvider>((ref) {
  return ResultsProvider(repository: ref.watch(resultsRepositoryProvider));
});
