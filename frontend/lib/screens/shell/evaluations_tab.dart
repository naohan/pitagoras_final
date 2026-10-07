import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/unsa_exam_target.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/motivator_fab.dart';
import 'session_profile_mixin.dart';

class EvaluationsTab extends ConsumerStatefulWidget {
  const EvaluationsTab({super.key});

  @override
  ConsumerState<EvaluationsTab> createState() => _EvaluationsTabState();
}

class _EvaluationsTabState extends ConsumerState<EvaluationsTab>
    with SessionProfileMixin {
  @override
  Widget build(BuildContext context) {
    final examId = diagnosticStudentExamId ?? lastStudentExamId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          profileLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.evaluationsTabTitle,
                                    style: AppTextStyles.greeting.copyWith(fontSize: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.evaluationsTabSubtitle,
                                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const _SearchButton(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!hasStudyProfile)
                          _EvalCard(
                            icon: Icons.school_outlined,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.chipBg,
                            accent: AppColors.primary,
                            title: AppStrings.homeCompleteOnboardingTitle,
                            subtitle: AppStrings.homeCompleteOnboardingSubtitle,
                            onTap: () => context.go(RoutePaths.onboardingUniversity),
                          )
                        else ...[
                          if (examTarget != null) ...[
                            _PreparationCard(target: examTarget!),
                            const SizedBox(height: 10),
                          ],
                          _PracticeBannerCard(
                            hasStudyProfile: true,
                            diagnosticCompleted: diagnosticCompleted,
                            examTarget: examTarget,
                          ),
                          const SizedBox(height: 10),
                          if (diagnosticCompleted)
                            _EvalCard(
                              icon: Icons.quiz_outlined,
                              iconColor: AppColors.primary,
                              iconBg: AppColors.chipBg,
                              accent: AppColors.primary,
                              title: examTarget != null
                                  ? AppStrings.preparationSimulacroTitle(examTarget!.label)
                                  : AppStrings.homePracticeSimulacroTitle,
                              subtitle: examTarget != null
                                  ? AppStrings.preparationSimulacroSubtitle(examTarget!.label)
                                  : AppStrings.evaluationsTabSimulacroSubtitle,
                              outlined: true,
                              onTap: () => context.push(RoutePaths.simulacro),
                            )
                          else
                            _EvalCard(
                              icon: Icons.play_circle_outline,
                              iconColor: AppColors.primary,
                              iconBg: AppColors.chipBg,
                              accent: AppColors.primary,
                              title: AppStrings.homeContinueDiagnosticTitle,
                              subtitle: AppStrings.studyTabLockedSubtitle,
                              outlined: true,
                              onTap: () => context.push(
                                RoutePaths.diagnosticPath(
                                  careerName: careerName!,
                                  universityName: universityName!,
                                ),
                              ),
                            ),
                          if (diagnosticCompleted) ...[
                            const SizedBox(height: 10),
                            _EvalCard(
                              icon: Icons.fact_check_outlined,
                              iconColor: AppColors.success,
                              iconBg: AppColors.successLight,
                              accent: AppColors.success,
                              title: AppStrings.homeRepeatDiagnosticTitle,
                              subtitle: AppStrings.homeRepeatDiagnosticSubtitle,
                              onTap: () {
                                if (examId == null) return;
                                context.push(
                                  RoutePaths.diagnosticResultPath(
                                    studentExamId: examId,
                                    careerName: careerName!,
                                    universityName: universityName!,
                                  ),
                                );
                              },
                            ),
                          ],
                          if (diagnosticCompleted && lastStudentExamId != null) ...[
                            const SizedBox(height: 10),
                            _EvalCard(
                              icon: Icons.insights_outlined,
                              iconColor: const Color(0xFF7C3AED),
                              iconBg: const Color(0xFFF3E8FF),
                              accent: const Color(0xFF7C3AED),
                              title: AppStrings.homeViewResultsTitle,
                              subtitle: AppStrings.homeViewResultsSubtitle,
                              onTap: () => context.push(
                                RoutePaths.resultsSession(lastStudentExamId!),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _EvalCard(
                              icon: Icons.rate_review_outlined,
                              iconColor: const Color(0xFFF97316),
                              iconBg: const Color(0xFFFFEDD5),
                              accent: const Color(0xFFF97316),
                              title: AppStrings.evaluationsTabReviewTitle,
                              subtitle: AppStrings.evaluationsTabReviewSubtitle,
                              onTap: () => context.push(
                                RoutePaths.examReviewSession(lastStudentExamId!),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
          if (hasStudyProfile)
            Positioned(
              right: 16,
              bottom: 16,
              child: MotivatorFab(
                onTap: () => context.push(RoutePaths.motivator),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.search_rounded, color: Color(0xFF7C3AED), size: 22),
        ),
      ),
    );
  }
}

class _PreparationCard extends StatelessWidget {
  const _PreparationCard({required this.target});

  final UnsaExamTarget target;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flag_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.preparationGoalTitle.toUpperCase(),
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  target.label,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15, height: 1.2),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _PracticeBannerCard extends StatelessWidget {
  const _PracticeBannerCard({
    required this.hasStudyProfile,
    required this.diagnosticCompleted,
    this.examTarget,
  });

  final bool hasStudyProfile;
  final bool diagnosticCompleted;
  final UnsaExamTarget? examTarget;

  @override
  Widget build(BuildContext context) {
    final body = !hasStudyProfile
        ? AppStrings.evaluationsTabBannerSetup
        : diagnosticCompleted
            ? (examTarget?.simulacroFocus ?? AppStrings.evaluationsTabBannerBody)
            : AppStrings.studyTabLockedSubtitle;

    final title = hasStudyProfile
        ? (diagnosticCompleted
            ? AppStrings.evaluationsTabBannerTitle
            : AppStrings.studyTabHeroPending)
        : AppStrings.evaluationsTabBannerSetup;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF7C3AED),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                child: Row(
                  children: [
                    Image.asset(AppAssets.mascotExam, width: 56, height: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 14, height: 1.2),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12, height: 1.25),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvalCard extends StatelessWidget {
  const _EvalCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: outlined ? accent : AppColors.border,
              width: outlined ? 1.5 : 1,
            ),
            boxShadow: outlined
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!outlined)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(outlined ? 14 : 12, 14, 14, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.cardTitle.copyWith(fontSize: 14, height: 1.2),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12, height: 1.25),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: accent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
