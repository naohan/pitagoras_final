import '../dto/exam_dto.dart';
import '../enums.dart';
import '../models/exam_model.dart';
import 'answer_mapper.dart';
import 'question_mapper.dart';

class ExamMapper {
  const ExamMapper._();

  static ExamTemplateQuestion toTemplateQuestion(
    ExamTemplateQuestionResponseDto dto,
  ) {
    return ExamTemplateQuestion(
      id: dto.id,
      questionId: dto.questionId,
      displayOrder: dto.displayOrder,
    );
  }

  static ExamTemplate toTemplate(ExamTemplateResponseDto dto) {
    return ExamTemplate(
      id: dto.id,
      admissionProcessId: dto.admissionProcessId,
      name: dto.name,
      durationMinutes: dto.durationMinutes,
      questionCount: dto.questionCount,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      templateQuestions: dto.templateQuestions.map(toTemplateQuestion).toList(),
    );
  }

  static StudentExam toStudentExam(StudentExamResponseDto dto) {
    return StudentExam(
      id: dto.id,
      studentId: dto.studentId,
      examTemplateId: dto.examTemplateId,
      status: StudentExamStatus.fromString(dto.status),
      startedAt: dto.startedAt,
      finishedAt: dto.finishedAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      questions: dto.questions.map(QuestionMapper.toQuestionForExam).toList(),
      answers: dto.answers.map(AnswerMapper.toStudentAnswer).toList(),
    );
  }

  static ExamTimeStatus toTimeStatus(ExamTimeStatusResponseDto dto) {
    return ExamTimeStatus(
      studentExamId: dto.studentExamId,
      status: StudentExamStatus.fromString(dto.status),
      startedAt: dto.startedAt,
      finishedAt: dto.finishedAt,
      durationMinutes: dto.durationMinutes,
      elapsedSeconds: dto.elapsedSeconds,
      remainingSeconds: dto.remainingSeconds,
      isExpired: dto.isExpired,
    );
  }
}
