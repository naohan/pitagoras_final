import '../api/exam_api.dart';
import '../dto/answer_dto.dart';
import '../dto/exam_dto.dart';
import '../dto/saved_answer_dto.dart';
import '../mappers/answer_mapper.dart';
import '../mappers/exam_mapper.dart';
import '../mappers/results_mapper.dart';
import '../mappers/saved_answer_mapper.dart';
import '../models/answer_model.dart';
import '../models/exam_model.dart';
import '../models/results_model.dart';
import '../models/saved_answer_model.dart';
import 'base_repository.dart';

class ExamRepository extends BaseRepository {
  const ExamRepository(this._api);

  final ExamApi _api;

  Future<ExamTemplate> getExamTemplate(int templateId) async {
    final response = await _api.getExamTemplate(templateId);
    return ExamMapper.toTemplate(response.data);
  }

  Future<ExamTemplate> getDefaultTemplateForCareer(int careerId) async {
    final response = await _api.listExamTemplates(
      careerId: careerId,
      activeOnly: true,
    );
    if (response.data.isEmpty) {
      throw StateError('No hay plantilla de examen para la carrera $careerId');
    }
    final templates = [...response.data]
      ..sort((a, b) => b.questionCount.compareTo(a.questionCount));
    return ExamMapper.toTemplate(templates.first);
  }

  Future<ExamTemplate> getDefaultTemplateForAdmissionProcess(
    int admissionProcessId,
  ) async {
    final response = await _api.listExamTemplates(
      admissionProcessId: admissionProcessId,
      activeOnly: true,
    );
    if (response.data.isEmpty) {
      throw StateError(
        'No hay plantilla para el proceso de admisión $admissionProcessId',
      );
    }
    final templates = [...response.data]
      ..sort((a, b) => b.questionCount.compareTo(a.questionCount));
    return ExamMapper.toTemplate(templates.first);
  }

  Future<List<ExamTemplate>> listExamTemplatesForCareer(int careerId) async {
    final response = await _api.listExamTemplates(
      careerId: careerId,
      activeOnly: true,
    );
    final templates = response.data.map(ExamMapper.toTemplate).toList()
      ..sort((a, b) => b.questionCount.compareTo(a.questionCount));
    return templates;
  }

  Future<StudentExam> startStudentExam(StartStudentExamRequestDto request) async {
    final response = await _api.startStudentExam(request);
    return ExamMapper.toStudentExam(response.data);
  }

  Future<StudentExam> startAdaptiveStudentExam(
    StartAdaptiveStudentExamRequestDto request,
  ) async {
    final response = await _api.startAdaptiveStudentExam(request);
    return ExamMapper.toStudentExam(response.data);
  }

  Future<StudentExam> getStudentExam(int studentExamId) async {
    final response = await _api.getStudentExam(studentExamId);
    return ExamMapper.toStudentExam(response.data);
  }

  Future<ExamTimeStatus> getExamTimeStatus(int studentExamId) async {
    final response = await _api.getExamTimeStatus(studentExamId);
    return ExamMapper.toTimeStatus(response.data);
  }

  Future<StudentAnswer> submitAnswer(
    int studentExamId,
    SubmitAnswerRequestDto request,
  ) async {
    final response = await _api.submitAnswer(studentExamId, request);
    return AnswerMapper.toStudentAnswer(response.data);
  }

  Future<StudentExamResult> finishStudentExam(int studentExamId) async {
    final response = await _api.finishStudentExam(studentExamId);
    return ResultsMapper.toStudentExamResult(response.data);
  }

  Future<StudentAnswer> toggleSaveAnswer(
    int studentExamId,
    int questionId,
    SaveAnswerRequestDto request,
  ) async {
    final response = await _api.toggleSaveAnswer(
      studentExamId,
      questionId,
      request,
    );
    return AnswerMapper.toStudentAnswer(response.data);
  }

  Future<List<SavedAnswerItem>> listSavedAnswers(
    int studentId, {
    String correctness = 'all',
  }) async {
    final response = await _api.listSavedAnswers(
      studentId,
      correctness: correctness,
    );
    return SavedAnswerMapper.toList(response.data);
  }

  Future<List<SavedAnswerItem>> getExamReview(
    int studentExamId, {
    String correctness = 'all',
  }) async {
    final response = await _api.getExamReview(
      studentExamId,
      correctness: correctness,
    );
    return SavedAnswerMapper.toList(response.data);
  }
}
