import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/dto/study_techniques_dto.dart';

class FeynmanPage extends ConsumerStatefulWidget {
  const FeynmanPage({super.key});

  @override
  ConsumerState<FeynmanPage> createState() => _FeynmanPageState();
}

class _FeynmanPageState extends ConsumerState<FeynmanPage> {
  static const _topics = [
    ('ecuaciones', 'Ecuaciones lineales'),
    ('funciones', 'Funciones y representación'),
    ('geometria', 'Geometría plana'),
    ('probabilidad', 'Probabilidad'),
    ('proporcionalidad', 'Proporcionalidad'),
    ('estadistica', 'Estadística descriptiva'),
  ];

  final _controller = TextEditingController();
  String _selectedKey = 'ecuaciones';
  bool _loading = false;
  FeynmanAnalysisDto? _result;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.length < 10) {
      setState(() => _error = AppStrings.feynmanTooShort);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final name = _topics.firstWhere((t) => t.$1 == _selectedKey).$2;
      final result = await ref.read(studyTechniquesProvider).analyzeFeynman(
            FeynmanAnalyzeRequestDto(
              subtopicName: name,
              subtopicKey: _selectedKey,
              explanation: text,
            ),
          );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicName = _topics.firstWhere((t) => t.$1 == _selectedKey).$2;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text(AppStrings.feynmanTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.feynmanSubtitle, style: AppTextStyles.welcome),
              const SizedBox(height: 16),
              Text(AppStrings.feynmanTopicLabel, style: AppTextStyles.cardTitle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKey,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _topics
                    .map(
                      (t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)),
                    )
                    .toList(),
                onChanged: _loading ? null : (v) => setState(() => _selectedKey = v!),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.feynmanPrompt(topicName),
                style: AppTextStyles.cardSubtitle,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 8,
                enabled: !_loading,
                decoration: InputDecoration(
                  hintText: AppStrings.feynmanHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: AppSizes.buttonHeight,
                child: FilledButton(
                  onPressed: _loading ? null : _analyze,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.feynmanAnalyze),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 24),
                Text(
                  AppStrings.feynmanScore(_result!.scorePercent),
                  style: AppTextStyles.greeting.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                _ListBlock(
                  title: AppStrings.feynmanStrengths,
                  items: _result!.strengths,
                  color: AppColors.success,
                ),
                _ListBlock(
                  title: AppStrings.feynmanGaps,
                  items: _result!.gaps,
                  color: const Color(0xFFDC2626),
                ),
                _ListBlock(
                  title: AppStrings.feynmanSuggestions,
                  items: _result!.suggestions,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({
    required this.title,
    required this.items,
    required this.color,
  });

  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(color: color)),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(child: Text(item, style: AppTextStyles.welcome)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
