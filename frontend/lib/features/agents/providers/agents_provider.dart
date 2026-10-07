import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/dto/agents_dto.dart';
import '../../../data/models/agents_model.dart';
import '../../../data/repositories/results_repository.dart';

/// Coordina los agentes IA post-examen (diagnóstico, motivador, padres).
class AgentsProvider {
  AgentsProvider({required ResultsRepository repository}) : _repository = repository;

  final ResultsRepository _repository;

  Future<AgentInsight> analyzeDiagnostic(AgentRunRequestDto request) {
    if (AppConfig.offlineMode) {
      return Future.value(
        OfflineData.agentInsight(
          agentName: 'diagnostic',
          studentExamId: request.studentExamId,
          content:
              'Tu mayor oportunidad de mejora está en divisibilidad y patrones numéricos. '
              'Recomendamos 3 sesiones cortas por semana.',
        ),
      );
    }
    return _repository.analyzeDiagnostic(request);
  }

  Future<AgentInsight> encourageStudent(AgentRunRequestDto request) {
    if (AppConfig.offlineMode) {
      return Future.value(
        OfflineData.agentInsight(
          agentName: 'motivator',
          studentExamId: request.studentExamId,
          content: '¡Buen trabajo! Cada intento te acerca más a tu meta de ingreso.',
        ),
      );
    }
    return _repository.encourageStudent(request);
  }

  Future<AgentInsight> parentReport(AgentRunRequestDto request) {
    if (AppConfig.offlineMode) {
      return Future.value(
        OfflineData.agentInsight(
          agentName: 'parents',
          studentExamId: request.studentExamId,
          content:
              'El estudiante completó el simulacro diagnóstico. Se recomienda reforzar '
              'matemáticas básicas en casa.',
        ),
      );
    }
    return _repository.parentReport(request);
  }
}

final agentsProvider = Provider<AgentsProvider>((ref) {
  return AgentsProvider(repository: ref.watch(resultsRepositoryProvider));
});
