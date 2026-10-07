import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import 'widgets/diagnostic_scaffold.dart';

class DiagnosticProcessingPage extends ConsumerStatefulWidget {
  const DiagnosticProcessingPage({
    super.key,
    required this.studentExamId,
    required this.careerName,
    required this.universityName,
  });

  final int studentExamId;
  final String careerName;
  final String universityName;

  @override
  ConsumerState<DiagnosticProcessingPage> createState() =>
      _DiagnosticProcessingPageState();
}

class _DiagnosticProcessingPageState extends ConsumerState<DiagnosticProcessingPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _processResults());
  }

  Future<void> _processResults() async {
    try {
      await Future.wait([
        Future<void>.delayed(const Duration(seconds: 2)),
        ref.read(diagnosticProvider).getDiagnostic(widget.studentExamId),
      ]);

      final session = ref.read(sessionManagerProvider);
      await session.saveDiagnosticStudentExamId(widget.studentExamId);
      await session.setDiagnosticCompleted(true);

      if (!mounted) return;
      context.go(
        RoutePaths.diagnosticResultPath(
          studentExamId: widget.studentExamId,
          careerName: widget.careerName,
          universityName: widget.universityName,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
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
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          8,
          AppSizes.padding,
          AppSizes.padding,
        ),
        child: Column(
          children: [
            Image.asset(AppAssets.mascotIdea, height: 180, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              AppStrings.diagnosticProcessingTitle,
              style: AppTextStyles.diagnosticHeroTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.diagnosticProcessingSubtitle,
              style: AppTextStyles.onboardingSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _processResults,
                child: const Text(AppStrings.retry),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                AppStrings.diagnosticProcessingNote,
                style: AppTextStyles.selectionSubtitle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
