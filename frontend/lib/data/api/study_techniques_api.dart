import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';
import '../dto/study_techniques_dto.dart';

class StudyTechniquesApi {
  const StudyTechniquesApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<FeynmanAnalysisDto>> analyzeFeynman(
    FeynmanAnalyzeRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(ApiPaths.feynmanAnalyze, data: request.toJson()),
      parser: (json) =>
          FeynmanAnalysisDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<ErrorGuidanceDto>> getErrorGuidance(
    int questionId, {
    int? selectedOptionId,
  }) {
    final query = selectedOptionId != null
        ? '?selected_option_id=$selectedOptionId'
        : '';
    return _client.request(
      call: () => _client.get('${ApiPaths.errorGuidance(questionId)}$query'),
      parser: (json) => ErrorGuidanceDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
