class AdmissionExamTarget {
  const AdmissionExamTarget({
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
}

class LearnableTopic {
  const LearnableTopic({
    required this.subtopicId,
    required this.subtopicName,
    required this.topicName,
    required this.courseName,
    required this.areaName,
    required this.theoryText,
    required this.originLabel,
    required this.externalLabel,
  });

  final int subtopicId;
  final String subtopicName;
  final String topicName;
  final String courseName;
  final String areaName;
  final String theoryText;
  final String originLabel;
  final String externalLabel;
}

class CurriculumCourse {
  const CurriculumCourse({
    required this.courseId,
    required this.courseName,
    required this.topics,
  });

  final int courseId;
  final String courseName;
  final List<LearnableTopic> topics;
}

class CurriculumArea {
  const CurriculumArea({
    required this.areaName,
    required this.courses,
  });

  final String areaName;
  final List<CurriculumCourse> courses;
}

class CurriculumCatalog {
  const CurriculumCatalog({required this.areas});

  final List<CurriculumArea> areas;

  static const empty = CurriculumCatalog(areas: []);
}

class PreparationProfile {
  const PreparationProfile({
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

  bool get isTopicLearning => purpose == 'topic_learning';
  bool get isAdmission => purpose == 'admission' || purpose == null;

  static const empty = PreparationProfile();
}

abstract final class StudyPurposes {
  static const admission = 'admission';
  static const topicLearning = 'topic_learning';
}
