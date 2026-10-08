import '../dto/tutor_dto.dart';
import '../models/tutor_model.dart';

class TutorMapper {
  const TutorMapper._();

  static AcademicContext toAcademicContext(AcademicContextResponseDto dto) {
    return AcademicContext(
      questionId: dto.questionId,
      subtopicId: dto.subtopicId,
      subtopicName: dto.subtopicName,
      topicName: dto.topicName,
      componentName: dto.componentName,
      areaName: dto.areaName,
      admissionContext: dto.admissionContext,
    );
  }

  static RagSource toRagSource(RagSourceResponseDto dto) {
    return RagSource(
      id: dto.id,
      score: dto.score,
      text: dto.text,
      metadata: dto.metadata,
    );
  }

  static TutorExplanation toExplanation(TutorExplainResponseDto dto) {
    return TutorExplanation(
      questionId: dto.questionId,
      explanation: dto.explanation,
      academicContext: toAcademicContext(dto.academicContext),
      ragSources: dto.ragSources.map(toRagSource).toList(),
      llmModel: dto.llmModel,
      llmProvider: dto.llmProvider,
    );
  }
}
