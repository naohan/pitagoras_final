import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/preparation_model.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_selection_card.dart';

class PurposePage extends ConsumerWidget {
  const PurposePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingScaffold(
      showBackButton: true,
      onBack: () => context.go(RoutePaths.login),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          8,
          AppSizes.padding,
          AppSizes.padding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingPageTitle(
              title: AppStrings.onboardingPurposeTitle,
              subtitle: AppStrings.onboardingPurposeSubtitle,
            ),
            const SizedBox(height: 20),
            OnboardingSelectionCard(
              title: AppStrings.onboardingPurposeAdmissionTitle,
              subtitle: AppStrings.onboardingPurposeAdmissionBody,
              isSelected: false,
              onTap: () async {
                await ref
                    .read(sessionManagerProvider)
                    .saveStudyPurpose(StudyPurposes.admission);
                if (!context.mounted) return;
                context.go(RoutePaths.onboardingUniversity);
              },
              leading: const CircleAvatar(
                backgroundColor: AppColors.chipBg,
                child: Icon(Icons.school_outlined, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            OnboardingSelectionCard(
              title: AppStrings.onboardingPurposeLearningTitle,
              subtitle: AppStrings.onboardingPurposeLearningBody,
              isSelected: false,
              onTap: () async {
                await ref
                    .read(sessionManagerProvider)
                    .saveStudyPurpose(StudyPurposes.topicLearning);
                if (!context.mounted) return;
                context.go(RoutePaths.onboardingTopic);
              },
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.menu_book_outlined, color: Color(0xFF16A34A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
