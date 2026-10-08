import '../dto/agents_dto.dart';
import '../dto/diagnostic_dto.dart';
import '../dto/results_dto.dart';
import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';

/// Resultados, diagnóstico, recomendaciones y agentes IA post-examen.
class ResultsApi {
  const ResultsApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<StudentExamResultResponseDto>> getStudentExamResults(
    int studentExamId,
  ) {
    return _client.request(
      call: () => _client.get(ApiPaths.studentExamResults(studentExamId)),
      parser: (json) =>
          StudentExamResultResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<DiagnosticReportResponseDto>> getDiagnostic(
    int studentExamId,
  ) {
    return _client.request(
      call: () => _client.get(ApiPaths.diagnostic(studentExamId)),
      parser: (json) =>
          DiagnosticReportResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<List<DiagnosticItemResponseDto>>> getDiagnosticAreas(
    int studentExamId,
  ) {
    return _client.requestList(
      call: () => _client.get(ApiPaths.diagnosticAreas(studentExamId)),
      itemParser: DiagnosticItemResponseDto.fromJson,
    );
  }

  Future<BaseResponse<List<DiagnosticItemResponseDto>>> getDiagnosticComponents(
    int studentExamId,
  ) {
    return _client.requestList(
      call: () => _client.get(ApiPaths.diagnosticComponents(studentExamId)),
      itemParser: DiagnosticItemResponseDto.fromJson,
    );
  }

  Future<BaseResponse<List<DiagnosticItemResponseDto>>> getDiagnosticTopics(
    int studentExamId,
  ) {
    return _client.requestList(
      call: () => _client.get(ApiPaths.diagnosticTopics(studentExamId)),
      itemParser: DiagnosticItemResponseDto.fromJson,
    );
  }

  Future<BaseResponse<List<DiagnosticItemResponseDto>>> getDiagnosticSubtopics(
    int studentExamId,
  ) {
    return _client.requestList(
      call: () => _client.get(ApiPaths.diagnosticSubtopics(studentExamId)),
      itemParser: DiagnosticItemResponseDto.fromJson,
    );
  }

  Future<BaseResponse<StudyPlanResponseDto>> getStudyPlan(int studentExamId) {
    return _client.request(
      call: () => _client.get(ApiPaths.studyPlan(studentExamId)),
      parser: (json) =>
          StudyPlanResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<AgentRunResponseDto>> analyzeDiagnostic(
    AgentRunRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(
        ApiPaths.agentDiagnosticAnalyze,
        data: request.toJson(),
      ),
      parser: (json) => AgentRunResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<AgentRunResponseDto>> encourageStudent(
    AgentRunRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(
        ApiPaths.agentMotivatorEncourage,
        data: request.toJson(),
      ),
      parser: (json) => AgentRunResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<AgentRunResponseDto>> parentReport(
    AgentRunRequestDto request,
  ) {
    return _client.request(
      call: () => _client.post(
        ApiPaths.agentParentsReport,
        data: request.toJson(),
      ),
      parser: (json) => AgentRunResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
