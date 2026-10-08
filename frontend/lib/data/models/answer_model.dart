import 'base_model.dart';

class StudentAnswer extends BaseModel {
  const StudentAnswer({
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
}
