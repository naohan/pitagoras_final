import '../dto/diagnostic_dto.dart';
import '../enums.dart';
import '../models/diagnostic_model.dart';

class DiagnosticMapper {
  const DiagnosticMapper._();

  static DiagnosticItem toItem(DiagnosticItemResponseDto dto) {
    return DiagnosticItem(
      entityId: dto.entityId,
      name: dto.name,
      totalQuestions: dto.totalQuestions,
      correctAnswers: dto.correctAnswers,
      scorePercent: dto.scorePercent,
      level: PerformanceLevel.fromString(dto.level),
      parentName: dto.parentName,
    );
  }

  static List<DiagnosticItem> toItemList(List<DiagnosticItemResponseDto> dtos) {
    return dtos.map(toItem).toList();
  }

  static DiagnosticReport toReport(DiagnosticReportResponseDto dto) {
    return DiagnosticReport(
      studentExamId: dto.studentExamId,
      globalScorePercent: dto.globalScorePercent,
      totalQuestions: dto.totalQuestions,
      correctAnswers: dto.correctAnswers,
      areas: dto.areas.map(toItem).toList(),
      components: dto.components.map(toItem).toList(),
      topics: dto.topics.map(toItem).toList(),
      subtopics: dto.subtopics.map(toItem).toList(),
      strengths: dto.strengths,
      weaknesses: dto.weaknesses,
    );
  }
}
