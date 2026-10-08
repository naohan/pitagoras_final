import '../enums.dart';
import 'base_dto.dart';
import 'json_parse.dart';

class QuestionOptionCreateDto extends BaseDto {
  const QuestionOptionCreateDto({
    required this.label,
    required this.text,
    this.isCorrect = false,
    this.displayOrder = 0,
  });

  final String label;
  final String text;
  final bool isCorrect;
  final int displayOrder;

  Map<String, dynamic> toJson() => {
        'label': label,
        'text': text,
        'is_correct': isCorrect,
        'display_order': displayOrder,
      };
}

class QuestionOptionResponseDto extends BaseDto {
  const QuestionOptionResponseDto({
    required this.id,
    required this.label,
    required this.text,
    required this.isCorrect,
    required this.displayOrder,
    required this.createdAt,
  });

  final int id;
  final String label;
  final String text;
  final bool isCorrect;
  final int displayOrder;
  final DateTime createdAt;

  factory QuestionOptionResponseDto.fromJson(Map<String, dynamic> json) {
    return QuestionOptionResponseDto(
      id: json['id'] as int,
      label: json['label'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: parseDateTime(json['created_at']),
    );
  }
}

class QuestionCreateDto extends BaseDto {
  const QuestionCreateDto({
    required this.subtopicId,
    required this.stem,
    this.explanation,
    this.difficulty = 3,
    this.level = QuestionLevel.intermediate,
    this.avgTimeSeconds,
    this.tags,
    this.isActive = true,
    this.options = const [],
  });

  final int subtopicId;
  final String stem;
  final String? explanation;
  final int difficulty;
  final QuestionLevel level;
  final int? avgTimeSeconds;
  final Object? tags;
  final bool isActive;
  final List<QuestionOptionCreateDto> options;

  Map<String, dynamic> toJson() => {
        'subtopic_id': subtopicId,
        'stem': stem,
        if (explanation != null) 'explanation': explanation,
        'difficulty': difficulty,
        'level': level.value,
        if (avgTimeSeconds != null) 'avg_time_seconds': avgTimeSeconds,
        if (tags != null) 'tags': tags,
        'is_active': isActive,
        'options': options.map((e) => e.toJson()).toList(),
      };
}

class QuestionUpdateDto extends BaseDto {
  const QuestionUpdateDto({
    this.subtopicId,
    this.stem,
    this.explanation,
    this.difficulty,
    this.level,
    this.avgTimeSeconds,
    this.tags,
    this.isActive,
    this.options,
  });

  final int? subtopicId;
  final String? stem;
  final String? explanation;
  final int? difficulty;
  final QuestionLevel? level;
  final int? avgTimeSeconds;
  final Object? tags;
  final bool? isActive;
  final List<QuestionOptionCreateDto>? options;

  Map<String, dynamic> toJson() => {
        if (subtopicId != null) 'subtopic_id': subtopicId,
        if (stem != null) 'stem': stem,
        if (explanation != null) 'explanation': explanation,
        if (difficulty != null) 'difficulty': difficulty,
        if (level != null) 'level': level!.value,
        if (avgTimeSeconds != null) 'avg_time_seconds': avgTimeSeconds,
        if (tags != null) 'tags': tags,
        if (isActive != null) 'is_active': isActive,
        if (options != null)
          'options': options!.map((e) => e.toJson()).toList(),
      };
}

class QuestionResponseDto extends BaseDto {
  const QuestionResponseDto({
    required this.id,
    required this.subtopicId,
    required this.stem,
    this.explanation,
    required this.difficulty,
    required this.level,
    this.avgTimeSeconds,
    this.tags,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  final int id;
  final int subtopicId;
  final String stem;
  final String? explanation;
  final int difficulty;
  final QuestionLevel level;
  final int? avgTimeSeconds;
  final Object? tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionOptionResponseDto> options;

  factory QuestionResponseDto.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];
    return QuestionResponseDto(
      id: json['id'] as int,
      subtopicId: json['subtopic_id'] as int,
      stem: json['stem'] as String,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as int? ?? 3,
      level: QuestionLevel.fromString(json['level'] as String? ?? 'intermediate'),
      avgTimeSeconds: json['avg_time_seconds'] as int?,
      tags: json['tags'],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      options: optionsJson
          .map((e) => QuestionOptionResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Variante examen — `schemas/exam.py` — sin `is_correct` ni explicación.
class QuestionOptionForExamDto extends BaseDto {
  const QuestionOptionForExamDto({
    required this.id,
    required this.label,
    required this.text,
    required this.displayOrder,
  });

  final int id;
  final String label;
  final String text;
  final int displayOrder;

  factory QuestionOptionForExamDto.fromJson(Map<String, dynamic> json) {
    return QuestionOptionForExamDto(
      id: json['id'] as int,
      label: json['label'] as String,
      text: json['text'] as String,
      displayOrder: json['display_order'] as int,
    );
  }
}

class QuestionForExamDto extends BaseDto {
  const QuestionForExamDto({
    required this.id,
    required this.subtopicId,
    required this.stem,
    required this.difficulty,
    required this.displayOrder,
    required this.options,
  });

  final int id;
  final int subtopicId;
  final String stem;
  final int difficulty;
  final int displayOrder;
  final List<QuestionOptionForExamDto> options;

  factory QuestionForExamDto.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];
    return QuestionForExamDto(
      id: json['id'] as int,
      subtopicId: json['subtopic_id'] as int,
      stem: json['stem'] as String,
      difficulty: json['difficulty'] as int,
      displayOrder: json['display_order'] as int,
      options: optionsJson
          .map((e) => QuestionOptionForExamDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
