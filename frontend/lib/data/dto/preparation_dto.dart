import 'json_parse.dart';

class AdmissionExamTargetDto {
  const AdmissionExamTargetDto({
    required this.id,
    required this.universityId,
    required this.code,
    required this.label,
    required this.shortLabel,
    required this.description,
    required this.simulacroFocus,
    required this.displayOrder,
  });

  final int id;
  final int universityId;
  final String code;
  final String label;
  final String shortLabel;
  final String description;
  final String simulacroFocus;
  final int displayOrder;

  factory AdmissionExamTargetDto.fromJson(Map<String, dynamic> json) {
    return AdmissionExamTargetDto(
      id: json['id'] as int,
      universityId: json['university_id'] as int,
      code: json['code'] as String,
      label: json['label'] as String,
      shortLabel: json['short_label'] as String,
      description: json['description'] as String,
      simulacroFocus: json['simulacro_focus'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

class LearnableTopicDto {
  const LearnableTopicDto({
    required this.subtopicId,
    required this.subtopicName,
    required this.topicName,
    required this.courseName,
    required this.areaName,
    required this.theoryText,
    required this.framework,
    required this.externalCode,
    required this.externalLabel,
    required this.originLabel,
  });

  final int subtopicId;
  final String subtopicName;
  final String topicName;
  final String courseName;
  final String areaName;
  final String theoryText;
  final String framework;
  final String externalCode;
  final String externalLabel;
  final String originLabel;

  factory LearnableTopicDto.fromJson(Map<String, dynamic> json) {
    return LearnableTopicDto(
      subtopicId: json['subtopic_id'] as int,
      subtopicName: json['subtopic_name'] as String,
      topicName: json['topic_name'] as String? ?? '',
      courseName: json['course_name'] as String? ?? '',
      areaName: json['area_name'] as String? ?? '',
      theoryText: json['theory_text'] as String? ?? '',
      framework: json['framework'] as String? ?? 'cneb_secundaria',
      externalCode: json['external_code'] as String? ?? '',
      externalLabel: json['external_label'] as String? ?? '',
      originLabel: json['origin_label'] as String? ?? '',
    );
  }
}

class CurriculumCourseDto {
  const CurriculumCourseDto({
    required this.courseId,
    required this.courseName,
    required this.topics,
  });

  final int courseId;
  final String courseName;
  final List<LearnableTopicDto> topics;

  factory CurriculumCourseDto.fromJson(Map<String, dynamic> json) {
    final rawTopics = json['topics'] as List<dynamic>? ?? const [];
    return CurriculumCourseDto(
      courseId: json['course_id'] as int? ?? 0,
      courseName: json['course_name'] as String? ?? '',
      topics: rawTopics
          .whereType<Map<String, dynamic>>()
          .map(LearnableTopicDto.fromJson)
          .toList(),
    );
  }
}

class CurriculumAreaDto {
  const CurriculumAreaDto({
    required this.areaName,
    required this.courses,
  });

  final String areaName;
  final List<CurriculumCourseDto> courses;

  factory CurriculumAreaDto.fromJson(Map<String, dynamic> json) {
    final rawCourses = json['courses'] as List<dynamic>? ?? const [];
    return CurriculumAreaDto(
      areaName: json['area_name'] as String? ?? '',
      courses: rawCourses
          .whereType<Map<String, dynamic>>()
          .map(CurriculumCourseDto.fromJson)
          .toList(),
    );
  }
}

class CurriculumCatalogDto {
  const CurriculumCatalogDto({required this.areas});

  final List<CurriculumAreaDto> areas;

  factory CurriculumCatalogDto.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'] as List<dynamic>? ?? const [];
    return CurriculumCatalogDto(
      areas: rawAreas
          .whereType<Map<String, dynamic>>()
          .map(CurriculumAreaDto.fromJson)
          .toList(),
    );
  }
}

class PreparationProfileDto {
  const PreparationProfileDto({
    this.purpose,
    this.universityId,
    this.universityCode,
    this.universityName,
    this.careerId,
    this.careerCode,
    this.careerName,
    this.admissionProcessId,
    this.examTargetCode,
    this.examTargetLabel,
    this.focusSubtopicId,
    this.focusSubtopicName,
    this.focusTopicName,
    this.focusAreaName,
    this.learningTitle,
    this.targetScore,
    this.scoreMin,
    this.scoreMax,
    this.metaTitle,
  });

  final String? purpose;
  final int? universityId;
  final String? universityCode;
  final String? universityName;
  final int? careerId;
  final String? careerCode;
  final String? careerName;
  final int? admissionProcessId;
  final String? examTargetCode;
  final String? examTargetLabel;
  final int? focusSubtopicId;
  final String? focusSubtopicName;
  final String? focusTopicName;
  final String? focusAreaName;
  final String? learningTitle;
  final double? targetScore;
  final double? scoreMin;
  final double? scoreMax;
  final String? metaTitle;

  factory PreparationProfileDto.fromJson(Map<String, dynamic> json) {
    return PreparationProfileDto(
      purpose: json['purpose'] as String?,
      universityId: parseIntOrNull(json['university_id']),
      universityCode: json['university_code'] as String?,
      universityName: json['university_name'] as String?,
      careerId: parseIntOrNull(json['career_id']),
      careerCode: json['career_code'] as String?,
      careerName: json['career_name'] as String?,
      admissionProcessId: parseIntOrNull(json['admission_process_id']),
      examTargetCode: json['exam_target_code'] as String?,
      examTargetLabel: json['exam_target_label'] as String?,
      focusSubtopicId: parseIntOrNull(json['focus_subtopic_id']),
      focusSubtopicName: json['focus_subtopic_name'] as String?,
      focusTopicName: json['focus_topic_name'] as String?,
      focusAreaName: json['focus_area_name'] as String?,
      learningTitle: json['learning_title'] as String?,
      targetScore: json['target_score'] == null
          ? null
          : parseDecimal(json['target_score']),
      scoreMin:
          json['score_min'] == null ? null : parseDecimal(json['score_min']),
      scoreMax:
          json['score_max'] == null ? null : parseDecimal(json['score_max']),
      metaTitle: json['meta_title'] as String?,
    );
  }
}
