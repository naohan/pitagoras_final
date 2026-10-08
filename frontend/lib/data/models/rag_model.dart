import 'base_model.dart';

class RagIngestResult extends BaseModel {
  const RagIngestResult({
    required this.source,
    required this.chunksIndexed,
    required this.chunkIds,
    this.warning,
  });

  final String source;
  final int chunksIndexed;
  final List<String> chunkIds;
  final String? warning;
}

class RagStats extends BaseModel {
  const RagStats({
    required this.collection,
    required this.chunkCount,
  });

  final String collection;
  final int chunkCount;
}

class RagContext extends BaseModel {
  const RagContext({
    required this.careerId,
    this.subtopicId,
    this.subtopicName,
    this.topicName,
    this.areaName,
    this.curriculumOrigins = const [],
  });

  final int careerId;
  final int? subtopicId;
  final String? subtopicName;
  final String? topicName;
  final String? areaName;
  final List<String> curriculumOrigins;
}

class MaterialDiagramNode extends BaseModel {
  const MaterialDiagramNode({
    required this.id,
    required this.label,
    required this.children,
  });

  final String id;
  final String label;
  final List<MaterialDiagramNode> children;
}

class MaterialDiagram extends BaseModel {
  const MaterialDiagram({
    required this.title,
    required this.chunkCount,
    required this.nodes,
  });

  final String title;
  final int chunkCount;
  final List<MaterialDiagramNode> nodes;
}
