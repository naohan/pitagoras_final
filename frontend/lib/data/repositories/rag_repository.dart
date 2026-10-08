import 'package:dio/dio.dart';

import '../api/rag_api.dart';
import '../dto/rag_dto.dart';
import '../mappers/rag_mapper.dart';
import '../models/rag_model.dart';
import 'base_repository.dart';

class RagRepository extends BaseRepository {
  const RagRepository(this._api);

  final RagApi _api;

  Future<RagIngestResult> ingestFile({
    required MultipartFile file,
    int? subtopicId,
    String? title,
  }) async {
    final response = await _api.ingestFile(
      file: file,
      subtopicId: subtopicId,
      title: title,
    );
    return RagMapper.toIngestResult(response);
  }

  Future<RagIngestResult> ingestText({
    required String text,
    int? subtopicId,
    String? title,
  }) async {
    final response = await _api.ingestText(
      text: text,
      subtopicId: subtopicId,
      title: title,
    );
    return RagMapper.toIngestResult(response);
  }

  Future<RagStats> getStats() async {
    final response = await _api.getStats();
    return RagMapper.toStats(response);
  }

  Future<RagContext> getContext(int careerId) async {
    final response = await _api.getContext(careerId);
    return RagMapper.toContext(response);
  }

  Future<MaterialDiagram> buildDiagram({
    String? title,
    String? source,
    String? query,
    int? subtopicId,
    int topK = 8,
  }) async {
    final response = await _api.buildDiagram(
      RagDiagramRequestDto(
        title: title,
        source: source,
        query: query,
        subtopicId: subtopicId,
        topK: topK,
      ),
    );
    return RagMapper.toDiagram(response);
  }
}
