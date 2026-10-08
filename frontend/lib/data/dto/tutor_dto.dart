import 'base_dto.dart';

class TutorExplainRequestDto extends BaseDto {
  const TutorExplainRequestDto({
    required this.questionId,
    this.studentMessage,
    this.selectedOptionId,
    this.topK,
  });

  final int questionId;
  final String? studentMessage;
  final int? selectedOptionId;
  final int? topK;

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        if (studentMessage != null) 'student_message': studentMessage,
        if (selectedOptionId != null) 'selected_option_id': selectedOptionId,
        if (topK != null) 'top_k': topK,
      };
}

class AcademicContextResponseDto extends BaseDto {
  const AcademicContextResponseDto({
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

  factory AcademicContextResponseDto.fromJson(Map<String, dynamic> json) {
    return AcademicContextResponseDto(
      questionId: json['question_id'] as int,
      subtopicId: json['subtopic_id'] as int,
      subtopicName: json['subtopic_name'] as String,
      topicName: json['topic_name'] as String,
      componentName: json['component_name'] as String,
      areaName: json['area_name'] as String,
      admissionContext: json['admission_context'] as String,
    );
  }
}

class RagSourceResponseDto extends BaseDto {
  const RagSourceResponseDto({
    required this.id,
    required this.score,
    required this.text,
    required this.metadata,
  });

  final String id;
  final double score;
  final String text;
  final Map<String, dynamic> metadata;

  factory RagSourceResponseDto.fromJson(Map<String, dynamic> json) {
    return RagSourceResponseDto(
      id: json['id'] as String,
      score: (json['score'] as num).toDouble(),
      text: json['text'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

class TutorExplainResponseDto extends BaseDto {
  const TutorExplainResponseDto({
    required this.questionId,
    required this.explanation,
    required this.academicContext,
    required this.ragSources,
    required this.llmModel,
    required this.llmProvider,
  });

  final int questionId;
  final String explanation;
  final AcademicContextResponseDto academicContext;
  final List<RagSourceResponseDto> ragSources;
  final String llmModel;
  final String llmProvider;

  factory TutorExplainResponseDto.fromJson(Map<String, dynamic> json) {
    final sourcesJson = json['rag_sources'] as List<dynamic>? ?? [];
    return TutorExplainResponseDto(
      questionId: json['question_id'] as int,
      explanation: json['explanation'] as String,
      academicContext: AcademicContextResponseDto.fromJson(
        json['academic_context'] as Map<String, dynamic>,
      ),
      ragSources: sourcesJson
          .map((e) => RagSourceResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      llmModel: json['llm_model'] as String,
      llmProvider: json['llm_provider'] as String,
    );
  }
}
