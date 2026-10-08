import 'base_dto.dart';
import 'json_parse.dart';

class SubmitAnswerRequestDto extends BaseDto {
  const SubmitAnswerRequestDto({
    required this.questionId,
    this.selectedOptionId,
    this.timeSeconds,
  });

  final int questionId;
  final int? selectedOptionId;
  final int? timeSeconds;

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'selected_option_id': selectedOptionId,
        if (timeSeconds != null) 'time_seconds': timeSeconds,
      };
}

class StudentAnswerResponseDto extends BaseDto {
  const StudentAnswerResponseDto({
    required this.id,
    required this.studentExamId,
    required this.questionId,
    this.selectedOptionId,
    this.isCorrect,
    this.isSaved = false,
    this.timeSeconds,
    this.answeredAt,
    required this.createdAt,
  });

  final int id;
  final int studentExamId;
  final int questionId;
  final int? selectedOptionId;
  final bool? isCorrect;
  final bool isSaved;
  final int? timeSeconds;
  final DateTime? answeredAt;
  final DateTime createdAt;

  factory StudentAnswerResponseDto.fromJson(Map<String, dynamic> json) {
    return StudentAnswerResponseDto(
      id: json['id'] as int,
      studentExamId: json['student_exam_id'] as int,
      questionId: json['question_id'] as int,
      selectedOptionId: json['selected_option_id'] as int?,
      isCorrect: parseBoolOrNull(json['is_correct']),
      isSaved: json['is_saved'] as bool? ?? false,
      timeSeconds: json['time_seconds'] as int?,
      answeredAt: parseDateTimeOrNull(json['answered_at']),
      createdAt: parseDateTime(json['created_at']),
    );
  }
}
