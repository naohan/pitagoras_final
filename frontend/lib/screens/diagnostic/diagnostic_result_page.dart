import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/diagnostic_model.dart';
import '../../data/models/results_model.dart';
import 'widgets/diagnostic_scaffold.dart';

class DiagnosticResultPage extends ConsumerStatefulWidget {
  const DiagnosticResultPage({
    super.key,
    required this.studentExamId,
    required this.careerName,
    required this.universityName,
  });

  final int studentExamId;
  final String careerName;
  final String universityName;

  @override
  ConsumerState<DiagnosticResultPage> createState() => _DiagnosticResultPageState();
}

class _DiagnosticResultPageState extends ConsumerState<DiagnosticResultPage> {
  bool _loading = true;
  String? _errorMessage;
  DiagnosticReport? _diagnostic;
  StudentExamResult? _results;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final loaded = await Future.wait([
        ref.read(diagnosticProvider).getDiagnostic(widget.studentExamId),
        ref.read(resultsProvider).getStudentExamResults(widget.studentExamId),
      ]);

      if (!mounted) return;
      setState(() {
        _diagnostic = loaded[0] as DiagnosticReport;
        _results = loaded[1] as StudentExamResult;
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

  double get _score =>
      _results?.result?.scorePercent ?? _diagnostic?.globalScorePercent ?? 0;

  @override
  Widget build(BuildContext context) {
    final subtitle = '${widget.careerName} - ${widget.universityName}';

    return DiagnosticScaffold(
      title: AppStrings.diagnosticResultTitle,
      subtitle: subtitle,
      bottomNavIndex: 2,
      body: _buildBody(),
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
            OutlinedButton(onPressed: _loadData, child: const Text(AppStrings.retry)),
          ],
        ),
      );
    }

    final diagnostic = _diagnostic!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        8,
        AppSizes.padding,
        AppSizes.padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.diagnosticYourScore,
                        style: AppTextStyles.selectionSubtitle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_score.toStringAsFixed(1)} / 100',
                        style: AppTextStyles.diagnosticScoreBig,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${diagnostic.correctAnswers}/${diagnostic.totalQuestions} correctas',
                        style: AppTextStyles.selectionSubtitle,
                      ),
                    ],
                  ),
                ),
                Image.asset(AppAssets.iconTrophy, width: 72, height: 72),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.diagnosticPerformanceByArea,
            style: AppTextStyles.selectionTitle,
          ),
          const SizedBox(height: 16),
          ...diagnostic.areas.map(
            (area) => DiagnosticAreaProgressRow(
              name: area.name,
              iconAsset: AppAssets.iconTopics,
              percent: area.scorePercent,
              showPercentLabel: true,
            ),
          ),
          if (diagnostic.subtopics.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              AppStrings.resultsSubtopicDetail,
              style: AppTextStyles.selectionTitle,
            ),
            const SizedBox(height: 12),
            ...diagnostic.subtopics.map(
              (item) {
                final label = item.parentName != null && item.parentName!.isNotEmpty
                    ? '${item.parentName} → ${item.name}'
                    : item.name;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DiagnosticAreaProgressRow(
                    name: label,
                    iconAsset: AppAssets.iconFlashcard,
                    percent: item.scorePercent,
                    showPercentLabel: true,
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  RoutePaths.diagnosticRecommendationsPath(
                    studentExamId: widget.studentExamId,
                    careerName: widget.careerName,
                    universityName: widget.universityName,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                ),
              ),
              child: Text(
                AppStrings.diagnosticViewRecommendations,
                style: AppTextStyles.buttonLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
