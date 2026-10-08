import '../mappers/study_tools_mapper.dart';
import '../models/study_tools_model.dart';
import 'base_repository.dart';
import '../api/study_tools_api.dart';

class StudyToolsRepository extends BaseRepository {
  const StudyToolsRepository(this._api);

  final StudyToolsApi _api;

  Future<List<FlashcardItem>> getFlashcards(int studentExamId, {int limit = 20}) async {
    final response = await _api.getFlashcards(studentExamId, limit: limit);
    return StudyToolsMapper.toFlashcardList(response.data);
  }

  Future<List<ConceptMapNode>> getConceptMap(int studentExamId) async {
    final response = await _api.getConceptMap(studentExamId);
    return StudyToolsMapper.toConceptMapList(response.data);
  }
}
