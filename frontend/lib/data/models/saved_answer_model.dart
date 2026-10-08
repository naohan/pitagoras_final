import 'base_model.dart';

class QuestionOptionReview extends BaseModel {
  const QuestionOptionReview({
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
}

class SavedAnswerItem extends BaseModel {
  const SavedAnswerItem({
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
  final List<QuestionOptionReview> options;
}
