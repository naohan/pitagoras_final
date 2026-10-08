import '../api/study_activity_api.dart';
import '../dto/study_activity_dto.dart';
import '../models/study_activity_model.dart';
import 'base_repository.dart';

class StudyActivityRepository extends BaseRepository {
  const StudyActivityRepository(this._api);

  final StudyActivityApi _api;

  Future<void> recordActivity(String activityType, {String? refId}) async {
    await _api.recordActivity(
      StudyActivityRecordRequestDto(
        activityType: activityType,
        refId: refId,
      ),
    );
  }

  Future<StreakInfo> getStreak() async {
    final dto = (await _api.getStreak()).data;
    return StreakInfo(
      currentStreak: dto.currentStreak,
      longestStreak: dto.longestStreak,
      weekMask: dto.weekMask,
      lastActivityDate: dto.lastActivityDate,
    );
  }
}
