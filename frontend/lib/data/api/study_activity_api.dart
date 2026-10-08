import '../api/api_client.dart';
import '../api/api_paths.dart';
import '../api/base_response.dart';
import '../dto/study_activity_dto.dart';

class StudyActivityApi {
  const StudyActivityApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<StudyActivityRecordDto>> recordActivity(
    StudyActivityRecordRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(ApiPaths.studyActivity, data: request.toJson()),
      parser: (json) =>
          StudyActivityRecordDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<StreakDto>> getStreak() {
    return _client.request(
      call: () => _client.get(ApiPaths.studyActivityStreak),
      parser: (json) => StreakDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
