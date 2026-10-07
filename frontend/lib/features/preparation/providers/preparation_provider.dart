import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/preparation_model.dart';
import '../../../data/repositories/preparation_repository.dart';

class PreparationProvider {
  const PreparationProvider({required PreparationRepository repository})
      : _repository = repository;

  final PreparationRepository _repository;

  Future<List<AdmissionExamTarget>> listExamTargets(int universityId) {
    if (AppConfig.offlineMode) return Future.value(const []);
    return _repository.listExamTargets(universityId);
  }

  Future<List<LearnableTopic>> listLearnableTopics() {
    if (AppConfig.offlineMode) {
      return Future.value([
        for (final area in OfflineData.curriculumCatalog().areas)
          for (final course in area.courses)
            for (final topic in course.topics) topic,
      ]);
    }
    return _repository.listLearnableTopics();
  }

  Future<CurriculumCatalog> getCurriculumCatalog() {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.curriculumCatalog());
    }
    return _repository.getCurriculumCatalog();
  }

  Future<LearnableTopic?> getLearnableTopic(int subtopicId) async {
    if (AppConfig.offlineMode) {
      return OfflineData.learnableTopic(subtopicId);
    }
    try {
      return await _repository.getLearnableTopic(subtopicId);
    } catch (_) {
      return null;
    }
  }

  Future<PreparationProfile> getProfile() {
    if (AppConfig.offlineMode) return Future.value(PreparationProfile.empty);
    return _repository.getProfile();
  }

  Future<PreparationProfile?> updateProfile({
    String? purpose,
    int? universityId,
    int? careerId,
    int? admissionProcessId,
    String? examTargetCode,
    int? focusSubtopicId,
  }) async {
    if (AppConfig.offlineMode) return null;
    try {
      return await _repository.updateProfile(
        purpose: purpose,
        universityId: universityId,
        careerId: careerId,
        admissionProcessId: admissionProcessId,
        examTargetCode: examTargetCode,
        focusSubtopicId: focusSubtopicId,
      );
    } catch (_) {
      return null;
    }
  }
}

final preparationProvider = Provider<PreparationProvider>((ref) {
  return PreparationProvider(
    repository: ref.watch(preparationRepositoryProvider),
  );
});
