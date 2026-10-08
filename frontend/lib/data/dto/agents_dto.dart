import 'base_dto.dart';

class AgentRunRequestDto extends BaseDto {
  const AgentRunRequestDto({
    required this.studentExamId,
    this.studentMessage,
  });

  final int studentExamId;
  final String? studentMessage;

  Map<String, dynamic> toJson() => {
        'student_exam_id': studentExamId,
        if (studentMessage != null) 'student_message': studentMessage,
      };
}

class AgentRunResponseDto extends BaseDto {
  const AgentRunResponseDto({
    required this.agentName,
    this.studentExamId,
    this.questionId,
    required this.content,
    required this.ragSources,
    required this.llmModel,
    required this.llmProvider,
    required this.metadata,
  });

  final String agentName;
  final int? studentExamId;
  final int? questionId;
  final String content;
  final List<Map<String, dynamic>> ragSources;
  final String llmModel;
  final String llmProvider;
  final Map<String, dynamic> metadata;

  factory AgentRunResponseDto.fromJson(Map<String, dynamic> json) {
    final sourcesJson = json['rag_sources'] as List<dynamic>? ?? [];
    return AgentRunResponseDto(
      agentName: json['agent_name'] as String,
      studentExamId: json['student_exam_id'] as int?,
      questionId: json['question_id'] as int?,
      content: json['content'] as String,
      ragSources: sourcesJson.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      llmModel: json['llm_model'] as String,
      llmProvider: json['llm_provider'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}
