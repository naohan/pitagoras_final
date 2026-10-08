class FlashcardItemDto {
  const FlashcardItemDto({
    required this.questionId,
    required this.front,
    required this.back,
    required this.subtopicName,
    required this.source,
    this.curriculumOrigins = const [],
  });

  final int questionId;
  final String front;
  final String back;
  final String subtopicName;
  final String source;
  final List<String> curriculumOrigins;

  factory FlashcardItemDto.fromJson(Map<String, dynamic> json) {
    final origins = (json['curriculum_origins'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return FlashcardItemDto(
      questionId: json['question_id'] as int,
      front: json['front'] as String,
      back: json['back'] as String,
      subtopicName: json['subtopic_name'] as String,
      source: json['source'] as String,
      curriculumOrigins: origins,
    );
  }
}

class ConceptMapNodeDto {
  const ConceptMapNodeDto({
    required this.id,
    required this.name,
    required this.entityType,
    this.scorePercent,
    this.level,
    required this.children,
  });

  final int id;
  final String name;
  final String entityType;
  final double? scorePercent;
  final String? level;
  final List<ConceptMapNodeDto> children;

  factory ConceptMapNodeDto.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>? ?? [];
    return ConceptMapNodeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      entityType: json['entity_type'] as String,
      scorePercent: (json['score_percent'] as num?)?.toDouble(),
      level: json['level'] as String?,
      children: childrenJson
          .map((item) => ConceptMapNodeDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
