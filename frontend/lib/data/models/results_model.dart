import '../enums.dart';
import 'base_model.dart';

class BreakdownItem extends BaseModel {
  const BreakdownItem({
    required this.id,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercent,
    this.areaId,
    this.componentId,
    this.topicId,
    this.subtopicId,
  });

  final int id;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercent;
  final int? areaId;
  final int? componentId;
  final int? topicId;
  final int? subtopicId;
}

class ExamResult extends BaseModel {
  const ExamResult({
    required this.id,
    required this.studentExamId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercent,
    this.durationSeconds,
    required this.calculatedAt,
    required this.createdAt,
  });

  final int id;
  final int studentExamId;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercent;
  final int? durationSeconds;
  final DateTime calculatedAt;
  final DateTime createdAt;
}

class StudentExamResult extends BaseModel {
  const StudentExamResult({
    required this.studentExamId,
    required this.status,
    this.result,
    required this.areas,
    required this.components,
    required this.topics,
    required this.subtopics,
  });

  final int studentExamId;
  final StudentExamStatus status;
  final ExamResult? result;
  final List<BreakdownItem> areas;
  final List<BreakdownItem> components;
  final List<BreakdownItem> topics;
  final List<BreakdownItem> subtopics;
}

class StudyRecommendation extends BaseModel {
  const StudyRecommendation({
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.scorePercent,
    required this.resourceType,
    required this.ruleId,
    required this.message,
  });

  final String entityType;
  final int entityId;
  final String entityName;
  final double scorePercent;
  final String resourceType;
  final String ruleId;
  final String message;
}

class StudyPlan extends BaseModel {
  const StudyPlan({
    required this.studentExamId,
    required this.globalScorePercent,
    required this.estimatedDays,
    required this.focusSubtopics,
    required this.recommendations,
    required this.byResourceType,
  });

  final int studentExamId;
  final double globalScorePercent;
  final int estimatedDays;
  final List<String> focusSubtopics;
  final List<StudyRecommendation> recommendations;
  final Map<String, List<StudyRecommendation>> byResourceType;
}
