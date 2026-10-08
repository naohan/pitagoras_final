import '../dto/rag_dto.dart';
import '../models/rag_model.dart';

class RagMapper {
  const RagMapper._();

  static RagIngestResult toIngestResult(RagIngestResponseDto dto) {
    return RagIngestResult(
      source: dto.source,
      chunksIndexed: dto.chunksIndexed,
      chunkIds: dto.chunkIds,
      warning: dto.warning,
    );
  }

  static RagStats toStats(RagStatsResponseDto dto) {
    return RagStats(
      collection: dto.collection,
      chunkCount: dto.chunkCount,
    );
  }

  static RagContext toContext(RagContextResponseDto dto) {
    return RagContext(
      careerId: dto.careerId,
      subtopicId: dto.subtopicId,
      subtopicName: dto.subtopicName,
      topicName: dto.topicName,
      areaName: dto.areaName,
      curriculumOrigins: dto.curriculumOrigins,
    );
  }

  static MaterialDiagramNode toDiagramNode(RagDiagramNodeResponseDto dto) {
    return MaterialDiagramNode(
      id: dto.id,
      label: dto.label,
      children: dto.children.map(toDiagramNode).toList(),
    );
  }

  static MaterialDiagram toDiagram(RagDiagramResponseDto dto) {
    return MaterialDiagram(
      title: dto.title,
      chunkCount: dto.chunkCount,
      nodes: dto.nodes.map(toDiagramNode).toList(),
    );
  }
}
