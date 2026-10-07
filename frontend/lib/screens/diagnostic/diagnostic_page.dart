import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/exam_template_not_found.dart';
import '../../core/services/exam_template_resolver.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/dto/exam_dto.dart';
import '../../data/models/exam_model.dart';
import 'widgets/diagnostic_scaffold.dart';

class DiagnosticPage extends ConsumerStatefulWidget {
  const DiagnosticPage({
    super.key,
    required this.careerName,
    required this.universityName,
  });

  final String careerName;
  final String universityName;

  @override
  ConsumerState<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends ConsumerState<DiagnosticPage> {
  bool _loading = true;
  bool _starting = false;
  String? _errorMessage;
  ExamTemplate? _template;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTemplate());
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final session = ref.read(sessionManagerProvider);
      final template = await ExamTemplateResolver.resolveTemplate(
        session,
        ref.read(examProvider),
        catalog: ref.read(catalogProvider),
        preparation: ref.read(preparationProvider),
      );
      if (!mounted) return;
      setState(() {
        _template = template;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = _resolveError(error);
      });
    }
  }

  Future<void> _startDiagnosticExam() async {
    if (_starting || _template == null) return;

    final studentId = await ref.read(sessionManagerProvider).getStudentId();
    if (studentId == null) {
      setState(() => _errorMessage = AppStrings.simulacroNoStudent);
      return;
    }

    setState(() {
      _starting = true;
      _errorMessage = null;
    });

    try {
      final studentExam = await ref.read(examProvider).startStudentExam(
            StartStudentExamRequestDto(
              studentId: studentId,
              examTemplateId: _template!.id,
            ),
          );

      final session = ref.read(sessionManagerProvider);
      await session.saveStudentExamId(studentExam.id);
      await session.saveDiagnosticStudentExamId(studentExam.id);
      await session.saveStudyProfile(
            careerName: widget.careerName,
            universityName: widget.universityName,
            universityId: await session.getUniversityId(),
            careerId: await session.getCareerId(),
          );

      final alreadyCompleted = await session.isDiagnosticCompleted();
      if (!alreadyCompleted) {
        await session.setDiagnosticCompleted(false);
      }

      if (!mounted) return;
      context.go(
        RoutePaths.examSessionWithFlow(
          studentExamId: studentExam.id,
          flow: 'diagnostic',
          careerName: widget.careerName,
          universityName: widget.universityName,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _errorMessage = _resolveError(error);
      });
    }
  }

  String _resolveError(Object error) {
    if (error is ExamTemplateNotFoundException) return error.message;
    final apiException = readApiException(error);
    if (apiException != null) return apiException.message;
    if (error is ApiException) return error.message;
    return AppStrings.examLoadError;
  }

  @override
  Widget build(BuildContext context) {
    final template = _template;

    return DiagnosticScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          8,
          AppSizes.padding,
          AppSizes.padding,
        ),
        child: Column(
          children: [
            Text(
              AppStrings.diagnosticTitle,
              style: AppTextStyles.diagnosticHeroTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(widget.careerName, style: AppTextStyles.diagnosticHeroSubtitle),
            Text(widget.universityName, style: AppTextStyles.diagnosticHeroSubtitle),
            const SizedBox(height: 20),
            Image.asset(AppAssets.mascotExam, height: 160, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              AppStrings.diagnosticDescription,
              style: AppTextStyles.onboardingSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_loading)
              const CircularProgressIndicator(color: AppColors.primary)
            else ...[
              DiagnosticInfoRow(
                icon: Image.asset(AppAssets.iconEvaluations, width: 28, height: 28),
                title: '${template?.questionCount ?? '—'} preguntas',
                subtitle: AppStrings.diagnosticQuestionsSubtitle,
              ),
              const SizedBox(height: 10),
              DiagnosticInfoRow(
                icon: Image.asset(AppAssets.iconCalendar, width: 28, height: 28),
                title: '${template?.durationMinutes ?? '—'} minutos',
                subtitle: AppStrings.diagnosticTimeSubtitle,
              ),
              const SizedBox(height: 10),
              DiagnosticInfoRow(
                icon: Image.asset(AppAssets.iconTopics, width: 28, height: 28),
                title: 'Matemáticas',
                subtitle: 'Área evaluada en este diagnóstico',
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _loading || _starting ? null : _startDiagnosticExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                  ),
                ),
                child: _starting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(AppStrings.diagnosticStartButton, style: AppTextStyles.buttonLight),
              ),
            ),
            const SizedBox(height: 10),
            Text(AppStrings.diagnosticTimerNote, style: AppTextStyles.selectionSubtitle),
          ],
        ),
      ),
    );
  }
}
