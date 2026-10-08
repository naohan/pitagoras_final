import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_paths.dart';
import '../dto/rag_dto.dart';

/// Indexación de material en ChromaDB para el Tutor IA.
class RagApi {
  const RagApi(this._client);

  final ApiClient _client;

  Future<RagIngestResponseDto> ingestFile({
    required MultipartFile file,
    int? subtopicId,
    String? title,
  }) async {
    final formData = FormData.fromMap({
      'file': file,
      if (subtopicId != null) 'subtopic_id': subtopicId,
      if (title != null && title.isNotEmpty) 'title': title,
    });

    final response = await _client.request(
      call: () => _client.post(
        ApiPaths.ragIngestFile,
        data: formData,
        // Dio debe añadir el boundary; no fijar multipart sin boundary.
        options: Options(
          headers: {Headers.contentTypeHeader: null},
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      ),
      parser: (json) =>
          RagIngestResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<RagIngestResponseDto> ingestText({
    required String text,
    int? subtopicId,
    String? title,
  }) async {
    final response = await _client.request(
      call: () => _client.post(
        ApiPaths.ragIngestText,
        data: {
          'text': text,
          if (subtopicId != null) 'subtopic_id': subtopicId,
          if (title != null && title.isNotEmpty) 'title': title,
          'source': title ?? 'texto_manual',
        },
        options: Options(
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      ),
      parser: (json) =>
          RagIngestResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<RagStatsResponseDto> getStats() async {
    final response = await _client.request(
      call: () => _client.get(ApiPaths.ragStats),
      parser: (json) =>
          RagStatsResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<RagContextResponseDto> getContext(int careerId) async {
    final response = await _client.request(
      call: () => _client.get(ApiPaths.ragContext(careerId)),
      parser: (json) =>
          RagContextResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<RagDiagramResponseDto> buildDiagram(RagDiagramRequestDto request) async {
    final response = await _client.request(
      call: () => _client.post(
        ApiPaths.ragDiagram,
        data: request.toJson(),
      ),
      parser: (json) =>
          RagDiagramResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
