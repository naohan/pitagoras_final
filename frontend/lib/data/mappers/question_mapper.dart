import '../dto/question_dto.dart';
import '../models/question_model.dart';

class QuestionMapper {
  const QuestionMapper._();

  static QuestionOption toOption(QuestionOptionResponseDto dto) {
    return QuestionOption(
      id: dto.id,
      label: dto.label,
      text: dto.text,
      isCorrect: dto.isCorrect,
      displayOrder: dto.displayOrder,
      createdAt: dto.createdAt,
    );
  }

  static Question toQuestion(QuestionResponseDto dto) {
    return Question(
      id: dto.id,
      subtopicId: dto.subtopicId,
      stem: dto.stem,
      explanation: dto.explanation,
      difficulty: dto.difficulty,
      level: dto.level,
      avgTimeSeconds: dto.avgTimeSeconds,
      tags: dto.tags,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      options: dto.options.map(toOption).toList(),
    );
  }

  static QuestionOptionForExam toOptionForExam(QuestionOptionForExamDto dto) {
    return QuestionOptionForExam(
      id: dto.id,
      label: dto.label,
      text: dto.text,
      displayOrder: dto.displayOrder,
    );
  }

  static QuestionForExam toQuestionForExam(QuestionForExamDto dto) {
    return QuestionForExam(
      id: dto.id,
      subtopicId: dto.subtopicId,
      stem: dto.stem,
      difficulty: dto.difficulty,
      displayOrder: dto.displayOrder,
      options: dto.options.map(toOptionForExam).toList(),
    );
  }

  static List<Question> toQuestionList(List<QuestionResponseDto> dtos) {
    return dtos.map(toQuestion).toList();
  }
}
