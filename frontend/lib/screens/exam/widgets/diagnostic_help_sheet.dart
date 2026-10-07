import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/api/interceptors/error_interceptor.dart';
import '../../../data/dto/study_techniques_dto.dart';
import '../../study_techniques/widgets/error_learning_sheet.dart';
import 'diagnostic_tip_sheet.dart';
import 'tutor_sheet.dart';

/// Ayuda en diagnóstico: pista breve o repaso/bases según datos disponibles.
class DiagnosticHelpSheet extends ConsumerStatefulWidget {
  const DiagnosticHelpSheet({
    super.key,
    required this.questionId,
    this.selectedOptionId,
    this.onRetry,
  });

  final int questionId;
  final int? selectedOptionId;
  final VoidCallback? onRetry;

  static Future<void> show(
    BuildContext context, {
    required int questionId,
    int? selectedOptionId,
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DiagnosticHelpSheet(
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        onRetry: onRetry,
      ),
    );
  }

  @override
  ConsumerState<DiagnosticHelpSheet> createState() => _DiagnosticHelpSheetState();
}

class _DiagnosticHelpSheetState extends ConsumerState<DiagnosticHelpSheet> {
  ErrorGuidanceDto? _guidance;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final guidance = await ref.read(studyTechniquesProvider).getErrorGuidance(
            widget.questionId,
            selectedOptionId: widget.selectedOptionId,
          );
      if (!mounted) return;
      setState(() {
        _guidance = guidance;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = readApiException(error)?.message ?? error.toString();
      });
    }
  }

  void _openTip() {
    final guidance = _guidance;
    if (guidance == null) return;
    Navigator.of(context).pop();
    DiagnosticTipSheet.show(context, guidance: guidance);
  }

  void _openSecondary() {
    final guidance = _guidance;
    if (guidance == null) return;
    Navigator.of(context).pop();

    if (guidance.hasRichData) {
      ErrorLearningSheet.show(
        context,
        questionId: widget.questionId,
        selectedOptionId: widget.selectedOptionId,
        onRetry: widget.onRetry,
      );
      return;
    }

    TutorSheet.show(
      context,
      questionId: widget.questionId,
      selectedOptionId: widget.selectedOptionId,
      initialStudentMessage:
          'Estoy en el examen de diagnóstico y aún no hay ejercicios similares '
          'en el banco. Consulta mis bases de conocimiento indexadas y explícame '
          'el concepto sin revelar la letra de la respuesta correcta.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final guidance = _guidance;
    final hasRichData = guidance?.hasRichData ?? false;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
            Row(
              children: [
                const Icon(Icons.help_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.diagnosticHelpTitle,
                    style: AppTextStyles.cardTitle,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.diagnosticHelpSubtitle,
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_errorMessage != null) ...[
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _load,
                child: const Text(AppStrings.retry),
              ),
            ] else ...[
              SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _openTip,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text(AppStrings.diagnosticHelpTip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: AppSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _openSecondary,
                  icon: Icon(
                    hasRichData ? Icons.menu_book_outlined : Icons.auto_stories_outlined,
                    size: 18,
                  ),
                  label: Text(
                    hasRichData
                        ? AppStrings.diagnosticHelpConcept
                        : AppStrings.diagnosticHelpBases,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              if (!hasRichData) ...[
                const SizedBox(height: 10),
                Text(
                  AppStrings.diagnosticHelpBasesHint,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
