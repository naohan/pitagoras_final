class FlashcardItem {
  const FlashcardItem({
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
}

class ConceptMapNode {
  const ConceptMapNode({
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
  final List<ConceptMapNode> children;
}
