import 'base_model.dart';

class AgentInsight extends BaseModel {
  const AgentInsight({
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
}
