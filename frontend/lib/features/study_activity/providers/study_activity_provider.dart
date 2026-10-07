import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/study_activity_model.dart';
import '../../../data/repositories/study_activity_repository.dart';

class StudyActivityProvider {
  const StudyActivityProvider({required StudyActivityRepository repository})
      : _repository = repository;

  final StudyActivityRepository _repository;

  Future<void> recordActivity(String activityType, {String? refId}) async {
    if (AppConfig.offlineMode) return;
    try {
      await _repository.recordActivity(activityType, refId: refId);
    } catch (_) {
      // La racha no debe bloquear el flujo principal de estudio.
    }
  }

  Future<StreakInfo> getStreak() async {
    if (AppConfig.offlineMode) return StreakInfo.empty;
    try {
      return await _repository.getStreak();
    } catch (_) {
      return StreakInfo.empty;
    }
  }
}

final studyActivityProvider = Provider<StudyActivityProvider>((ref) {
  return StudyActivityProvider(
    repository: ref.watch(studyActivityRepositoryProvider),
  );
});
