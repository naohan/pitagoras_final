import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/models/unsa_exam_target.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Muestra la meta de postulación UNSA elegida en onboarding.
class PreparationGoalBanner extends StatelessWidget {
  const PreparationGoalBanner({
    super.key,
    required this.target,
    this.compact = false,
  });

  final UnsaExamTarget target;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.flag_outlined,
            color: AppColors.primary,
            size: compact ? 18 : 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.preparationGoalTitle,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: compact ? 11 : 12),
                ),
                const SizedBox(height: 2),
                Text(
                  target.label,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: compact ? 14 : 15),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    target.simulacroFocus,
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12, height: 1.35),
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
