import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/saved_answer_model.dart';
import '../exam/widgets/answer_review_detail_sheet.dart';

enum _ReviewFilter { all, correct, incorrect, saved }

/// Revisión completa post-examen (frame 22).
class ExamReviewPage extends ConsumerStatefulWidget {
  const ExamReviewPage({super.key, required this.studentExamId});

  final int studentExamId;

  @override
  ConsumerState<ExamReviewPage> createState() => _ExamReviewPageState();
}

class _ExamReviewPageState extends ConsumerState<ExamReviewPage> {
  _ReviewFilter _filter = _ReviewFilter.all;
  bool _loading = true;
  String? _errorMessage;
  List<SavedAnswerItem> _items = [];

  String get _correctnessParam {
    switch (_filter) {
      case _ReviewFilter.all:
        return 'all';
      case _ReviewFilter.correct:
        return 'correct';
      case _ReviewFilter.incorrect:
        return 'incorrect';
      case _ReviewFilter.saved:
        return 'saved';
    }
  }

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
      final items = await ref.read(examProvider).getExamReview(
            widget.studentExamId,
            correctness: _correctnessParam,
          );
      if (!mounted) return;
      setState(() {
        _items = items;
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
    return AppStrings.examReviewLoadError;
  }

  void _onFilterChanged(_ReviewFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.examReviewTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.examReviewSubtitle, style: AppTextStyles.welcome),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: AppStrings.savedAnswersTabAll,
                      selected: _filter == _ReviewFilter.all,
                      onTap: () => _onFilterChanged(_ReviewFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: AppStrings.savedAnswersTabCorrect,
                      selected: _filter == _ReviewFilter.correct,
                      onTap: () => _onFilterChanged(_ReviewFilter.correct),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: AppStrings.savedAnswersTabIncorrect,
                      selected: _filter == _ReviewFilter.incorrect,
                      onTap: () => _onFilterChanged(_ReviewFilter.incorrect),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: AppStrings.examReviewTabSaved,
                      selected: _filter == _ReviewFilter.saved,
                      onTap: () => _onFilterChanged(_ReviewFilter.saved),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _load, child: const Text(AppStrings.retry)),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          AppStrings.examReviewEmpty,
          style: AppTextStyles.welcome,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _ReviewCard(
          item: item,
          onTap: () => AnswerReviewDetailSheet.show(context, item),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: AppTextStyles.cardSubtitle.copyWith(
              color: selected ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item, required this.onTap});

  final SavedAnswerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = item.isCorrect;
    final icon = isCorrect == true
        ? Icons.check_circle_outline
        : isCorrect == false
            ? Icons.cancel_outlined
            : Icons.help_outline;
    final iconColor = isCorrect == true
        ? const Color(0xFF16A34A)
        : isCorrect == false
            ? const Color(0xFFDC2626)
            : AppColors.textMuted;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayOrder > 0
                          ? 'Pregunta ${item.displayOrder}'
                          : item.areaName ?? 'Pregunta',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.stem,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                  ],
                ),
              ),
              if (item.isSaved)
                const Icon(Icons.bookmark, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
