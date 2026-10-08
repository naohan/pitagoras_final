import '../dto/results_dto.dart';
import '../enums.dart';
import '../models/results_model.dart';

class ResultsMapper {
  const ResultsMapper._();

  static BreakdownItem toBreakdownItem(BreakdownItemResponseDto dto) {
    return BreakdownItem(
      id: dto.id,
      totalQuestions: dto.totalQuestions,
      correctAnswers: dto.correctAnswers,
      scorePercent: dto.scorePercent,
      areaId: dto.areaId,
      componentId: dto.componentId,
      topicId: dto.topicId,
      subtopicId: dto.subtopicId,
    );
  }

  static ExamResult toExamResult(ExamResultResponseDto dto) {
    return ExamResult(
      id: dto.id,
      studentExamId: dto.studentExamId,
      totalQuestions: dto.totalQuestions,
      correctAnswers: dto.correctAnswers,
      scorePercent: dto.scorePercent,
      durationSeconds: dto.durationSeconds,
      calculatedAt: dto.calculatedAt,
      createdAt: dto.createdAt,
    );
  }

  static StudentExamResult toStudentExamResult(StudentExamResultResponseDto dto) {
    return StudentExamResult(
      studentExamId: dto.studentExamId,
      status: StudentExamStatus.fromString(dto.status),
      result: dto.result != null ? toExamResult(dto.result!) : null,
      areas: dto.areas.map(toBreakdownItem).toList(),
      components: dto.components.map(toBreakdownItem).toList(),
      topics: dto.topics.map(toBreakdownItem).toList(),
      subtopics: dto.subtopics.map(toBreakdownItem).toList(),
    );
  }

  static StudyRecommendation toStudyRecommendation(
    StudyRecommendationResponseDto dto,
  ) {
    return StudyRecommendation(
      entityType: dto.entityType,
      entityId: dto.entityId,
      entityName: dto.entityName,
      scorePercent: dto.scorePercent,
      resourceType: dto.resourceType,
      ruleId: dto.ruleId,
      message: dto.message,
    );
  }

  static StudyPlan toStudyPlan(StudyPlanResponseDto dto) {
    final byResourceType = <String, List<StudyRecommendation>>{};
    dto.byResourceType.forEach((key, value) {
      byResourceType[key] = value.map(toStudyRecommendation).toList();
    });

    return StudyPlan(
      studentExamId: dto.studentExamId,
      globalScorePercent: dto.globalScorePercent,
      estimatedDays: dto.estimatedDays,
      focusSubtopics: dto.focusSubtopics,
      recommendations: dto.recommendations.map(toStudyRecommendation).toList(),
      byResourceType: byResourceType,
    );
  }
}
