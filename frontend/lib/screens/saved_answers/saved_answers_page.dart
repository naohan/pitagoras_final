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

enum _SavedFilter { all, correct, incorrect }

class SavedAnswersPage extends ConsumerStatefulWidget {
  const SavedAnswersPage({super.key});

  @override
  ConsumerState<SavedAnswersPage> createState() => _SavedAnswersPageState();
}

class _SavedAnswersPageState extends ConsumerState<SavedAnswersPage> {
  _SavedFilter _filter = _SavedFilter.all;
  bool _loading = true;
  String? _errorMessage;
  List<SavedAnswerItem> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String get _correctnessParam {
    switch (_filter) {
      case _SavedFilter.all:
        return 'all';
      case _SavedFilter.correct:
        return 'correct';
      case _SavedFilter.incorrect:
        return 'incorrect';
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final studentId = await ref.read(sessionManagerProvider).getStudentId();
      if (studentId == null) {
        throw StateError(AppStrings.simulacroNoStudent);
      }

      final items = await ref.read(examProvider).listSavedAnswers(
            studentId,
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
    return AppStrings.resultsLoadError;
  }

  void _onFilterChanged(_SavedFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    _load();
  }

  void _openDetail(SavedAnswerItem item) {
    AnswerReviewDetailSheet.show(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.savedAnswersTitle),
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
              Text(AppStrings.savedAnswersSubtitle, style: AppTextStyles.welcome),
              const SizedBox(height: 16),
              _FilterTabs(
                selected: _filter,
                onChanged: _onFilterChanged,
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
          AppStrings.savedAnswersEmpty,
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
        return _SavedAnswerCard(item: item, onTap: () => _openDetail(item));
      },
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final _SavedFilter selected;
  final ValueChanged<_SavedFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabChip(
          label: AppStrings.savedAnswersTabAll,
          selected: selected == _SavedFilter.all,
          onTap: () => onChanged(_SavedFilter.all),
        ),
        const SizedBox(width: 8),
        _TabChip(
          label: AppStrings.savedAnswersTabCorrect,
          selected: selected == _SavedFilter.correct,
          onTap: () => onChanged(_SavedFilter.correct),
        ),
        const SizedBox(width: 8),
        _TabChip(
          label: AppStrings.savedAnswersTabIncorrect,
          selected: selected == _SavedFilter.incorrect,
          onTap: () => onChanged(_SavedFilter.incorrect),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: selected ? Colors.white : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedAnswerCard extends StatelessWidget {
  const _SavedAnswerCard({required this.item, required this.onTap});

  final SavedAnswerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = item.isCorrect;
    final statusLabel = isCorrect == true
        ? AppStrings.savedAnswersCorrect
        : isCorrect == false
            ? AppStrings.savedAnswersIncorrect
            : 'Sin responder';
    final statusColor = isCorrect == true
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.areaName != null)
                      Text(
                        item.areaName!,
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: AppColors.primary,
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
                    const SizedBox(height: 6),
                    Text(
                      statusLabel,
                      style: AppTextStyles.cardSubtitle.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bookmark, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
