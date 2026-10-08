import 'base_dto.dart';

class RagIngestResponseDto extends BaseDto {
  const RagIngestResponseDto({
    required this.source,
    required this.chunksIndexed,
    required this.chunkIds,
    this.warning,
  });

  final String source;
  final int chunksIndexed;
  final List<String> chunkIds;
  final String? warning;

  factory RagIngestResponseDto.fromJson(Map<String, dynamic> json) {
    final ids = json['chunk_ids'] as List<dynamic>? ?? [];
    return RagIngestResponseDto(
      source: json['source'] as String? ?? '',
      chunksIndexed: json['chunks_indexed'] as int? ?? 0,
      chunkIds: ids.map((e) => e.toString()).toList(),
      warning: json['warning'] as String?,
    );
  }
}

class RagStatsResponseDto extends BaseDto {
  const RagStatsResponseDto({
    required this.collection,
    required this.chunkCount,
  });

  final String collection;
  final int chunkCount;

  factory RagStatsResponseDto.fromJson(Map<String, dynamic> json) {
    return RagStatsResponseDto(
      collection: json['collection'] as String? ?? '',
      chunkCount: json['chunk_count'] as int? ?? 0,
    );
  }
}

class RagContextResponseDto extends BaseDto {
  const RagContextResponseDto({
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

  factory RagContextResponseDto.fromJson(Map<String, dynamic> json) {
    final origins = (json['curriculum_origins'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return RagContextResponseDto(
      careerId: json['career_id'] as int,
      subtopicId: json['subtopic_id'] as int?,
      subtopicName: json['subtopic_name'] as String?,
      topicName: json['topic_name'] as String?,
      areaName: json['area_name'] as String?,
      curriculumOrigins: origins,
    );
  }
}

class RagDiagramRequestDto extends BaseDto {
  const RagDiagramRequestDto({
    this.title,
    this.source,
    this.query,
    this.subtopicId,
    this.topK = 8,
  });

  final String? title;
  final String? source;
  final String? query;
  final int? subtopicId;
  final int topK;

  Map<String, dynamic> toJson() => {
        if (title != null && title!.isNotEmpty) 'title': title,
        if (source != null && source!.isNotEmpty) 'source': source,
        if (query != null && query!.isNotEmpty) 'query': query,
        if (subtopicId != null) 'subtopic_id': subtopicId,
        'top_k': topK,
      };
}

class RagDiagramNodeResponseDto extends BaseDto {
  const RagDiagramNodeResponseDto({
    required this.id,
    required this.label,
    required this.children,
  });

  final String id;
  final String label;
  final List<RagDiagramNodeResponseDto> children;

  factory RagDiagramNodeResponseDto.fromJson(Map<String, dynamic> json) {
    final children = json['children'] as List<dynamic>? ?? [];
    return RagDiagramNodeResponseDto(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      children: children
          .map((item) => RagDiagramNodeResponseDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RagDiagramResponseDto extends BaseDto {
  const RagDiagramResponseDto({
    required this.title,
    required this.chunkCount,
    required this.nodes,
  });

  final String title;
  final int chunkCount;
  final List<RagDiagramNodeResponseDto> nodes;

  factory RagDiagramResponseDto.fromJson(Map<String, dynamic> json) {
    final nodes = json['nodes'] as List<dynamic>? ?? [];
    return RagDiagramResponseDto(
      title: json['title'] as String? ?? '',
      chunkCount: json['chunk_count'] as int? ?? 0,
      nodes: nodes
          .map((item) => RagDiagramNodeResponseDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
