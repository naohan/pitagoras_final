import 'answer_dto.dart';
import 'json_parse.dart';
import 'question_dto.dart';
import 'base_dto.dart';

class StartStudentExamRequestDto extends BaseDto {
  const StartStudentExamRequestDto({
    required this.studentId,
    required this.examTemplateId,
  });

  final int studentId;
  final int examTemplateId;

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'exam_template_id': examTemplateId,
      };
}

class StartAdaptiveStudentExamRequestDto extends BaseDto {
  const StartAdaptiveStudentExamRequestDto({
    required this.studentId,
    required this.basedOnStudentExamId,
    this.questionCount = 15,
  });

  final int studentId;
  final int basedOnStudentExamId;
  final int questionCount;

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'based_on_student_exam_id': basedOnStudentExamId,
        'question_count': questionCount,
      };
}

class ExamTemplateQuestionResponseDto extends BaseDto {
  const ExamTemplateQuestionResponseDto({
    required this.id,
    required this.questionId,
    required this.displayOrder,
  });

  final int id;
  final int questionId;
  final int displayOrder;

  factory ExamTemplateQuestionResponseDto.fromJson(Map<String, dynamic> json) {
    return ExamTemplateQuestionResponseDto(
      id: parseInt(json['id']),
      questionId: parseInt(json['question_id']),
      displayOrder: parseInt(json['display_order']),
    );
  }
}

class ExamTemplateResponseDto extends BaseDto {
  const ExamTemplateResponseDto({
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
  final List<ExamTemplateQuestionResponseDto> templateQuestions;

  factory ExamTemplateResponseDto.fromJson(Map<String, dynamic> json) {
    final templateQuestionsJson = json['template_questions'] as List<dynamic>? ?? [];
    return ExamTemplateResponseDto(
      id: parseInt(json['id']),
      admissionProcessId: parseInt(json['admission_process_id']),
      name: json['name'] as String,
      durationMinutes: parseInt(json['duration_minutes']),
      questionCount: parseInt(json['question_count']),
      isActive: parseBool(json['is_active']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      templateQuestions: templateQuestionsJson
          .map((e) =>
              ExamTemplateQuestionResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentExamResponseDto extends BaseDto {
  const StudentExamResponseDto({
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
  final String status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionForExamDto> questions;
  final List<StudentAnswerResponseDto> answers;

  factory StudentExamResponseDto.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    final answersJson = json['answers'] as List<dynamic>? ?? [];
    return StudentExamResponseDto(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      examTemplateId: json['exam_template_id'] as int,
      status: json['status'] as String,
      startedAt: parseDateTimeOrNull(json['started_at']),
      finishedAt: parseDateTimeOrNull(json['finished_at']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      questions: questionsJson
          .map((e) => QuestionForExamDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      answers: answersJson
          .map((e) => StudentAnswerResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExamTimeStatusResponseDto extends BaseDto {
  const ExamTimeStatusResponseDto({
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
  final String status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int durationMinutes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool isExpired;

  factory ExamTimeStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return ExamTimeStatusResponseDto(
      studentExamId: json['student_exam_id'] as int,
      status: json['status'] as String,
      startedAt: parseDateTimeOrNull(json['started_at']),
      finishedAt: parseDateTimeOrNull(json['finished_at']),
      durationMinutes: json['duration_minutes'] as int,
      elapsedSeconds: json['elapsed_seconds'] as int,
      remainingSeconds: json['remaining_seconds'] as int,
      isExpired: parseBool(json['is_expired']),
    );
  }
}
