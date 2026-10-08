import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';
import '../dto/study_tools_dto.dart';

class StudyToolsApi {
  const StudyToolsApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<List<FlashcardItemDto>>> getFlashcards(
    int studentExamId, {
    int limit = 20,
  }) {
    return _client.requestList(
      call: () => _client.get(
        ApiPaths.flashcards(studentExamId, limit: limit),
      ),
      itemParser: FlashcardItemDto.fromJson,
    );
  }

  Future<BaseResponse<List<ConceptMapNodeDto>>> getConceptMap(int studentExamId) {
    return _client.requestList(
      call: () => _client.get(ApiPaths.conceptMap(studentExamId)),
      itemParser: ConceptMapNodeDto.fromJson,
    );
  }
}
