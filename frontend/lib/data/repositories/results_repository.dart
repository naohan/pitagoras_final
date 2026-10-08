import '../api/results_api.dart';
import '../dto/agents_dto.dart';
import '../mappers/agents_mapper.dart';
import '../mappers/diagnostic_mapper.dart';
import '../mappers/results_mapper.dart';
import '../models/agents_model.dart';
import '../models/diagnostic_model.dart';
import '../models/results_model.dart';
import 'base_repository.dart';

class ResultsRepository extends BaseRepository {
  const ResultsRepository(this._api);

  final ResultsApi _api;

  Future<StudentExamResult> getStudentExamResults(int studentExamId) async {
    final response = await _api.getStudentExamResults(studentExamId);
    return ResultsMapper.toStudentExamResult(response.data);
  }

  Future<DiagnosticReport> getDiagnostic(int studentExamId) async {
    final response = await _api.getDiagnostic(studentExamId);
    return DiagnosticMapper.toReport(response.data);
  }

  Future<List<DiagnosticItem>> getDiagnosticAreas(int studentExamId) async {
    final response = await _api.getDiagnosticAreas(studentExamId);
    return DiagnosticMapper.toItemList(response.data);
  }

  Future<List<DiagnosticItem>> getDiagnosticComponents(int studentExamId) async {
    final response = await _api.getDiagnosticComponents(studentExamId);
    return DiagnosticMapper.toItemList(response.data);
  }

  Future<List<DiagnosticItem>> getDiagnosticTopics(int studentExamId) async {
    final response = await _api.getDiagnosticTopics(studentExamId);
    return DiagnosticMapper.toItemList(response.data);
  }

  Future<List<DiagnosticItem>> getDiagnosticSubtopics(int studentExamId) async {
    final response = await _api.getDiagnosticSubtopics(studentExamId);
    return DiagnosticMapper.toItemList(response.data);
  }

  Future<StudyPlan> getStudyPlan(int studentExamId) async {
    final response = await _api.getStudyPlan(studentExamId);
    return ResultsMapper.toStudyPlan(response.data);
  }

  Future<AgentInsight> analyzeDiagnostic(AgentRunRequestDto request) async {
    final response = await _api.analyzeDiagnostic(request);
    return AgentsMapper.toInsight(response.data);
  }

  Future<AgentInsight> encourageStudent(AgentRunRequestDto request) async {
    final response = await _api.encourageStudent(request);
    return AgentsMapper.toInsight(response.data);
  }

  Future<AgentInsight> parentReport(AgentRunRequestDto request) async {
    final response = await _api.parentReport(request);
    return AgentsMapper.toInsight(response.data);
  }
}
