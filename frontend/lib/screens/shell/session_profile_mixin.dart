import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/unsa_exam_target.dart';
import '../../core/providers/providers.dart';
import '../../core/services/career_id_resolver.dart';
import '../../core/services/study_flow_helper.dart';

mixin SessionProfileMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String? userName;
  String? careerName;
  String? universityName;
  int? lastStudentExamId;
  int? diagnosticStudentExamId;
  UnsaExamTarget? examTarget;
  String? studyPurpose;
  String? focusSubtopicName;
  int? focusSubtopicId;
  bool diagnosticCompleted = false;
  bool profileLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadSessionProfile());
  }

  Future<void> loadSessionProfile() async {
    final session = ref.read(sessionManagerProvider);
    await CareerIdResolver.ensure(
      session: session,
      catalog: ref.read(catalogProvider),
      preparation: ref.read(preparationProvider),
    );
    final loadedName = await session.getUserFullName();
    final loadedCareer = await session.getCareerName();
    final loadedUniversity = await session.getUniversityName();
    final loadedExamId = await session.getStudentExamId();
    final loadedDiagnosticExamId = await session.getDiagnosticStudentExamId();
    final loadedTarget = await session.getUnsaExamTarget();
    final loadedPurpose = await session.getStudyPurpose();
    final loadedFocusTopic = await session.getFocusSubtopicName();
    final loadedFocusId = await session.getFocusSubtopicId();
    var loadedDiagnostic = await session.isDiagnosticCompleted();

    if (!loadedDiagnostic && loadedDiagnosticExamId != null) {
      try {
        await ref.read(diagnosticProvider).getDiagnostic(loadedDiagnosticExamId);
        await session.setDiagnosticCompleted(true);
        loadedDiagnostic = true;
      } catch (_) {
        // Sin diagnóstico completado en servidor.
      }
    }

    if (!mounted) return;
    setState(() {
      userName = loadedName;
      careerName = loadedCareer;
      universityName = loadedUniversity;
      lastStudentExamId = loadedExamId;
      diagnosticStudentExamId = loadedDiagnosticExamId;
      examTarget = loadedTarget ??
          (UnsaExamTarget.isUnsaUniversity(loadedUniversity)
              ? UnsaExamTarget.ordinario
              : null);
      studyPurpose = loadedPurpose;
      focusSubtopicName = loadedFocusTopic;
      focusSubtopicId = loadedFocusId;
      diagnosticCompleted = loadedDiagnostic;
      profileLoading = false;
    });
  }

  @override
  void activate() {
    super.activate();
    if (!profileLoading) {
      loadSessionProfile();
    }
  }

  bool get hasStudyProfile {
    if (studyPurpose == 'topic_learning') {
      return focusSubtopicName != null && focusSubtopicName!.isNotEmpty;
    }
    return careerName != null &&
        careerName!.isNotEmpty &&
        universityName != null &&
        universityName!.isNotEmpty;
  }

  bool get isTopicLearning => studyPurpose == 'topic_learning';

  bool get isUnsaStudent =>
      UnsaExamTarget.isUnsaUniversity(universityName);

  int? get scoreExamId => diagnosticStudentExamId ?? lastStudentExamId;

  String greetingText(String baseGreeting) {
    final name = userName?.trim();
    if (name != null && name.isNotEmpty) return '$baseGreeting, $name';
    return baseGreeting;
  }

  Future<bool> refreshDiagnosticStatus() => resolveDiagnosticCompleted(ref);
}
