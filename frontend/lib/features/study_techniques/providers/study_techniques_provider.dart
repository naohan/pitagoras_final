import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_client_provider.dart';
import '../../../data/api/study_techniques_api.dart';
import '../../../data/dto/study_techniques_dto.dart';

class StudyTechniquesProvider {
  const StudyTechniquesProvider(this._api);

  final StudyTechniquesApi _api;

  Future<FeynmanAnalysisDto> analyzeFeynman(FeynmanAnalyzeRequestDto request) async {
    return (await _api.analyzeFeynman(request)).data;
  }

  Future<ErrorGuidanceDto> getErrorGuidance(
    int questionId, {
    int? selectedOptionId,
  }) async {
    return (await _api.getErrorGuidance(
      questionId,
      selectedOptionId: selectedOptionId,
    ))
        .data;
  }
}

final studyTechniquesProvider = Provider<StudyTechniquesProvider>((ref) {
  return StudyTechniquesProvider(StudyTechniquesApi(ref.watch(apiClientProvider)));
});
