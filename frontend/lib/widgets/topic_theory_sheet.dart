import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/preparation_model.dart';
import '../../screens/onboarding/widgets/theory_content.dart';

/// Abre la hoja modal con la teoría detallada de un tema.
Future<void> showTopicTheorySheet(
  BuildContext context, {
  required LearnableTopic topic,
  String? primaryLabel,
  VoidCallback? onPrimary,
}) {
  final body = topic.theoryText
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('# '))
      .join('\n')
      .trim();
  final theory =
      body.isEmpty ? AppStrings.onboardingTopicTheoryEmpty : body;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final height = MediaQuery.sizeOf(ctx).height * 0.88;
      return SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.subtopicName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (topic.areaName.isNotEmpty) topic.areaName,
                            if (topic.courseName.isNotEmpty) topic.courseName,
                          ].join(' · '),
                          style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: TheoryContent(text: theory),
              ),
            ),
            if (primaryLabel != null && onPrimary != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: AppSizes.buttonHeight,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onPrimary();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      primaryLabel,
                      style: AppTextStyles.buttonLight,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: AppSizes.buttonHeight,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      AppStrings.onboardingTopicTheoryClose,
                      style: AppTextStyles.buttonDark.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
