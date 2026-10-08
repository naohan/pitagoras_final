import 'base_dto.dart';
import 'json_parse.dart';

class SaveAnswerRequestDto extends BaseDto {
  const SaveAnswerRequestDto({required this.isSaved});

  final bool isSaved;

  Map<String, dynamic> toJson() => {'is_saved': isSaved};
}

class QuestionOptionReviewDto extends BaseDto {
  const QuestionOptionReviewDto({
    required this.id,
    required this.label,
    required this.text,
    required this.isCorrect,
    required this.displayOrder,
  });

  final int id;
  final String label;
  final String text;
  final bool isCorrect;
  final int displayOrder;

  factory QuestionOptionReviewDto.fromJson(Map<String, dynamic> json) {
    return QuestionOptionReviewDto(
      id: json['id'] as int,
      label: json['label'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
      displayOrder: json['display_order'] as int,
    );
  }
}

class SavedAnswerItemDto extends BaseDto {
  const SavedAnswerItemDto({
    required this.studentAnswerId,
    required this.studentExamId,
    required this.questionId,
    required this.stem,
    this.areaName,
    this.selectedOptionId,
    this.isCorrect,
    required this.isSaved,
    this.answeredAt,
    this.displayOrder = 0,
    required this.options,
  });

  final int studentAnswerId;
  final int studentExamId;
  final int questionId;
  final String stem;
  final String? areaName;
  final int? selectedOptionId;
  final bool? isCorrect;
  final bool isSaved;
  final DateTime? answeredAt;
  final int displayOrder;
  final List<QuestionOptionReviewDto> options;

  factory SavedAnswerItemDto.fromJson(Map<String, dynamic> json) {
    return SavedAnswerItemDto(
      studentAnswerId: json['student_answer_id'] as int,
      studentExamId: json['student_exam_id'] as int,
      questionId: json['question_id'] as int,
      stem: json['stem'] as String,
      areaName: json['area_name'] as String?,
      selectedOptionId: json['selected_option_id'] as int?,
      isCorrect: parseBoolOrNull(json['is_correct']),
      isSaved: json['is_saved'] as bool? ?? true,
      answeredAt: parseDateTimeOrNull(json['answered_at']),
      displayOrder: json['display_order'] as int? ?? 0,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => QuestionOptionReviewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
