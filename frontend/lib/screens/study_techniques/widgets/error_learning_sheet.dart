import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/api/interceptors/error_interceptor.dart';
import '../../../data/dto/study_techniques_dto.dart';

/// Aprendizaje por errores — sin mostrar la respuesta correcta de inmediato.
class ErrorLearningSheet extends ConsumerStatefulWidget {
  const ErrorLearningSheet({
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
      builder: (_) => ErrorLearningSheet(
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        onRetry: onRetry,
      ),
    );
  }

  @override
  ConsumerState<ErrorLearningSheet> createState() => _ErrorLearningSheetState();
}

class _ErrorLearningSheetState extends ConsumerState<ErrorLearningSheet> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
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
                const Icon(Icons.psychology_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.errorLearningTitle,
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
            Flexible(child: _buildBody()),
            if (_guidance?.allowRetry == true && widget.onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onRetry?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(AppStrings.errorLearningRetry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMessage != null) {
      return Text(_errorMessage!, textAlign: TextAlign.center);
    }
    final g = _guidance!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            title: AppStrings.errorLearningStep,
            body: g.errorStep,
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 12),
          _Section(
            title: AppStrings.errorLearningConcept,
            body: '${g.conceptName}\n${g.conceptReminder}',
            icon: Icons.menu_book_outlined,
          ),
          if (g.similarQuestionStem != null) ...[
            const SizedBox(height: 12),
            _Section(
              title: AppStrings.errorLearningSimilar,
              body: g.similarQuestionStem!,
              icon: Icons.fitness_center_outlined,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            AppStrings.errorLearningNoAnswer,
            style: AppTextStyles.cardSubtitle.copyWith(
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.aiCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.welcome),
        ],
      ),
    );
  }
}
