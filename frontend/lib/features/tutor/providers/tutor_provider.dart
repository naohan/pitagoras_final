import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/dto/tutor_dto.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/repositories/tutor_repository.dart';

/// Coordina las consultas al tutor IA.
class TutorProvider {
  TutorProvider({required TutorRepository repository}) : _repository = repository;

  final TutorRepository _repository;

  Future<TutorExplanation> explain(TutorExplainRequestDto request) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.tutorExplanation(request.questionId));
    }
    return _repository.explain(request);
  }

  Future<TutorExplanation> hint(TutorExplainRequestDto request) {
    if (AppConfig.offlineMode) {
      final full = OfflineData.tutorExplanation(request.questionId);
      return Future.value(
        TutorExplanation(
          questionId: full.questionId,
          explanation:
              'Tip: identifica qué dato te dan y qué te piden. ${full.explanation.split('.').first}.',
          academicContext: full.academicContext,
          ragSources: const [],
          llmModel: full.llmModel,
          llmProvider: full.llmProvider,
        ),
      );
    }
    return _repository.hint(request);
  }
}

final tutorProvider = Provider<TutorProvider>((ref) {
  return TutorProvider(repository: ref.watch(tutorRepositoryProvider));
});
