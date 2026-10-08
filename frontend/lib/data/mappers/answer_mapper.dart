import '../dto/answer_dto.dart';
import '../models/answer_model.dart';

class AnswerMapper {
  const AnswerMapper._();

  static StudentAnswer toStudentAnswer(StudentAnswerResponseDto dto) {
    return StudentAnswer(
      id: dto.id,
      studentExamId: dto.studentExamId,
      questionId: dto.questionId,
      selectedOptionId: dto.selectedOptionId,
      isCorrect: dto.isCorrect,
      isSaved: dto.isSaved,
      timeSeconds: dto.timeSeconds,
      answeredAt: dto.answeredAt,
      createdAt: dto.createdAt,
    );
  }

  static List<StudentAnswer> toStudentAnswerList(
    List<StudentAnswerResponseDto> dtos,
  ) {
    return dtos.map(toStudentAnswer).toList();
  }
}
