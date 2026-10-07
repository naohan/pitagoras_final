import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/api/interceptors/error_interceptor.dart';
import '../../../data/dto/agents_dto.dart';
import '../../../data/models/agents_model.dart';
import 'results_section_header.dart';

typedef AgentRequest = Future<AgentInsight> Function(AgentsProvider provider);

/// Tarjeta de agente IA (`POST /agents/*`).
class ResultsAgentCard extends ConsumerStatefulWidget {
  const ResultsAgentCard({
    super.key,
    required this.title,
    required this.studentExamId,
    required this.request,
  });

  final String title;
  final int studentExamId;
  final AgentRequest request;

  @override
  ConsumerState<ResultsAgentCard> createState() => _ResultsAgentCardState();
}

class _ResultsAgentCardState extends ConsumerState<ResultsAgentCard> {
  AgentInsight? _insight;
  String? _errorMessage;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final insight = await widget.request(
        ref.read(agentsProvider),
      );
      if (!mounted) return;
      setState(() {
        _insight = insight;
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_insight != null)
            Text(_insight!.content, style: AppTextStyles.welcome)
          else if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: AppTextStyles.cardSubtitle.copyWith(color: const Color(0xFFDC2626)),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_insight == null ? AppStrings.resultsAgentGenerate : AppStrings.retry),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsAgentsSection extends StatelessWidget {
  const ResultsAgentsSection({super.key, required this.studentExamId});

  final int studentExamId;

  AgentRunRequestDto get _requestDto => AgentRunRequestDto(studentExamId: studentExamId);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResultsSectionHeader(title: AppStrings.resultsAiSection),
        const SizedBox(height: 16),
        ResultsAgentCard(
          title: AppStrings.resultsAgentDiagnostic,
          studentExamId: studentExamId,
          request: (provider) => provider.analyzeDiagnostic(_requestDto),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        ResultsAgentCard(
          title: AppStrings.resultsAgentMotivator,
          studentExamId: studentExamId,
          request: (provider) => provider.encourageStudent(_requestDto),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        ResultsAgentCard(
          title: AppStrings.resultsAgentParents,
          studentExamId: studentExamId,
          request: (provider) => provider.parentReport(_requestDto),
        ),
      ],
    );
  }
}
