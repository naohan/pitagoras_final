import '../dto/agents_dto.dart';
import '../models/agents_model.dart';

class AgentsMapper {
  const AgentsMapper._();

  static AgentInsight toInsight(AgentRunResponseDto dto) {
    return AgentInsight(
      agentName: dto.agentName,
      studentExamId: dto.studentExamId,
      questionId: dto.questionId,
      content: dto.content,
      ragSources: dto.ragSources,
      llmModel: dto.llmModel,
      llmProvider: dto.llmProvider,
      metadata: dto.metadata,
    );
  }
}
