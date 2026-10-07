import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/preparation_goal_banner.dart';
import 'session_profile_mixin.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> with SessionProfileMixin {
  Future<void> _logout() async {
    await ref.read(authProvider).logout();
    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  String get _initials {
    final name = userName?.trim();
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
        automaticallyImplyLeading: false,
      ),
      body: profileLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      initials: _initials,
                      name: userName ?? AppStrings.profileTabGuest,
                      career: careerName,
                      university: universityName,
                    ),
                    const SizedBox(height: 24),
                    _ProfileInfoTile(
                      icon: Icons.assignment_turned_in_outlined,
                      label: AppStrings.profileTabDiagnosticStatus,
                      value: diagnosticCompleted
                          ? AppStrings.profileTabDiagnosticDone
                          : AppStrings.profileTabDiagnosticPending,
                      valueColor: diagnosticCompleted
                          ? AppColors.success
                          : AppColors.progressOrange,
                    ),
                    if (hasStudyProfile) ...[
                      _ProfileInfoTile(
                        icon: Icons.school_outlined,
                        label: AppStrings.profileTabCareer,
                        value: careerName!,
                      ),
                      _ProfileInfoTile(
                        icon: Icons.account_balance_outlined,
                        label: AppStrings.profileTabUniversity,
                        value: universityName!,
                      ),
                      if (isUnsaStudent)
                        _ProfileInfoTile(
                          icon: Icons.flag_outlined,
                          label: AppStrings.profileTabExamTarget,
                          value: examTarget?.label ?? AppStrings.profileTabExamTargetUnset,
                        ),
                    ],
                    if (examTarget != null) ...[
                      const SizedBox(height: 12),
                      PreparationGoalBanner(target: examTarget!, compact: true),
                    ],
                    const SizedBox(height: 24),
                    if (isUnsaStudent && hasStudyProfile)
                      SizedBox(
                        height: AppSizes.buttonHeight,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            RoutePaths.onboardingExamTargetPath(
                              universityId: '1',
                              universityName: universityName!,
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.profileTabEditExamTarget),
                        ),
                      ),
                    if (isUnsaStudent && hasStudyProfile) const SizedBox(height: 12),
                    SizedBox(
                      height: AppSizes.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: hasStudyProfile
                            ? () => context.go(RoutePaths.onboardingUniversity)
                            : null,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(AppStrings.profileTabEditCareer),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(AppStrings.logout),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(AppAssets.mascotPose1, width: 120, height: 120),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    this.career,
    this.university,
  });

  final String initials;
  final String name;
  final String? career;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.cardTitle),
                if (career != null && university != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$career · $university',
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.diagnosticCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.selectionSubtitle),
                Text(
                  value,
                  style: AppTextStyles.selectionTitle.copyWith(
                    color: valueColor ?? AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
