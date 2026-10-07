import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/unsa_exam_target.dart';
import '../../core/services/career_id_resolver.dart';
import '../../core/services/study_flow_helper.dart';
import '../../core/services/exam_template_not_found.dart';
import '../../core/services/exam_template_resolver.dart';
import '../../widgets/preparation_goal_banner.dart';
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

enum _SimulacroPageStatus { loading, loaded, error, starting }

class SimulacroPage extends ConsumerStatefulWidget {
  const SimulacroPage({super.key});

  @override
  ConsumerState<SimulacroPage> createState() => _SimulacroPageState();
}

class _SimulacroPageState extends ConsumerState<SimulacroPage> {
  _SimulacroPageStatus _status = _SimulacroPageStatus.loading;
  ExamTemplate? _template;
  String? _userName;
  String? _errorMessage;
  bool _useAdaptive = false;
  int? _diagnosticExamId;
  bool _diagnosticCompleted = false;
  String? _careerName;
  String? _universityName;
  UnsaExamTarget? _examTarget;
  static const int _adaptiveQuestionCount = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTemplate());
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _status = _SimulacroPageStatus.loading;
      _errorMessage = null;
    });

    try {
      final session = ref.read(sessionManagerProvider);
      _userName = await session.getUserFullName();
      _careerName = await session.getCareerName();
      _universityName = await session.getUniversityName();
      _examTarget = await session.getUnsaExamTarget();
      if (_examTarget == null && UnsaExamTarget.isUnsaUniversity(_universityName)) {
        _examTarget = UnsaExamTarget.ordinario;
      }
      _diagnosticCompleted = await resolveDiagnosticCompleted(ref);
      final diagnosticExamId = await session.getDiagnosticStudentExamId();
      var resolvedDiagnosticExamId = diagnosticExamId;
      resolvedDiagnosticExamId ??= await session.getStudentExamId();

      final careerId = await CareerIdResolver.ensure(
        session: session,
        catalog: ref.read(catalogProvider),
        preparation: ref.read(preparationProvider),
      );
      ExamTemplate? ordinarioTemplate;
      if (careerId != null) {
        final templates =
            await ref.read(examProvider).listExamTemplatesForCareer(careerId);
        for (final template in templates) {
          if (template.name.toLowerCase().contains('ordinario')) {
            ordinarioTemplate = template;
            break;
          }
        }
      }

      if (ordinarioTemplate != null) {
        _useAdaptive = false;
        _diagnosticExamId = resolvedDiagnosticExamId;
        _template = ordinarioTemplate;
        if (!mounted) return;
        setState(() => _status = _SimulacroPageStatus.loaded);
        return;
      }

      _useAdaptive = _diagnosticCompleted && resolvedDiagnosticExamId != null;
      _diagnosticExamId = resolvedDiagnosticExamId;

      if (_useAdaptive) {
        if (!mounted) return;
        setState(() => _status = _SimulacroPageStatus.loaded);
        return;
      }

      final template = await ExamTemplateResolver.resolveTemplate(
        session,
        ref.read(examProvider),
        catalog: ref.read(catalogProvider),
        preparation: ref.read(preparationProvider),
      );

      if (!mounted) return;
      setState(() {
        _template = template;
        _status = _SimulacroPageStatus.loaded;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _SimulacroPageStatus.error;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  Future<void> _startExam() async {
    if (_status == _SimulacroPageStatus.starting) return;
    if (!_diagnosticCompleted) return;
    if (!_useAdaptive && _template == null) return;

    final studentId = await ref.read(sessionManagerProvider).getStudentId();
    if (studentId == null) {
      setState(() => _errorMessage = AppStrings.simulacroNoStudent);
      return;
    }

    setState(() {
      _status = _SimulacroPageStatus.starting;
      _errorMessage = null;
    });

    try {
      final StudentExam studentExam;
      if (_useAdaptive && _diagnosticExamId != null) {
        studentExam = await ref.read(examProvider).startAdaptiveStudentExam(
              StartAdaptiveStudentExamRequestDto(
                studentId: studentId,
                basedOnStudentExamId: _diagnosticExamId!,
                questionCount: _adaptiveQuestionCount,
              ),
            );
      } else {
        studentExam = await ref.read(examProvider).startStudentExam(
              StartStudentExamRequestDto(
                studentId: studentId,
                examTemplateId: _template!.id,
              ),
            );
      }

      await ref.read(sessionManagerProvider).saveStudentExamId(studentExam.id);

      if (!mounted) return;
      context.go(RoutePaths.examSession(studentExam.id));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _SimulacroPageStatus.loaded;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  String _resolveErrorMessage(Object error) {
    if (error is ExamTemplateNotFoundException) return error.message;
    final apiException = readApiException(error);
    if (apiException != null) {
      if (apiException.code == 'insufficient_questions' ||
          apiException.message.contains('insufficient_questions') ||
          apiException.message.contains('Not enough questions')) {
        return AppStrings.simulacroInsufficientBank;
      }
      return apiException.message;
    }
    if (error is ApiException) return error.message;
    return AppStrings.simulacroLoadError;
  }

  Future<void> _logout(BuildContext context) async {
    await ref.read(authProvider).logout();
    if (context.mounted) {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStarting = _status == _SimulacroPageStatus.starting;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.simulacroTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutePaths.home),
        ),
        actions: [
          TextButton(
            onPressed: isStarting ? null : () => _logout(context),
            child: Text(
              AppStrings.logout,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: _buildBody(isStarting),
        ),
      ),
    );
  }

  Widget _buildBody(bool isStarting) {
    if (_status == _SimulacroPageStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_status == _SimulacroPageStatus.error && _template == null && !_useAdaptive) {
      return _ErrorView(
        message: _errorMessage ?? AppStrings.simulacroLoadError,
        onRetry: _loadTemplate,
        onReselectCareer: () => context.go(RoutePaths.onboardingUniversity),
      );
    }

    final greetingName = _userName?.trim();
    final greeting = greetingName != null && greetingName.isNotEmpty
        ? '${AppStrings.simulacroGreeting}, $greetingName'
        : AppStrings.simulacroGreeting;

    final subtitle = _examTarget != null
        ? _examTarget!.simulacroFocus
        : _template != null && _template!.name.toLowerCase().contains('ordinario')
            ? AppStrings.simulacroOrdinarioSubtitle
            : _useAdaptive
                ? AppStrings.simulacroAdaptiveSubtitle
                : AppStrings.simulacroSubtitle;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical -
              kToolbarHeight -
              32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(greeting, style: AppTextStyles.greeting),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.welcome),
            if (_examTarget != null) ...[
              const SizedBox(height: 16),
              PreparationGoalBanner(target: _examTarget!),
            ],
            if (!_diagnosticCompleted) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.simulacroRequiresDiagnostic,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.warningText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: AppSizes.buttonHeight - 8,
                      child: ElevatedButton(
                        onPressed: _careerName != null && _universityName != null
                            ? () => context.push(
                                  RoutePaths.diagnosticPath(
                                    careerName: _careerName!,
                                    universityName: _universityName!,
                                  ),
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(AppStrings.simulacroGoDiagnostic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _useAdaptive
                ? _SimulacroCard(
                    name: _examTarget != null
                        ? '${AppStrings.simulacroAdaptiveName} · ${_examTarget!.shortLabel}'
                        : AppStrings.simulacroAdaptiveName,
                    durationMinutes: _adaptiveQuestionCount * 2,
                    questionCount: _adaptiveQuestionCount,
                  )
                : _SimulacroCard(
                    name: _examTarget != null
                        ? '${_template!.name} · ${_examTarget!.shortLabel}'
                        : _template!.name,
                    durationMinutes: _template!.durationMinutes,
                    questionCount: _template!.questionCount,
                  ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: const Color(0xFFDC2626),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: isStarting || !_diagnosticCompleted ? null : _startExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                  ),
                ),
                child: isStarting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isStarting
                            ? AppStrings.startingSimulacro
                            : AppStrings.startSimulacro,
                        style: AppTextStyles.buttonLight,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulacroCard extends StatelessWidget {
  const _SimulacroCard({
    required this.name,
    required this.durationMinutes,
    required this.questionCount,
  });

  final String name;
  final int durationMinutes;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142F6BEE),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTextStyles.cardTitle),
          const SizedBox(height: 20),
          _InfoChip(
            icon: Icons.schedule_outlined,
            label:
                '${AppStrings.simulacroDuration}: $durationMinutes ${AppStrings.simulacroMinutes}',
          ),
          const SizedBox(height: 12),
          _InfoChip(
            icon: Icons.quiz_outlined,
            label: '${AppStrings.simulacroQuestions}: $questionCount',
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppTextStyles.cardSubtitle),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.onReselectCareer,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onReselectCareer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.welcome,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text(AppStrings.retry),
          ),
          if (onReselectCareer != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onReselectCareer,
              child: const Text('Elegir carrera de nuevo'),
            ),
          ],
        ],
      ),
    );
  }
}
