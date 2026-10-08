import '../enums.dart';
import 'base_model.dart';

class DiagnosticItem extends BaseModel {
  const DiagnosticItem({
    required this.entityId,
    required this.name,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercent,
    required this.level,
    this.parentName,
  });

  final int entityId;
  final String name;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercent;
  final PerformanceLevel level;
  final String? parentName;
}

class DiagnosticReport extends BaseModel {
  const DiagnosticReport({
    required this.studentExamId,
    required this.globalScorePercent,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.areas,
    required this.components,
    required this.topics,
    required this.subtopics,
    required this.strengths,
    required this.weaknesses,
  });

  final int studentExamId;
  final double globalScorePercent;
  final int totalQuestions;
  final int correctAnswers;
  final List<DiagnosticItem> areas;
  final List<DiagnosticItem> components;
  final List<DiagnosticItem> topics;
  final List<DiagnosticItem> subtopics;
  final List<String> strengths;
  final List<String> weaknesses;
}
