import 'dart:async';

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
import '../../data/dto/answer_dto.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/study_activity_model.dart';
import 'widgets/answer_feedback_banner.dart';
import 'widgets/exam_option_tile.dart';
import 'widgets/exam_progress_bar.dart';
import 'widgets/exam_timer_display.dart';
import 'widgets/diagnostic_help_sheet.dart';
import 'widgets/resolution_tip_sheet.dart';

enum _ExamPageStatus { loading, ready, error, submitting, finishing }

class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key, required this.studentExamId});

  final int studentExamId;

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  _ExamPageStatus _status = _ExamPageStatus.loading;
  String? _errorMessage;

  StudentExam? _exam;
  ExamTimeStatus? _timeStatus;
  int _currentIndex = 0;

  final Map<int, int> _selectedOptions = {};
  final Map<int, bool?> _answerFeedback = {};
  final Map<int, bool> _savedQuestions = {};
  final Map<int, DateTime> _questionStartedAt = {};

  Timer? _pollTimer;
  Timer? _countdownTimer;
  int? _remainingSeconds;
  bool _finishInProgress = false;
  int? _savingQuestionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExam());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  List<QuestionForExam> get _questions {
    final list = List<QuestionForExam>.from(_exam?.questions ?? []);
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  QuestionForExam? get _currentQuestion {
    final questions = _questions;
    if (questions.isEmpty || _currentIndex >= questions.length) return null;
    return questions[_currentIndex];
  }

  bool get _isDiagnostic =>
      GoRouterState.of(context).uri.queryParameters['flow'] == 'diagnostic';

  Future<void> _loadExam() async {
    setState(() {
      _status = _ExamPageStatus.loading;
      _errorMessage = null;
    });

    try {
      final examService = ref.read(examProvider);
      final results = await Future.wait([
        examService.getStudentExam(widget.studentExamId),
        examService.getExamTimeStatus(widget.studentExamId),
      ]);

      final studentExam = results[0] as StudentExam;
      final timeStatus = results[1] as ExamTimeStatus;

      for (final answer in studentExam.answers) {
        if (answer.selectedOptionId != null) {
          _selectedOptions[answer.questionId] = answer.selectedOptionId!;
        }
        if (answer.isCorrect != null) {
          _answerFeedback[answer.questionId] = answer.isCorrect;
        }
        if (answer.isSaved) {
          _savedQuestions[answer.questionId] = true;
        }
      }

      if (!mounted) return;

      setState(() {
        _exam = studentExam;
        _timeStatus = timeStatus;
        _remainingSeconds = timeStatus.remainingSeconds;
        _status = _ExamPageStatus.ready;
      });

      _markQuestionStart();
      _startTimers();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _ExamPageStatus.error;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  void _startTimers() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _pollTime());

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds == null || _remainingSeconds! <= 0) return;
      setState(() => _remainingSeconds = _remainingSeconds! - 1);
    });
  }

  Future<void> _pollTime() async {
    try {
      final timeStatus =
          await ref.read(examProvider).getExamTimeStatus(widget.studentExamId);
      if (!mounted) return;
      setState(() {
        _timeStatus = timeStatus;
        _remainingSeconds = timeStatus.remainingSeconds;
      });
    } catch (_) {
      // Mantener último valor conocido del temporizador.
    }
  }

  void _markQuestionStart() {
    final question = _currentQuestion;
    if (question == null) return;
    _questionStartedAt[question.id] = DateTime.now();
  }

  int _elapsedSecondsForQuestion(int questionId) {
    final started = _questionStartedAt[questionId];
    if (started == null) return 0;
    return DateTime.now().difference(started).inSeconds;
  }

  Future<void> _selectOption(int optionId) async {
    final question = _currentQuestion;
    if (question == null || _status == _ExamPageStatus.submitting) return;
    if (_timeStatus?.isExpired == true) return;

    final previous = _selectedOptions[question.id];
    if (previous == optionId) return;

    setState(() {
      _selectedOptions[question.id] = optionId;
      _status = _ExamPageStatus.submitting;
      _errorMessage = null;
    });

    try {
      final answer = await ref.read(examProvider).submitAnswer(
            widget.studentExamId,
            SubmitAnswerRequestDto(
              questionId: question.id,
              selectedOptionId: optionId,
              timeSeconds: _elapsedSecondsForQuestion(question.id),
            ),
          );

      if (!mounted) return;
      setState(() {
        _answerFeedback[question.id] = answer.isCorrect;
        _status = _ExamPageStatus.ready;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _selectedOptions.remove(question.id);
        if (previous != null) {
          _selectedOptions[question.id] = previous;
        }
        _status = _ExamPageStatus.ready;
        _errorMessage = _resolveErrorMessage(error, submitContext: true);
      });
    }
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length || index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _markQuestionStart();
  }

  int get _unansweredCount {
    return _questions.where((q) => !_selectedOptions.containsKey(q.id)).length;
  }

  Future<void> _confirmFinish() async {
    if (_finishInProgress) return;

    final unanswered = _unansweredCount;
    final body = unanswered > 0
        ? 'Tienes $unanswered preguntas sin responder. ${AppStrings.examFinishBody}'
        : AppStrings.examFinishBody;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.examFinishTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.examFinishCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.examFinishConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _finishExam();
  }

  Future<void> _finishExam() async {
    if (_finishInProgress) return;

    _finishInProgress = true;
    setState(() {
      _status = _ExamPageStatus.finishing;
      _errorMessage = null;
    });

    try {
      await ref.read(examProvider).finishStudentExam(widget.studentExamId);
      await ref.read(studyActivityProvider).recordActivity(
            StudyActivityTypes.exam,
            refId: 'exam-${widget.studentExamId}',
          );
      if (!mounted) return;

      final params = GoRouterState.of(context).uri.queryParameters;
      final flow = params['flow'];
      final careerName = params['careerName'] ?? '';
      final universityName = params['universityName'] ?? '';

      if (flow == 'diagnostic') {
        context.go(
          RoutePaths.diagnosticProcessingPath(
            studentExamId: widget.studentExamId,
            careerName: careerName,
            universityName: universityName,
          ),
        );
        return;
      }

      context.go(RoutePaths.resultsSession(widget.studentExamId));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _ExamPageStatus.ready;
        _errorMessage = _resolveErrorMessage(error, finishContext: true);
      });
    } finally {
      _finishInProgress = false;
    }
  }

  void _retryQuestion(int questionId) {
    setState(() {
      _selectedOptions.remove(questionId);
      _answerFeedback.remove(questionId);
    });
    _markQuestionStart();
  }

  void _openDiagnosticHelp(QuestionForExam question) {
    DiagnosticHelpSheet.show(
      context,
      questionId: question.id,
      selectedOptionId: _selectedOptions[question.id],
      onRetry: () => _retryQuestion(question.id),
    );
  }

  Future<void> _toggleSave(QuestionForExam question) async {
    if (_savingQuestionId == question.id) return;

    final currentlySaved = _savedQuestions[question.id] ?? false;
    setState(() => _savingQuestionId = question.id);

    try {
      final answer = await ref.read(examProvider).toggleSaveAnswer(
            widget.studentExamId,
            question.id,
            isSaved: !currentlySaved,
          );

      if (!mounted) return;
      setState(() {
        if (answer.isSaved) {
          _savedQuestions[question.id] = true;
        } else {
          _savedQuestions.remove(question.id);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _resolveErrorMessage(error, submitContext: true);
      });
    } finally {
      if (mounted) {
        setState(() => _savingQuestionId = null);
      }
    }
  }

  String _resolveErrorMessage(
    Object error, {
    bool finishContext = false,
    bool submitContext = false,
  }) {
    final apiException = readApiException(error);
    if (apiException != null) return apiException.message;
    if (error is ApiException) return error.message;
    if (error is TypeError || error is FormatException) {
      return finishContext
          ? AppStrings.examFinishError
          : submitContext
              ? AppStrings.examSubmitError
              : AppStrings.examLoadError;
    }
    if (submitContext) return AppStrings.examSubmitError;
    return finishContext ? AppStrings.examFinishError : AppStrings.examLoadError;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundBottom,
          appBar: AppBar(
            title: const Text(AppStrings.examTitle),
            actions: [
              if (_remainingSeconds != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: ExamTimerDisplay(
                      remainingSeconds: _remainingSeconds!,
                      isWarning: _remainingSeconds! < 300,
                      isExpired: _timeStatus?.isExpired ?? false,
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(child: _buildBody()),
        ),
        if (_status == _ExamPageStatus.finishing)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0x88000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.examFinishing,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_status == _ExamPageStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_status == _ExamPageStatus.error && _exam == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? AppStrings.examLoadError,
                style: AppTextStyles.welcome,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _loadExam,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    final question = _currentQuestion;
    if (question == null) {
      return Center(child: Text(AppStrings.examNoQuestions));
    }

    final total = _questions.length;
    final isSubmitting = _status == _ExamPageStatus.submitting;
    final isLastQuestion = _currentIndex >= total - 1;
    final selectedOptionId = _selectedOptions[question.id];
    final feedback = _answerFeedback[question.id];
    final canNavigate = !isSubmitting && _status != _ExamPageStatus.finishing;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExamProgressBar(current: _currentIndex + 1, total: total),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(question.stem, style: AppTextStyles.cardTitle),
                  ),
                  const SizedBox(height: 20),
                  ...() {
                    final options = List.of(question.options)
                      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
                    return options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExamOptionTile(
                          label: option.label,
                          text: option.text,
                          isSelected: selectedOptionId == option.id,
                          enabled: !isSubmitting && !(_timeStatus?.isExpired ?? false),
                          onTap: () => _selectOption(option.id),
                        ),
                      );
                    });
                  }(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!_isDiagnostic)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () => ResolutionTipSheet.show(
                                      context,
                                      questionId: question.id,
                                      selectedOptionId: selectedOptionId,
                                    ),
                            icon: const Icon(Icons.lightbulb_outline, size: 18),
                            label: const Text(AppStrings.examResolutionTip),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      if (!_isDiagnostic) const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _savingQuestionId == question.id || isSubmitting
                              ? null
                              : () => _toggleSave(question),
                          icon: Icon(
                            _savedQuestions[question.id] == true
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 18,
                          ),
                          label: Text(
                            _savedQuestions[question.id] == true
                                ? AppStrings.examSavedQuestion
                                : AppStrings.examSaveQuestion,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 12),
                    AnswerFeedbackBanner(
                      isCorrect: feedback,
                      wrongMessage: _isDiagnostic
                          ? AppStrings.examAnswerWrongDiagnostic
                          : AppStrings.examAnswerWrongAtEnd,
                      helpButtonLabel:
                          _isDiagnostic ? AppStrings.examAskHelpDiagnostic : null,
                      onAskTutor: feedback == false && _isDiagnostic
                          ? () => _openDiagnosticHelp(question)
                          : null,
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                  if (_timeStatus?.isExpired == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.examTimeExpired,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _currentIndex > 0 && canNavigate
                      ? () => _goToQuestion(_currentIndex - 1)
                      : null,
                  child: const Text(AppStrings.examPrevious),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: !canNavigate
                      ? null
                      : isLastQuestion
                          ? _confirmFinish
                          : () => _goToQuestion(_currentIndex + 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(
                    isLastQuestion ? AppStrings.examFinish : AppStrings.examNext,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
