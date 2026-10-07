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

/// Bottom sheet del tutor IA (`POST /tutor/explain`).
class TutorSheet extends ConsumerStatefulWidget {
  const TutorSheet({
    super.key,
    required this.questionId,
    this.selectedOptionId,
    this.initialStudentMessage,
  });

  final int questionId;
  final int? selectedOptionId;
  final String? initialStudentMessage;

  static Future<void> show(
    BuildContext context, {
    required int questionId,
    int? selectedOptionId,
    String? initialStudentMessage,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TutorSheet(
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        initialStudentMessage: initialStudentMessage,
      ),
    );
  }

  @override
  ConsumerState<TutorSheet> createState() => _TutorSheetState();
}

class _TutorSheetState extends ConsumerState<TutorSheet> {
  final _messageController = TextEditingController();
  TutorExplanation? _explanation;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadExplanation(studentMessage: widget.initialStudentMessage),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadExplanation({String? studentMessage}) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final explanation = await ref.read(tutorProvider).explain(
            TutorExplainRequestDto(
              questionId: widget.questionId,
              selectedOptionId: widget.selectedOptionId,
              studentMessage: studentMessage,
            ),
          );
      if (!mounted) return;
      setState(() {
        _explanation = explanation;
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
    return AppStrings.tutorError;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.tutorTitle,
                      style: AppTextStyles.cardTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(AppStrings.tutorLoading, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Text(_errorMessage!, style: AppTextStyles.welcome, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _loadExplanation(
              studentMessage: _trimmedMessage(),
            ),
            child: const Text(AppStrings.retry),
          ),
        ],
      );
    }

    final explanation = _explanation!;
    final ctx = explanation.academicContext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ContextChip(label: ctx.areaName),
            _ContextChip(label: ctx.componentName),
            _ContextChip(label: ctx.topicName),
            _ContextChip(label: ctx.subtopicName),
          ],
        ),
        const SizedBox(height: 16),
        Text(explanation.explanation, style: AppTextStyles.welcome),
        if (explanation.ragSources.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Fuentes', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          ...explanation.ragSources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                source.text,
                style: AppTextStyles.cardSubtitle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _messageController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: AppStrings.tutorOptionalHint,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: AppSizes.buttonHeight,
          child: OutlinedButton(
            onPressed: () => _loadExplanation(studentMessage: _trimmedMessage()),
            child: const Text('Enviar duda'),
          ),
        ),
      ],
    );
  }

  String? _trimmedMessage() {
    final value = _messageController.text.trim();
    return value.isEmpty ? null : value;
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.cardSubtitle),
    );
  }
}
