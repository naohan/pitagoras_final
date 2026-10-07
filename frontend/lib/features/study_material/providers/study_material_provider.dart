import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/rag_model.dart';
import '../../../data/repositories/rag_repository.dart';

/// Sube material de estudio al índice RAG del backend.
class StudyMaterialProvider {
  StudyMaterialProvider({required RagRepository repository})
      : _repository = repository;

  final RagRepository _repository;

  Future<RagIngestResult> uploadFile({
    required MultipartFile file,
    int? subtopicId,
    String? title,
  }) async {
    if (AppConfig.offlineMode) {
      return RagIngestResult(
        source: title ?? file.filename ?? 'demo.pdf',
        chunksIndexed: 12,
        chunkIds: const ['offline-chunk-1', 'offline-chunk-2'],
      );
    }

    return _repository.ingestFile(
      file: file,
      subtopicId: subtopicId,
      title: title,
    );
  }

  Future<RagIngestResult> uploadText({
    required String text,
    int? subtopicId,
    String? title,
  }) async {
    if (AppConfig.offlineMode) {
      return RagIngestResult(
        source: title ?? 'texto_manual',
        chunksIndexed: 8,
        chunkIds: const ['offline-text-1'],
      );
    }

    return _repository.ingestText(
      text: text,
      subtopicId: subtopicId,
      title: title,
    );
  }

  Future<RagStats> getStats() async {
    if (AppConfig.offlineMode) {
      return const RagStats(collection: 'offline', chunkCount: 0);
    }
    return _repository.getStats();
  }

  Future<RagContext?> getContextForCareer(int? careerId) async {
    if (careerId == null || AppConfig.offlineMode) return null;
    try {
      return await _repository.getContext(careerId);
    } catch (_) {
      return null;
    }
  }

  Future<MaterialDiagram> buildDiagram({
    String? title,
    String? source,
    String? query,
    int? subtopicId,
  }) async {
    if (AppConfig.offlineMode) {
      return MaterialDiagram(
        title: title ?? 'Apuntes demo',
        chunkCount: 3,
        nodes: const [
          MaterialDiagramNode(
            id: 'root',
            label: 'Álgebra — ecuaciones',
            children: [
              MaterialDiagramNode(
                id: 'sec_0',
                label: 'Conceptos clave',
                children: [
                  MaterialDiagramNode(id: 'item_0', label: 'Ecuación de primer grado', children: []),
                  MaterialDiagramNode(id: 'item_1', label: 'Despeje de incógnitas', children: []),
                ],
              ),
            ],
          ),
        ],
      );
    }

    return _repository.buildDiagram(
      title: title,
      source: source,
      query: query,
      subtopicId: subtopicId,
    );
  }
}

final studyMaterialProvider = Provider<StudyMaterialProvider>((ref) {
  return StudyMaterialProvider(
    repository: ref.watch(ragRepositoryProvider),
  );
});
