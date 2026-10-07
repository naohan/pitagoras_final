import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/study_activity_model.dart';
import 'session_profile_mixin.dart';

class InicioTab extends ConsumerStatefulWidget {
  const InicioTab({super.key});

  @override
  ConsumerState<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends ConsumerState<InicioTab> with SessionProfileMixin {
  double? _lastScore;
  StreakInfo _streak = StreakInfo.empty;
  double _metaTarget = 72.5;
  String _metaTitle = AppStrings.inicioMetaTitle;

  @override
  Future<void> loadSessionProfile() async {
    await super.loadSessionProfile();
    final examId = scoreExamId;
    if (diagnosticCompleted && examId != null) {
      try {
        final report = await ref.read(diagnosticProvider).getDiagnostic(examId);
        if (mounted) setState(() => _lastScore = report.globalScorePercent);
      } catch (_) {
        // Mantiene UI sin puntaje si falla la carga.
      }
    }
    final streak = await ref.read(studyActivityProvider).getStreak();
    final session = ref.read(sessionManagerProvider);
    var target = await session.getCareerTargetScore();
    var metaTitle = await session.getMetaTitle();
    try {
      final profile = await ref.read(preparationProvider).getProfile();
      if (profile.targetScore != null) {
        target = profile.targetScore;
        await session.saveCareerTargetScore(profile.targetScore);
      }
      if (profile.metaTitle != null && profile.metaTitle!.isNotEmpty) {
        metaTitle = profile.metaTitle;
        await session.saveMetaTitle(profile.metaTitle);
      }
    } catch (_) {
      // Usa valores locales si el perfil aún no está en servidor.
    }
    if (!mounted) return;
    setState(() {
      _streak = streak;
      if (target != null && target > 0) _metaTarget = target;
      _metaTitle = metaTitle?.trim().isNotEmpty == true
          ? metaTitle!
          : AppStrings.inicioMetaTitleFor(
              universityName?.contains('San Agust') == true
                  ? 'UNSA'
                  : universityName,
            );
    });
  }

  String get _initials {
    final name = userName?.trim();
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get _greeting {
    final name = userName?.trim();
    if (name != null && name.isNotEmpty) return '¡Hola, $name!';
    return '¡Hola!';
  }

  void _openRoutine() {
    final examId = diagnosticStudentExamId ?? lastStudentExamId;
    if (examId != null && hasStudyProfile) {
      context.push(
        RoutePaths.diagnosticRecommendationsPath(
          studentExamId: examId,
          careerName: careerName!,
          universityName: universityName!,
        ),
      );
    } else {
      context.go(RoutePaths.homeTab(1));
    }
  }

  void _openWeakTopics() {
    context.go(RoutePaths.homeTab(1));
  }

  void _openSimulacro() {
    if (!hasStudyProfile) {
      context.go(RoutePaths.onboardingPurpose);
    } else {
      context.push(RoutePaths.simulacro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: profileLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InicioHeader(greeting: _greeting, initials: _initials),
                    const SizedBox(height: 16),
                    if (!hasStudyProfile) ...[
                      _SetupCard(
                        onTap: () => context.go(RoutePaths.onboardingPurpose),
                      ),
                      const SizedBox(height: 16),
                    ] else if (isTopicLearning) ...[
                      _LearningFocusCard(
                        topicName: focusSubtopicName ?? careerName ?? 'Tu tema',
                        onTap: () => context.go(RoutePaths.onboardingTopic),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _CareerCard(
                              careerName: careerName!,
                              onTap: () => context.go(RoutePaths.onboardingUniversity),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetaUnsaCard(
                              title: _metaTitle,
                              score: _lastScore,
                              targetScore: _metaTarget,
                              hasDiagnostic: diagnosticCompleted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    _StreakCard(streak: _streak),
                    const SizedBox(height: 16),
                    if (!isTopicLearning)
                      _SimulacroBanner(
                        locked: hasStudyProfile && !diagnosticCompleted,
                        onTap: _openSimulacro,
                      )
                    else
                      _RecommendTile(
                        icon: Icons.menu_book_outlined,
                        iconColor: const Color(0xFF16A34A),
                        iconBg: const Color(0xFFDCFCE7),
                        title: AppStrings.inicioLearningCtaTitle,
                        subtitle: AppStrings.inicioLearningCtaSub,
                        onTap: () => context.go(RoutePaths.homeTab(1)),
                      ),
                    if (!isTopicLearning) const SizedBox(height: 24),
                    if (!isTopicLearning) ...[
                    Text(
                      AppStrings.inicioRecommendTitle,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _RecommendTile(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF22C55E),
                      iconBg: const Color(0xFFDCFCE7),
                      title: AppStrings.inicioRecommendWeak,
                      subtitle: AppStrings.inicioRecommendWeakSub,
                      onTap: _openWeakTopics,
                    ),
                    const SizedBox(height: 10),
                    _RecommendTile(
                      icon: Icons.event_available_outlined,
                      iconColor: const Color(0xFFF97316),
                      iconBg: const Color(0xFFFFEDD5),
                      title: AppStrings.inicioRecommendRoutine,
                      subtitle: AppStrings.inicioRecommendRoutineSub,
                      onTap: _openRoutine,
                    ),
                    const SizedBox(height: 16),
                    ],
                    const _AiTipBanner(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InicioHeader extends StatelessWidget {
  const _InicioHeader({required this.greeting, required this.initials});

  final String greeting;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.asset(
            AppAssets.profileAvatar,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTextStyles.greeting.copyWith(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                AppStrings.inicioGreetingSuffix,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.onTap});

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
          ),
          child: Row(
            children: [
              const Icon(Icons.school_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.inicioSetupCareer,
                  style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.primary),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningFocusCard extends StatelessWidget {
  const _LearningFocusCard({required this.topicName, required this.onTap});

  final String topicName;
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.curriculumOriginCneb,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.studyTabLearningFocus(topicName),
                style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.studyTabLearningFocusSub,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  const _CareerCard({required this.careerName, required this.onTap});

  final String careerName;
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
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.inicioCareerLabel,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                careerName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaUnsaCard extends StatelessWidget {
  const _MetaUnsaCard({
    required this.hasDiagnostic,
    required this.title,
    required this.targetScore,
    this.score,
  });

  final bool hasDiagnostic;
  final String title;
  final double targetScore;
  final double? score;

  @override
  Widget build(BuildContext context) {
    final current = score ?? (hasDiagnostic ? 0.0 : 0.0);
    final ceiling = targetScore <= 0 ? 100.0 : targetScore;
    final progress = (current / ceiling).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: AppTextStyles.greeting.copyWith(
                fontSize: 22,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: current.toStringAsFixed(1)),
                TextSpan(
                  text: ' / ${ceiling.toStringAsFixed(1)}',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hasDiagnostic ? progress : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    final days = streak.currentStreak;
    final mask = streak.weekMask.length == 7
        ? streak.weekMask
        : List<bool>.filled(7, false);

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AppAssets.iconFire, width: 20, height: 20),
              const SizedBox(width: 6),
              Text(
                AppStrings.inicioStudyStreak,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
              ),
              const Spacer(),
              Text(
                AppStrings.inicioStreakDays(days),
                style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done = mask[i];
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: done ? AppColors.success : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SimulacroBanner extends StatelessWidget {
  const _SimulacroBanner({required this.onTap, this.locked = false});

  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 148,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6D28D9).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 12,
                top: 8,
                child: Image.asset(AppAssets.mascotExam, height: 120),
              ),
              Positioned(
                right: 88,
                top: 18,
                child: _FloatingBadge(asset: AppAssets.iconTrophy),
              ),
              Positioned(
                right: 56,
                top: 52,
                child: _FloatingBadge(asset: AppAssets.iconStats),
              ),
              Positioned(
                left: 20,
                top: 24,
                right: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.inicioSimulacroTitle,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      locked
                          ? AppStrings.inicioSimulacroLockedBody
                          : AppStrings.inicioSimulacroBody,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    locked ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
                    color: const Color(0xFF6D28D9),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(asset),
    );
  }
}

class _RecommendTile extends StatelessWidget {
  const _RecommendTile({
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
                    Text(
                      subtitle,
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

class _AiTipBanner extends StatelessWidget {
  const _AiTipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.inicioTipIaTitle,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 14,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.inicioAiTip,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: AppColors.navy,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(AppAssets.mascotIdea, width: 64, height: 64),
        ],
      ),
    );
  }
}
