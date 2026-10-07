import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/unsa_exam_target.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/motivator_fab.dart';
import '../../widgets/topic_theory_sheet.dart';
import 'session_profile_mixin.dart';

class StudyTab extends ConsumerStatefulWidget {
  const StudyTab({super.key});

  @override
  ConsumerState<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends ConsumerState<StudyTab> with SessionProfileMixin {
  Future<void> _openFocusTheory() async {
    final id = focusSubtopicId;
    if (id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.studyTabLearningTheoryError)),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 12),
                Text(AppStrings.studyTabLearningTheoryLoading),
              ],
            ),
          ),
        ),
      ),
    );

    final topic = await ref.read(preparationProvider).getLearnableTopic(id);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (topic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.studyTabLearningTheoryError)),
      );
      return;
    }

    await showTopicTheorySheet(context, topic: topic);
  }

  @override
  Widget build(BuildContext context) {
    final examId = diagnosticStudentExamId ?? lastStudentExamId;
    final showContent = isTopicLearning || (hasStudyProfile && diagnosticCompleted);

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
                        const _StudyHeader(),
                        const SizedBox(height: 8),
                        Text(
                          isTopicLearning
                              ? AppStrings.studyTabLearningSubtitle
                              : AppStrings.studyTabSubtitle,
                          style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                        ),
                        if (isTopicLearning && focusSubtopicName != null) ...[
                          const SizedBox(height: 16),
                          _StatusCard(
                            icon: Icons.menu_book_outlined,
                            iconColor: const Color(0xFF16A34A),
                            iconBg: const Color(0xFFDCFCE7),
                            title: AppStrings.studyTabLearningFocus(focusSubtopicName!),
                            subtitle: AppStrings.studyTabLearningFocusSub,
                            onTap: () => context.go(RoutePaths.onboardingTopic),
                          ),
                          const SizedBox(height: 10),
                          _StatusCard(
                            icon: Icons.auto_stories_outlined,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.chipBg,
                            title: AppStrings.studyTabLearningTheoryTitle,
                            subtitle: AppStrings.studyTabLearningTheorySub,
                            onTap: _openFocusTheory,
                          ),
                        ],
                        if (!isTopicLearning && examTarget != null) ...[
                          const SizedBox(height: 16),
                          _PreparationCard(target: examTarget!),
                        ],
                        const SizedBox(height: 12),
                        if (!hasStudyProfile)
                          _StatusCard(
                            icon: Icons.school_outlined,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.chipBg,
                            title: AppStrings.homeCompleteOnboardingTitle,
                            subtitle: AppStrings.homeCompleteOnboardingSubtitle,
                            highlight: true,
                            onTap: () => context.go(RoutePaths.onboardingPurpose),
                          )
                        else if (!isTopicLearning && !diagnosticCompleted)
                          _StatusCard(
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFFF97316),
                            iconBg: const Color(0xFFFFEDD5),
                            title: AppStrings.studyTabHeroPending,
                            subtitle: AppStrings.studyTabLockedSubtitle,
                            onTap: () => context.go(RoutePaths.homeTab(2)),
                          )
                        else ...[
                          if (!isTopicLearning && examId != null)
                            _PlanCard(
                              onTap: () => context.push(
                                RoutePaths.diagnosticRecommendationsPath(
                                  studentExamId: examId,
                                  careerName: careerName!,
                                  universityName: universityName!,
                                ),
                              ),
                            ),
                          if (isTopicLearning) ...[
                            _StatusCard(
                              icon: Icons.upload_file_outlined,
                              iconColor: AppColors.primary,
                              iconBg: AppColors.chipBg,
                              title: AppStrings.studyMaterialTitle,
                              subtitle: AppStrings.studyTabLearningMaterialSub,
                              onTap: () => context.push(RoutePaths.studyMaterial),
                            ),
                            const SizedBox(height: 10),
                            _StatusCard(
                              icon: Icons.timer_outlined,
                              iconColor: const Color(0xFFF97316),
                              iconBg: const Color(0xFFFFEDD5),
                              title: AppStrings.pomodoroCardTitle,
                              subtitle: AppStrings.pomodoroCardSubtitle,
                              onTap: () => context.push(RoutePaths.pomodoro),
                            ),
                            const SizedBox(height: 10),
                            _StatusCard(
                              icon: Icons.psychology_outlined,
                              iconColor: const Color(0xFF7C3AED),
                              iconBg: const Color(0xFFEDE9FE),
                              title: AppStrings.feynmanCardTitle,
                              subtitle: AppStrings.feynmanCardSubtitle,
                              onTap: () => context.push(RoutePaths.feynman),
                            ),
                          ] else ...[
                          Text(
                            AppStrings.hubSectionResources,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.95,
                            children: [
                              _ResourceCard(
                                asset: AppAssets.iconMaterial,
                                accent: AppColors.primary,
                                accentBg: AppColors.chipBg,
                                title: AppStrings.homeStudyMaterialTitle,
                                subtitle: AppStrings.homeStudyMaterialSubtitle,
                                onTap: () => context.push(RoutePaths.studyMaterial),
                              ),
                              _ResourceCard(
                                asset: AppAssets.iconSavedAnswers,
                                accent: const Color(0xFFF97316),
                                accentBg: const Color(0xFFFFEDD5),
                                title: AppStrings.homeSavedAnswersTitle,
                                subtitle: AppStrings.homeSavedAnswersSubtitle,
                                onTap: () => context.push(RoutePaths.savedAnswers),
                              ),
                              _ResourceCard(
                                asset: AppAssets.iconFlashcard,
                                accent: const Color(0xFF7C3AED),
                                accentBg: const Color(0xFFF3E8FF),
                                title: AppStrings.studyTabFlashcardsTitle,
                                subtitle: AppStrings.studyTabFlashcardsSubtitle,
                                onTap: () {
                                  if (examId == null) return;
                                  context.push(RoutePaths.flashcardsPath(studentExamId: examId));
                                },
                              ),
                              _ResourceCard(
                                asset: AppAssets.iconMaps,
                                accent: AppColors.success,
                                accentBg: AppColors.successLight,
                                title: AppStrings.studyTabMapsTitle,
                                subtitle: AppStrings.studyTabMapsSubtitle,
                                onTap: () {
                                  if (examId == null) return;
                                  context.push(RoutePaths.conceptMapPath(studentExamId: examId));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppStrings.hubSectionTechniques,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          _TechniquesCard(
                            onFeynman: () => context.push(RoutePaths.feynman),
                            onPomodoro: () => context.push(RoutePaths.pomodoro),
                          ),
                        ],
                      ],
                      ],
                    ),
                  ),
                ),
          if (showContent)
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

class _StudyHeader extends StatelessWidget {
  const _StudyHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          AppStrings.studyTabTitle,
          style: AppTextStyles.greeting.copyWith(fontSize: 20),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
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
                  AppStrings.preparationGoalTitle,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  target.label,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeViewPlanTitle,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.homeViewPlanSubtitle,
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? AppColors.chipBg : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlight ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
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
                    Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.asset,
    required this.accent,
    required this.accentBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String asset;
  final Color accent;
  final Color accentBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(asset),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 13, height: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11, height: 1.25),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right_rounded, color: accent, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechniquesCard extends StatelessWidget {
  const _TechniquesCard({
    required this.onFeynman,
    required this.onPomodoro,
  });

  final VoidCallback onFeynman;
  final VoidCallback onPomodoro;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          _TechniqueTile(
            icon: Icons.record_voice_over_outlined,
            iconColor: AppColors.primary,
            iconBg: AppColors.chipBg,
            title: AppStrings.feynmanCardTitle,
            subtitle: AppStrings.feynmanCardSubtitle,
            onTap: onFeynman,
          ),
          const Divider(height: 1, color: AppColors.border),
          _TechniqueTile(
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFFF97316),
            iconBg: const Color(0xFFFFEDD5),
            title: AppStrings.pomodoroCardTitle,
            subtitle: AppStrings.pomodoroCardSubtitle,
            onTap: onPomodoro,
          ),
        ],
      ),
    );
  }
}

class _TechniqueTile extends StatelessWidget {
  const _TechniqueTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
