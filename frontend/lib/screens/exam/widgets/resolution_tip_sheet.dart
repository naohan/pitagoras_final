import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/api/interceptors/error_interceptor.dart';
import '../../../data/dto/tutor_dto.dart';
import '../../../data/models/tutor_model.dart';
import 'tutor_sheet.dart';

/// Modal de tip breve (frame 20) — `POST /tutor/hint`.
class ResolutionTipSheet extends ConsumerStatefulWidget {
  const ResolutionTipSheet({
    super.key,
    required this.questionId,
    this.selectedOptionId,
  });

  final int questionId;
  final int? selectedOptionId;

  static Future<void> show(
    BuildContext context, {
    required int questionId,
    int? selectedOptionId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResolutionTipSheet(
        questionId: questionId,
        selectedOptionId: selectedOptionId,
      ),
    );
  }

  @override
  ConsumerState<ResolutionTipSheet> createState() => _ResolutionTipSheetState();
}

class _ResolutionTipSheetState extends ConsumerState<ResolutionTipSheet> {
  TutorExplanation? _hint;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHint());
  }

  Future<void> _loadHint() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final hint = await ref.read(tutorProvider).hint(
            TutorExplainRequestDto(
              questionId: widget.questionId,
              selectedOptionId: widget.selectedOptionId,
            ),
          );
      if (!mounted) return;
      setState(() {
        _hint = hint;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = _resolveError(error);
      });
    }
  }

  String _resolveError(Object error) {
    final apiException = readApiException(error);
    if (apiException != null) return apiException.message;
    if (error is ApiException) return error.message;
    return AppStrings.tipError;
  }

  void _openExtendedTutor() {
    Navigator.of(context).pop();
    TutorSheet.show(
      context,
      questionId: widget.questionId,
      selectedOptionId: widget.selectedOptionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
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
                const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppStrings.tipTitle, style: AppTextStyles.cardTitle),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(child: _buildBody()),
            const SizedBox(height: 16),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _loading ? null : _openExtendedTutor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(AppStrings.tipExtended),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text(AppStrings.tipLoading, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadHint,
            child: const Text(AppStrings.retry),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Text(
        _hint!.explanation,
        style: AppTextStyles.welcome,
      ),
    );
  }
}
