import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/results_model.dart';
import 'results_section_header.dart';

/// Plan de estudio (`GET /recommendations/student-exams/{id}`).
class ResultsStudyPlanSection extends StatelessWidget {
  const ResultsStudyPlanSection({super.key, required this.plan});

  final StudyPlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResultsSectionHeader(title: AppStrings.resultsStudyPlanSection),
        const SizedBox(height: 12),
        Text(
          '${AppStrings.resultsEstimatedDays}: ${plan.estimatedDays}',
          style: AppTextStyles.welcome,
        ),
        if (plan.focusSubtopics.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(AppStrings.resultsFocusSubtopics, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          ...plan.focusSubtopics.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $topic', style: AppTextStyles.welcome),
            ),
          ),
        ],
        if (plan.recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...plan.recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bubble,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.entityName, style: AppTextStyles.cardSubtitle),
                    const SizedBox(height: 4),
                    Text(rec.message, style: AppTextStyles.welcome),
                    const SizedBox(height: 4),
                    Text(
                      '${rec.resourceType} · ${rec.scorePercent.toStringAsFixed(0)}%',
                      style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
