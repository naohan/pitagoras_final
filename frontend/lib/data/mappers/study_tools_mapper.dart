import '../dto/study_tools_dto.dart';
import '../models/study_tools_model.dart';

abstract final class StudyToolsMapper {
  static FlashcardItem toFlashcard(FlashcardItemDto dto) {
    return FlashcardItem(
      questionId: dto.questionId,
      front: dto.front,
      back: dto.back,
      subtopicName: dto.subtopicName,
      source: dto.source,
      curriculumOrigins: dto.curriculumOrigins,
    );
  }

  static List<FlashcardItem> toFlashcardList(List<FlashcardItemDto> dtos) {
    return dtos.map(toFlashcard).toList();
  }

  static ConceptMapNode toConceptMapNode(ConceptMapNodeDto dto) {
    return ConceptMapNode(
      id: dto.id,
      name: dto.name,
      entityType: dto.entityType,
      scorePercent: dto.scorePercent,
      level: dto.level,
      children: dto.children.map(toConceptMapNode).toList(),
    );
  }

  static List<ConceptMapNode> toConceptMapList(List<ConceptMapNodeDto> dtos) {
    return dtos.map(toConceptMapNode).toList();
  }
}
