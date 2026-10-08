import '../dto/tutor_dto.dart';
import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';

/// Llamadas HTTP del tutor IA (CU-10).
class TutorApi {
  const TutorApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<TutorExplainResponseDto>> explain(
    TutorExplainRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(ApiPaths.tutorExplain, data: request.toJson()),
      parser: (json) =>
          TutorExplainResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<TutorExplainResponseDto>> hint(
    TutorExplainRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(ApiPaths.tutorHint, data: request.toJson()),
      parser: (json) =>
          TutorExplainResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
