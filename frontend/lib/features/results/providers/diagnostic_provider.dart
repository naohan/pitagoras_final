import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/diagnostic_model.dart';
import '../../../data/repositories/results_repository.dart';

/// Coordina el diagnóstico académico post-examen.
class DiagnosticProvider {
  DiagnosticProvider({required ResultsRepository repository})
      : _repository = repository;

  final ResultsRepository _repository;

  Future<DiagnosticReport> getDiagnostic(int studentExamId) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.diagnosticReport(studentExamId));
    }
    return _repository.getDiagnostic(studentExamId);
  }

  Future<List<DiagnosticItem>> getDiagnosticAreas(int studentExamId) async {
    final report = await getDiagnostic(studentExamId);
    return report.areas;
  }

  Future<List<DiagnosticItem>> getDiagnosticComponents(int studentExamId) async {
    final report = await getDiagnostic(studentExamId);
    return report.components;
  }

  Future<List<DiagnosticItem>> getDiagnosticTopics(int studentExamId) async {
    final report = await getDiagnostic(studentExamId);
    return report.topics;
  }

  Future<List<DiagnosticItem>> getDiagnosticSubtopics(int studentExamId) async {
    final report = await getDiagnostic(studentExamId);
    return report.subtopics;
  }
}

final diagnosticProvider = Provider<DiagnosticProvider>((ref) {
  return DiagnosticProvider(repository: ref.watch(resultsRepositoryProvider));
});
