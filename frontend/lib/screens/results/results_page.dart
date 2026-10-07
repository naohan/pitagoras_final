import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import 'widgets/results_agents_section.dart';
import 'widgets/results_diagnostic_section.dart';
import 'widgets/results_score_section.dart';
import 'widgets/results_study_plan_section.dart';

enum _ResultsPageStatus { loading, ready, error }

/// Hub post-examen: puntaje, diagnóstico y plan de estudio.
class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key, required this.studentExamId});

  final int studentExamId;

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  _ResultsPageStatus _status = _ResultsPageStatus.loading;
  String? _errorMessage;

  StudentExamResult? _results;
  DiagnosticReport? _diagnostic;
  StudyPlan? _studyPlan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _status = _ResultsPageStatus.loading;
      _errorMessage = null;
    });

    try {
      final resultsService = ref.read(resultsProvider);
      final diagnosticService = ref.read(diagnosticProvider);

      final loaded = await Future.wait([
        resultsService.getStudentExamResults(widget.studentExamId),
        diagnosticService.getDiagnostic(widget.studentExamId),
        resultsService.getStudyPlan(widget.studentExamId),
      ]);

      if (!mounted) return;
      setState(() {
        _results = loaded[0] as StudentExamResult;
        _diagnostic = loaded[1] as DiagnosticReport;
        _studyPlan = loaded[2] as StudyPlan;
        _status = _ResultsPageStatus.ready;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _ResultsPageStatus.error;
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.resultsTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_status == _ResultsPageStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_status == _ResultsPageStatus.error || _results == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? AppStrings.resultsLoadError,
                style: AppTextStyles.welcome,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _loadData,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultsScoreSection(data: _results!),
                const SizedBox(height: 32),
                if (_diagnostic != null) ...[
                  ResultsDiagnosticSection(report: _diagnostic!),
                  const SizedBox(height: 32),
                ],
                if (_studyPlan != null) ...[
                  ResultsStudyPlanSection(plan: _studyPlan!),
                  const SizedBox(height: 32),
                ],
                ResultsAgentsSection(studentExamId: widget.studentExamId),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go(RoutePaths.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text(AppStrings.resultsBackToHome),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.push(
                    RoutePaths.examReviewSession(widget.studentExamId),
                  ),
                  child: const Text(AppStrings.resultsReviewAnswers),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => context.push(RoutePaths.simulacro),
                  child: const Text(AppStrings.resultsBackToSimulacro),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
