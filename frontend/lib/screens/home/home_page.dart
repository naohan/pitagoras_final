import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Hub principal tras el diagnóstico: plan, simulacro y perfil.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _userName;
  String? _careerName;
  String? _universityName;
  int? _lastStudentExamId;
  bool _diagnosticCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final session = ref.read(sessionManagerProvider);
    final userName = await session.getUserFullName();
    final careerName = await session.getCareerName();
    final universityName = await session.getUniversityName();
    final lastExamId = await session.getStudentExamId();
    final diagnosticCompleted = await session.isDiagnosticCompleted();

    if (!mounted) return;
    setState(() {
      _userName = userName;
      _careerName = careerName;
      _universityName = universityName;
      _lastStudentExamId = lastExamId;
      _diagnosticCompleted = diagnosticCompleted;
    });
  }

  Future<void> _logout() async {
    await ref.read(authProvider).logout();
    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  bool get _hasStudyProfile =>
      _careerName != null &&
      _careerName!.isNotEmpty &&
      _universityName != null &&
      _universityName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final greetingName = _userName?.trim();
    final greeting = greetingName != null && greetingName.isNotEmpty
        ? '${AppStrings.homeGreeting}, $greetingName'
        : AppStrings.homeGreeting;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _logout,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(greeting, style: AppTextStyles.greeting),
              const SizedBox(height: 8),
              Text(AppStrings.homeSubtitle, style: AppTextStyles.welcome),
              if (!_diagnosticCompleted && _hasStudyProfile) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.homeFlowHint,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              if (_hasStudyProfile) ...[
                const SizedBox(height: 8),
                Text(
                  '${_careerName!} · ${_universityName!}',
                  style: AppTextStyles.cardSubtitle,
                ),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    if (!_hasStudyProfile)
                      _HomeActionCard(
                        icon: Icons.school_outlined,
                        title: AppStrings.homeCompleteOnboardingTitle,
                        subtitle: AppStrings.homeCompleteOnboardingSubtitle,
                        onTap: () => context.go(RoutePaths.onboardingUniversity),
                      )
                    else ...[
                      if (!_diagnosticCompleted)
                        _HomeActionCard(
                          icon: Icons.play_circle_outline,
                          title: AppStrings.homeContinueDiagnosticTitle,
                          subtitle: AppStrings.homeContinueDiagnosticSubtitle,
                          highlight: true,
                          onTap: () => context.push(
                            RoutePaths.diagnosticPath(
                              careerName: _careerName!,
                              universityName: _universityName!,
                            ),
                          ),
                        ),
                      if (_diagnosticCompleted && _lastStudentExamId != null)
                        _HomeActionCard(
                          icon: Icons.auto_awesome,
                          title: AppStrings.homeViewPlanTitle,
                          subtitle: AppStrings.homeViewPlanSubtitle,
                          onTap: () => context.push(
                            RoutePaths.diagnosticRecommendationsPath(
                              studentExamId: _lastStudentExamId!,
                              careerName: _careerName!,
                              universityName: _universityName!,
                            ),
                          ),
                        ),
                      if (_diagnosticCompleted && _lastStudentExamId != null)
                        _HomeActionCard(
                          icon: Icons.insights_outlined,
                          title: AppStrings.homeViewResultsTitle,
                          subtitle: AppStrings.homeViewResultsSubtitle,
                          onTap: () => context.push(
                            RoutePaths.resultsSession(_lastStudentExamId!),
                          ),
                        ),
                      if (_diagnosticCompleted)
                        _HomeActionCard(
                          icon: Icons.upload_file_outlined,
                          title: AppStrings.homeStudyMaterialTitle,
                          subtitle: AppStrings.homeStudyMaterialSubtitle,
                          onTap: () => context.push(RoutePaths.studyMaterial),
                        ),
                      if (_diagnosticCompleted)
                        _HomeActionCard(
                          icon: Icons.bookmark_outline,
                          title: AppStrings.homeSavedAnswersTitle,
                          subtitle: AppStrings.homeSavedAnswersSubtitle,
                          onTap: () => context.push(RoutePaths.savedAnswers),
                        ),
                      if (_diagnosticCompleted)
                        _HomeActionCard(
                          icon: Icons.quiz_outlined,
                          title: AppStrings.homePracticeSimulacroTitle,
                          subtitle: AppStrings.homePracticeSimulacroSubtitle,
                          onTap: () => context.push(RoutePaths.simulacro),
                        ),
                      if (_diagnosticCompleted && _lastStudentExamId != null)
                        _HomeActionCard(
                          icon: Icons.fact_check_outlined,
                          title: AppStrings.homeRepeatDiagnosticTitle,
                          subtitle: AppStrings.homeRepeatDiagnosticSubtitle,
                          onTap: () => context.push(
                            RoutePaths.diagnosticResultPath(
                              studentExamId: _lastStudentExamId!,
                              careerName: _careerName!,
                              universityName: _universityName!,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: highlight ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusCard),
              border: Border.all(
                color: highlight ? AppColors.primary : AppColors.border,
                width: highlight ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(subtitle, style: AppTextStyles.cardSubtitle),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
