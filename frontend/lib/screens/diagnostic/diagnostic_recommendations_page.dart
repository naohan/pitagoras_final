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
import '../../data/dto/agents_dto.dart';
import '../../data/enums.dart';
import '../../data/models/diagnostic_model.dart';
import '../../data/models/results_model.dart';
import '../../core/utils/score_utils.dart';
import 'widgets/diagnostic_scaffold.dart';

class DiagnosticRecommendationsPage extends ConsumerStatefulWidget {
  const DiagnosticRecommendationsPage({
    super.key,
    required this.studentExamId,
    required this.careerName,
    required this.universityName,
  });

  final int studentExamId;
  final String careerName;
  final String universityName;

  @override
  ConsumerState<DiagnosticRecommendationsPage> createState() =>
      _DiagnosticRecommendationsPageState();
}

class _DiagnosticRecommendationsPageState
    extends ConsumerState<DiagnosticRecommendationsPage> {
  bool _loading = true;
  String? _errorMessage;
  DiagnosticReport? _diagnostic;
  StudyPlan? _studyPlan;
  String? _agentInsight;

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
      final diagnostic = await ref.read(diagnosticProvider).getDiagnostic(
            widget.studentExamId,
          );
      final studyPlan = await ref.read(resultsProvider).getStudyPlan(
            widget.studentExamId,
          );

      String? insight;
      try {
        final agent = await ref.read(agentsProvider).analyzeDiagnostic(
              AgentRunRequestDto(studentExamId: widget.studentExamId),
            );
        insight = agent.content;
      } catch (_) {
        insight = null;
      }

      if (!mounted) return;
      setState(() {
        _diagnostic = diagnostic;
        _studyPlan = studyPlan;
        _agentInsight = insight;
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

  @override
  Widget build(BuildContext context) {
    return DiagnosticScaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null || _diagnostic == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage ?? AppStrings.resultsLoadError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _loadData, child: const Text(AppStrings.retry)),
          ],
        ),
      );
    }

    final diagnostic = _diagnostic!;
    final aiText = _agentInsight ??
        '${AppStrings.diagnosticAiHighlight}${AppStrings.diagnosticAiBody}';

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
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.aiCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(aiText, style: AppTextStyles.welcome)),
                const SizedBox(width: 8),
                Image.asset(AppAssets.mascotIdea, height: 72, fit: BoxFit.contain),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.diagnosticStrengths,
            style: AppTextStyles.selectionTitle.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: 12),
          ...diagnostic.strengths.map(
            (item) => _StrengthWeaknessRow(name: item, isStrength: true),
          ),
          if (diagnostic.strengths.isEmpty)
            Text(AppStrings.resultsNoStrengthsYet, style: AppTextStyles.welcome),
          const SizedBox(height: 20),
          Text(
            AppStrings.diagnosticWeaknesses,
            style: AppTextStyles.selectionTitle.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: 12),
          ...diagnostic.weaknesses.map(
            (item) => _StrengthWeaknessRow(name: item, isStrength: false),
          ),
          if (diagnostic.weaknesses.isEmpty)
            Text(AppStrings.resultsNoWeaknessesYet, style: AppTextStyles.welcome),
          if (diagnostic.subtopics.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(AppStrings.resultsSubtopicDetail, style: AppTextStyles.selectionTitle),
            const SizedBox(height: 12),
            ...diagnostic.subtopics.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubtopicDetailRow(item: item),
              ),
            ),
          ],
          if (_studyPlan != null && _studyPlan!.recommendations.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(AppStrings.resultsStudyPlanSection, style: AppTextStyles.selectionTitle),
            const SizedBox(height: 12),
            ..._studyPlan!.recommendations.take(3).map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• ${rec.message}', style: AppTextStyles.welcome),
                  ),
                ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: () async {
                final session = ref.read(sessionManagerProvider);
                await session.setDiagnosticCompleted(true);
                await session.saveDiagnosticStudentExamId(widget.studentExamId);
                if (!context.mounted) return;
                context.go(RoutePaths.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                ),
              ),
              child: Text(
                AppStrings.diagnosticCreatePlan,
                style: AppTextStyles.buttonLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtopicDetailRow extends StatelessWidget {
  const _SubtopicDetailRow({required this.item});

  final DiagnosticItem item;

  @override
  Widget build(BuildContext context) {
    final topic = item.parentName;
    final title = topic != null && topic.isNotEmpty
        ? '$topic → ${item.name}'
        : item.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.diagnosticCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.selectionTitle),
                const SizedBox(height: 4),
                Text(
                  '${item.correctAnswers}/${item.totalQuestions} correctas · '
                  '${ScoreUtils.formatPercent(item.scorePercent)}',
                  style: AppTextStyles.selectionSubtitle,
                ),
              ],
            ),
          ),
          Text(
            item.level.value,
            style: TextStyle(
              color: item.level == PerformanceLevel.weakness
                  ? AppColors.danger
                  : item.level == PerformanceLevel.strength
                      ? AppColors.success
                      : AppColors.progressOrange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StrengthWeaknessRow extends StatelessWidget {
  const _StrengthWeaknessRow({required this.name, required this.isStrength});

  final String name;
  final bool isStrength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isStrength ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isStrength ? AppColors.success : AppColors.danger,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: AppTextStyles.selectionTitle)),
        ],
      ),
    );
  }
}
