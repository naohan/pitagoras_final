import 'json_parse.dart';
import 'base_dto.dart';

class BreakdownItemResponseDto extends BaseDto {
  const BreakdownItemResponseDto({
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

  factory BreakdownItemResponseDto.fromJson(Map<String, dynamic> json) {
    return BreakdownItemResponseDto(
      id: json['id'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      scorePercent: parseDecimal(json['score_percent']),
      areaId: json['area_id'] as int?,
      componentId: json['component_id'] as int?,
      topicId: json['topic_id'] as int?,
      subtopicId: json['subtopic_id'] as int?,
    );
  }
}

class ExamResultResponseDto extends BaseDto {
  const ExamResultResponseDto({
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

  factory ExamResultResponseDto.fromJson(Map<String, dynamic> json) {
    return ExamResultResponseDto(
      id: json['id'] as int,
      studentExamId: json['student_exam_id'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      scorePercent: parseDecimal(json['score_percent']),
      durationSeconds: json['duration_seconds'] as int?,
      calculatedAt: parseDateTime(json['calculated_at']),
      createdAt: parseDateTime(json['created_at']),
    );
  }
}

class StudentExamResultResponseDto extends BaseDto {
  const StudentExamResultResponseDto({
    required this.studentExamId,
    required this.status,
    this.result,
    required this.areas,
    required this.components,
    required this.topics,
    required this.subtopics,
  });

  final int studentExamId;
  final String status;
  final ExamResultResponseDto? result;
  final List<BreakdownItemResponseDto> areas;
  final List<BreakdownItemResponseDto> components;
  final List<BreakdownItemResponseDto> topics;
  final List<BreakdownItemResponseDto> subtopics;

  factory StudentExamResultResponseDto.fromJson(Map<String, dynamic> json) {
    List<BreakdownItemResponseDto> parseList(dynamic value) {
      final list = value as List<dynamic>? ?? [];
      return list
          .map((e) => BreakdownItemResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final resultJson = json['result'];
    return StudentExamResultResponseDto(
      studentExamId: json['student_exam_id'] as int,
      status: json['status'] as String,
      result: resultJson != null
          ? ExamResultResponseDto.fromJson(resultJson as Map<String, dynamic>)
          : null,
      areas: parseList(json['areas']),
      components: parseList(json['components']),
      topics: parseList(json['topics']),
      subtopics: parseList(json['subtopics']),
    );
  }
}

class StudyRecommendationResponseDto extends BaseDto {
  const StudyRecommendationResponseDto({
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

  factory StudyRecommendationResponseDto.fromJson(Map<String, dynamic> json) {
    return StudyRecommendationResponseDto(
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as int,
      entityName: json['entity_name'] as String,
      scorePercent: parseDecimal(json['score_percent']),
      resourceType: json['resource_type'] as String,
      ruleId: json['rule_id'] as String,
      message: json['message'] as String,
    );
  }
}

class StudyPlanResponseDto extends BaseDto {
  const StudyPlanResponseDto({
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
  final List<StudyRecommendationResponseDto> recommendations;
  final Map<String, List<StudyRecommendationResponseDto>> byResourceType;

  factory StudyPlanResponseDto.fromJson(Map<String, dynamic> json) {
    final recommendationsJson = json['recommendations'] as List<dynamic>? ?? [];
    final byTypeJson = json['by_resource_type'] as Map<String, dynamic>? ?? {};

    final byResourceType = <String, List<StudyRecommendationResponseDto>>{};
    byTypeJson.forEach((key, value) {
      final list = value as List<dynamic>? ?? [];
      byResourceType[key] = list
          .map((e) => StudyRecommendationResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return StudyPlanResponseDto(
      studentExamId: json['student_exam_id'] as int,
      globalScorePercent: parseDecimal(json['global_score_percent']),
      estimatedDays: json['estimated_days'] as int,
      focusSubtopics: List<String>.from(json['focus_subtopics'] as List? ?? []),
      recommendations: recommendationsJson
          .map((e) => StudyRecommendationResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      byResourceType: byResourceType,
    );
  }
}
