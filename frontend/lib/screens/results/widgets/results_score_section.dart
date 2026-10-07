import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/results_model.dart';
import 'results_section_header.dart';

/// Puntaje y desglose (`GET /student-exams/{id}/results`).
class ResultsScoreSection extends StatelessWidget {
  const ResultsScoreSection({super.key, required this.data});

  final StudentExamResult data;

  Color _scoreColor(double score) {
    if (score >= 70) return const Color(0xFF16A34A);
    if (score >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final result = data.result;
    if (result == null) {
      return Text(AppStrings.resultsNoData, style: AppTextStyles.welcome);
    }

    final scoreColor = _scoreColor(result.scorePercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResultsSectionHeader(title: AppStrings.resultsScoreSection),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${result.scorePercent.toStringAsFixed(0)}%',
            style: AppTextStyles.greeting.copyWith(
              fontSize: 48,
              color: scoreColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${AppStrings.resultsCorrectLabel}: '
            '${result.correctAnswers}/${result.totalQuestions}',
            style: AppTextStyles.welcome,
          ),
        ),
        if (data.areas.isNotEmpty) ...[
          const SizedBox(height: 24),
          const ResultsSectionHeader(title: AppStrings.resultsAreasSection),
          const SizedBox(height: 12),
          ...data.areas.map(
            (area) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BreakdownRow(
                label: 'Área ${area.areaId ?? area.id}',
                scorePercent: area.scorePercent,
                detail: '${area.correctAnswers}/${area.totalQuestions}',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.scorePercent,
    required this.detail,
  });

  final String label;
  final double scorePercent;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.cardSubtitle)),
            Text('$detail · ${scorePercent.toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (scorePercent / 100).clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
