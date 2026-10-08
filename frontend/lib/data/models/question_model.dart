import '../enums.dart';
import 'base_model.dart';

class QuestionOption extends BaseModel {
  const QuestionOption({
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
}

class Question extends BaseModel {
  const Question({
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
  final List<QuestionOption> options;
}

class QuestionOptionForExam extends BaseModel {
  const QuestionOptionForExam({
    required this.id,
    required this.label,
    required this.text,
    required this.displayOrder,
  });

  final int id;
  final String label;
  final String text;
  final int displayOrder;
}

class QuestionForExam extends BaseModel {
  const QuestionForExam({
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
  final List<QuestionOptionForExam> options;
}
