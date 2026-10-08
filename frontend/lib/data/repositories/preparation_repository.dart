import '../api/preparation_api.dart';
import '../dto/preparation_dto.dart';
import '../models/preparation_model.dart';
import 'base_repository.dart';

class PreparationRepository extends BaseRepository {
  const PreparationRepository(this._api);

  final PreparationApi _api;

  Future<List<AdmissionExamTarget>> listExamTargets(int universityId) async {
    final response = await _api.listExamTargets(universityId);
    return response.data
        .map(
          (dto) => AdmissionExamTarget(
            id: dto.id,
            universityId: dto.universityId,
            code: dto.code,
            label: dto.label,
            shortLabel: dto.shortLabel,
            description: dto.description,
            simulacroFocus: dto.simulacroFocus,
            displayOrder: dto.displayOrder,
          ),
        )
        .toList();
  }

  Future<List<LearnableTopic>> listLearnableTopics() async {
    final response = await _api.listLearnableTopics();
    return response.data.map(_toLearnableTopic).toList();
  }

  Future<CurriculumCatalog> getCurriculumCatalog() async {
    final dto = (await _api.getCurriculumCatalog()).data;
    return CurriculumCatalog(
      areas: dto.areas
          .map(
            (area) => CurriculumArea(
              areaName: area.areaName,
              courses: area.courses
                  .map(
                    (course) => CurriculumCourse(
                      courseId: course.courseId,
                      courseName: course.courseName,
                      topics: course.topics.map(_toLearnableTopic).toList(),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  Future<LearnableTopic> getLearnableTopic(int subtopicId) async {
    final dto = (await _api.getLearnableTopic(subtopicId)).data;
    return _toLearnableTopic(dto);
  }

  LearnableTopic _toLearnableTopic(LearnableTopicDto dto) {
    return LearnableTopic(
      subtopicId: dto.subtopicId,
      subtopicName: dto.subtopicName,
      topicName: dto.topicName,
      courseName: dto.courseName,
      areaName: dto.areaName,
      theoryText: dto.theoryText,
      originLabel: dto.originLabel,
      externalLabel: dto.externalLabel,
    );
  }

  Future<PreparationProfile> getProfile() async {
    final dto = (await _api.getProfile()).data;
    return _toProfile(dto);
  }

  Future<PreparationProfile> updateProfile({
    String? purpose,
    int? universityId,
    int? careerId,
    int? admissionProcessId,
    String? examTargetCode,
    int? focusSubtopicId,
  }) async {
    final dto = (await _api.updateProfile(
      purpose: purpose,
      universityId: universityId,
      careerId: careerId,
      admissionProcessId: admissionProcessId,
      examTargetCode: examTargetCode,
      focusSubtopicId: focusSubtopicId,
    ))
        .data;
    return _toProfile(dto);
  }

  PreparationProfile _toProfile(PreparationProfileDto dto) {
    return PreparationProfile(
      purpose: dto.purpose,
      universityId: dto.universityId,
      universityCode: dto.universityCode,
      universityName: dto.universityName,
      careerId: dto.careerId,
      careerCode: dto.careerCode,
      careerName: dto.careerName,
      admissionProcessId: dto.admissionProcessId,
      examTargetCode: dto.examTargetCode,
      examTargetLabel: dto.examTargetLabel,
      focusSubtopicId: dto.focusSubtopicId,
      focusSubtopicName: dto.focusSubtopicName,
      focusTopicName: dto.focusTopicName,
      focusAreaName: dto.focusAreaName,
      learningTitle: dto.learningTitle,
      targetScore: dto.targetScore,
      scoreMin: dto.scoreMin,
      scoreMax: dto.scoreMax,
      metaTitle: dto.metaTitle,
    );
  }
}
