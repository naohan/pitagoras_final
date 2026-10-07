import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/study_activity_model.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/study_tools_model.dart';

class FlashcardsPage extends ConsumerStatefulWidget {
  const FlashcardsPage({super.key, required this.studentExamId});

  final int studentExamId;

  @override
  ConsumerState<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends ConsumerState<FlashcardsPage> {
  bool _loading = true;
  String? _errorMessage;
  List<FlashcardItem> _cards = [];
  int _index = 0;
  bool _showBack = false;

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
      final cards = await ref
          .read(studyToolsProvider)
          .getFlashcards(widget.studentExamId);
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _index = 0;
        _showBack = false;
        _loading = false;
      });
      if (cards.isNotEmpty) {
        await ref.read(studyActivityProvider).recordActivity(
              StudyActivityTypes.flashcards,
              refId: 'flashcards-${widget.studentExamId}',
            );
      }
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
    return error.toString();
  }

  void _goTo(int nextIndex) {
    if (_cards.isEmpty) return;
    setState(() {
      _index = nextIndex.clamp(0, _cards.length - 1);
      _showBack = false;
    });
  }

  String _sourceLabel(String source) {
    if (source == 'wrong_answer') return AppStrings.flashcardsSourceWrong;
    if (source == 'weak_subtopic') return AppStrings.flashcardsSourceWeak;
    return source;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.flashcardsPageTitle),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _load);
    }

    if (_cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Text(
            AppStrings.flashcardsEmpty,
            textAlign: TextAlign.center,
            style: AppTextStyles.welcome,
          ),
        ),
      );
    }

    final card = _cards[_index];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(card.subtopicName),
                  backgroundColor: AppColors.chipBg,
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_sourceLabel(card.source)),
                  backgroundColor: AppColors.aiCardBg,
                  labelStyle: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                ),
                const Spacer(),
                Text(
                  '${_index + 1}/${_cards.length}',
                  style: AppTextStyles.cardSubtitle,
                ),
              ],
            ),
            if (card.curriculumOrigins.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: card.curriculumOrigins
                    .map(
                      (origin) => Chip(
                        label: Text(origin),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: const Color(0xFFEEF2FF),
                        labelStyle: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF4338CA),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _FlashcardFace(
                    key: ValueKey('$_index-$_showBack'),
                    title: _showBack ? 'Respuesta' : 'Pregunta',
                    body: _showBack ? card.back : card.front,
                    isBack: _showBack,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.flashcardsTapHint,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                    child: const Text(AppStrings.flashcardsPrev),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        _index < _cards.length - 1 ? () => _goTo(_index + 1) : null,
                    child: const Text(AppStrings.flashcardsNext),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    super.key,
    required this.title,
    required this.body,
    required this.isBack,
  });

  final String title;
  final String body;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBack ? AppColors.aiCardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBack
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.chipBg,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                body,
                style: AppTextStyles.selectionTitle.copyWith(height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.welcome),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
