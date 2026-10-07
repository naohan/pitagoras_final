import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/saved_answer_model.dart';
import '../../study_techniques/widgets/error_learning_sheet.dart';

/// Detalle de pregunta para revisión post-examen (frames 23–24).
class AnswerReviewDetailSheet extends ConsumerWidget {
  const AnswerReviewDetailSheet({super.key, required this.item});

  final SavedAnswerItem item;

  static Future<void> show(BuildContext context, SavedAnswerItem item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AnswerReviewDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = List.of(item.options)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (item.displayOrder > 0)
                Text(
                  'Pregunta ${item.displayOrder}',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (item.isSaved) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bookmark, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(AppStrings.examSavedQuestion, style: AppTextStyles.cardSubtitle),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(item.stem, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 16),
                    ...options.map((option) {
                      final isSelected = option.id == item.selectedOptionId;
                      final isCorrect = option.isCorrect;
                      Color? borderColor;
                      Color? bgColor;
                      if (isSelected && !isCorrect) {
                        borderColor = const Color(0xFFDC2626);
                        bgColor = const Color(0xFFFEE2E2);
                      } else if (isCorrect) {
                        borderColor = const Color(0xFF16A34A);
                        bgColor = const Color(0xFFDCFCE7);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bgColor ?? AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor ?? AppColors.border),
                          ),
                          child: Text(
                            '${option.label}. ${option.text}',
                            style: AppTextStyles.cardSubtitle,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              if (item.isCorrect == false)
                SizedBox(
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ErrorLearningSheet.show(
                        context,
                        questionId: item.questionId,
                        selectedOptionId: item.selectedOptionId,
                      );
                    },
                    icon: const Icon(Icons.psychology_outlined),
                    label: const Text(AppStrings.reviewErrorGuidance),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
