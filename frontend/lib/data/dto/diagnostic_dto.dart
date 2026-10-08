import 'base_dto.dart';
import 'json_parse.dart';

class DiagnosticItemResponseDto extends BaseDto {
  const DiagnosticItemResponseDto({
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
  final String level;
  final String? parentName;

  factory DiagnosticItemResponseDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticItemResponseDto(
      entityId: json['entity_id'] as int,
      name: json['name'] as String,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      scorePercent: parseDecimal(json['score_percent']),
      level: json['level'] as String,
      parentName: json['parent_name'] as String?,
    );
  }
}

class DiagnosticReportResponseDto extends BaseDto {
  const DiagnosticReportResponseDto({
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
  final List<DiagnosticItemResponseDto> areas;
  final List<DiagnosticItemResponseDto> components;
  final List<DiagnosticItemResponseDto> topics;
  final List<DiagnosticItemResponseDto> subtopics;
  final List<String> strengths;
  final List<String> weaknesses;

  factory DiagnosticReportResponseDto.fromJson(Map<String, dynamic> json) {
    List<DiagnosticItemResponseDto> parseItems(dynamic value) {
      final list = value as List<dynamic>? ?? [];
      return list
          .map((e) => DiagnosticItemResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DiagnosticReportResponseDto(
      studentExamId: json['student_exam_id'] as int,
      globalScorePercent: parseDecimal(json['global_score_percent']),
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      areas: parseItems(json['areas']),
      components: parseItems(json['components']),
      topics: parseItems(json['topics']),
      subtopics: parseItems(json['subtopics']),
      strengths: List<String>.from(json['strengths'] as List? ?? []),
      weaknesses: List<String>.from(json['weaknesses'] as List? ?? []),
    );
  }
}
