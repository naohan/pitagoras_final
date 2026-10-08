import '../api/api_client.dart';
import '../api/api_paths.dart';
import '../api/base_response.dart';
import '../dto/preparation_dto.dart';

class PreparationApi {
  const PreparationApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<List<AdmissionExamTargetDto>>> listExamTargets(
    int universityId,
  ) {
    return _client.requestList(
      call: () => _client.get(ApiPaths.universityExamTargets(universityId)),
      itemParser: AdmissionExamTargetDto.fromJson,
    );
  }

  Future<BaseResponse<PreparationProfileDto>> getProfile() {
    return _client.request(
      call: () => _client.get(ApiPaths.preparationProfile),
      parser: (json) =>
          PreparationProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<PreparationProfileDto>> updateProfile({
    String? purpose,
    int? universityId,
    int? careerId,
    int? admissionProcessId,
    String? examTargetCode,
    int? focusSubtopicId,
  }) {
    return _client.request(
      call: () => _client.put(
        ApiPaths.preparationProfile,
        data: {
          if (purpose != null) 'purpose': purpose,
          if (universityId != null) 'university_id': universityId,
          if (careerId != null) 'career_id': careerId,
          if (admissionProcessId != null) 'admission_process_id': admissionProcessId,
          if (examTargetCode != null) 'exam_target_code': examTargetCode,
          if (focusSubtopicId != null) 'focus_subtopic_id': focusSubtopicId,
        },
      ),
      parser: (json) =>
          PreparationProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<List<LearnableTopicDto>>> listLearnableTopics() {
    return _client.requestList(
      call: () => _client.get(ApiPaths.learnableTopics),
      itemParser: LearnableTopicDto.fromJson,
    );
  }

  Future<BaseResponse<CurriculumCatalogDto>> getCurriculumCatalog() {
    return _client.request(
      call: () => _client.get(ApiPaths.curriculumCatalog),
      parser: (json) =>
          CurriculumCatalogDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<LearnableTopicDto>> getLearnableTopic(int subtopicId) {
    return _client.request(
      call: () => _client.get(ApiPaths.learnableTopic(subtopicId)),
      parser: (json) =>
          LearnableTopicDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
