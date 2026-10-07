import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../data/models/study_tools_model.dart';
import '../../../data/repositories/study_tools_repository.dart';

class StudyToolsProvider {
  const StudyToolsProvider({required StudyToolsRepository repository})
      : _repository = repository;

  final StudyToolsRepository _repository;

  Future<List<FlashcardItem>> getFlashcards(int studentExamId, {int limit = 20}) {
    return _repository.getFlashcards(studentExamId, limit: limit);
  }

  Future<List<ConceptMapNode>> getConceptMap(int studentExamId) {
    return _repository.getConceptMap(studentExamId);
  }
}

final studyToolsProvider = Provider<StudyToolsProvider>((ref) {
  return StudyToolsProvider(repository: ref.watch(studyToolsRepositoryProvider));
});
