class FeynmanAnalyzeRequestDto {
  const FeynmanAnalyzeRequestDto({
    required this.subtopicName,
    required this.subtopicKey,
    required this.explanation,
  });

  final String subtopicName;
  final String subtopicKey;
  final String explanation;

  Map<String, dynamic> toJson() => {
        'subtopic_name': subtopicName,
        'subtopic_key': subtopicKey,
        'explanation': explanation,
      };
}

class FeynmanAnalysisDto {
  const FeynmanAnalysisDto({
    required this.scorePercent,
    required this.strengths,
    required this.gaps,
    required this.suggestions,
  });

  final double scorePercent;
  final List<String> strengths;
  final List<String> gaps;
  final List<String> suggestions;

  factory FeynmanAnalysisDto.fromJson(Map<String, dynamic> json) {
    return FeynmanAnalysisDto(
      scorePercent: (json['score_percent'] as num).toDouble(),
      strengths: List<String>.from(json['strengths'] as List? ?? []),
      gaps: List<String>.from(json['gaps'] as List? ?? []),
      suggestions: List<String>.from(json['suggestions'] as List? ?? []),
    );
  }
}

class ErrorGuidanceDto {
  const ErrorGuidanceDto({
    required this.questionId,
    required this.errorStep,
    required this.conceptName,
    required this.conceptReminder,
    required this.quickTip,
    this.similarQuestionId,
    this.similarQuestionStem,
    this.hasRichData = false,
    required this.allowRetry,
  });

  final int questionId;
  final String errorStep;
  final String conceptName;
  final String conceptReminder;
  final String quickTip;
  final int? similarQuestionId;
  final String? similarQuestionStem;
  final bool hasRichData;
  final bool allowRetry;

  factory ErrorGuidanceDto.fromJson(Map<String, dynamic> json) {
    return ErrorGuidanceDto(
      questionId: json['question_id'] as int,
      errorStep: json['error_step'] as String,
      conceptName: json['concept_name'] as String,
      conceptReminder: json['concept_reminder'] as String,
      quickTip: json['quick_tip'] as String? ?? '',
      similarQuestionId: json['similar_question_id'] as int?,
      similarQuestionStem: json['similar_question_stem'] as String?,
      hasRichData: json['has_rich_data'] as bool? ?? false,
      allowRetry: json['allow_retry'] as bool? ?? true,
    );
  }
}
