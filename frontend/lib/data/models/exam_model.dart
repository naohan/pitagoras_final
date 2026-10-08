import '../enums.dart';
import 'base_model.dart';
import 'question_model.dart';
import 'answer_model.dart';

class ExamTemplateQuestion extends BaseModel {
  const ExamTemplateQuestion({
    required this.id,
    required this.questionId,
    required this.displayOrder,
  });

  final int id;
  final int questionId;
  final int displayOrder;
}

class ExamTemplate extends BaseModel {
  const ExamTemplate({
    required this.id,
    required this.admissionProcessId,
    required this.name,
    required this.durationMinutes,
    required this.questionCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.templateQuestions,
  });

  final int id;
  final int admissionProcessId;
  final String name;
  final int durationMinutes;
  final int questionCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExamTemplateQuestion> templateQuestions;
}

class StudentExam extends BaseModel {
  const StudentExam({
    required this.id,
    required this.studentId,
    required this.examTemplateId,
    required this.status,
    this.startedAt,
    this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
    required this.answers,
  });

  final int id;
  final int studentId;
  final int examTemplateId;
  final StudentExamStatus status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionForExam> questions;
  final List<StudentAnswer> answers;
}

class ExamTimeStatus extends BaseModel {
  const ExamTimeStatus({
    required this.studentExamId,
    required this.status,
    this.startedAt,
    this.finishedAt,
    required this.durationMinutes,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.isExpired,
  });

  final int studentExamId;
  final StudentExamStatus status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int durationMinutes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool isExpired;
}
