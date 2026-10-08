import 'base_model.dart';

class AcademicContext extends BaseModel {
  const AcademicContext({
    required this.questionId,
    required this.subtopicId,
    required this.subtopicName,
    required this.topicName,
    required this.componentName,
    required this.areaName,
    required this.admissionContext,
  });

  final int questionId;
  final int subtopicId;
  final String subtopicName;
  final String topicName;
  final String componentName;
  final String areaName;
  final String admissionContext;
}

class RagSource extends BaseModel {
  const RagSource({
    required this.id,
    required this.score,
    required this.text,
    required this.metadata,
  });

  final String id;
  final double score;
  final String text;
  final Map<String, dynamic> metadata;
}

class TutorExplanation extends BaseModel {
  const TutorExplanation({
    required this.questionId,
    required this.explanation,
    required this.academicContext,
    required this.ragSources,
    required this.llmModel,
    required this.llmProvider,
  });

  final int questionId;
  final String explanation;
  final AcademicContext academicContext;
  final List<RagSource> ragSources;
  final String llmModel;
  final String llmProvider;
}
