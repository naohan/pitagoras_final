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
import '../../data/models/study_activity_model.dart';

class _ChatMessage {
  const _ChatMessage({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

class MotivatorPage extends ConsumerStatefulWidget {
  const MotivatorPage({super.key});

  @override
  ConsumerState<MotivatorPage> createState() => _MotivatorPageState();
}

class _MotivatorPageState extends ConsumerState<MotivatorPage> {
  final _messages = <_ChatMessage>[];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  int? _studentExamId;
  bool _loading = false;
  bool _bootstrapping = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final session = ref.read(sessionManagerProvider);
    _userName = await session.getUserFullName();
    _studentExamId =
        await session.getDiagnosticStudentExamId() ?? await session.getStudentExamId();

    if (!mounted) return;
    setState(() => _bootstrapping = false);

    if (_studentExamId != null) {
      await _askMotivator();
      return;
    }

    setState(() {
      _messages.add(
        const _ChatMessage(
          isUser: false,
          text: AppStrings.motivatorWelcome,
        ),
      );
      _messages.add(
        const _ChatMessage(
          isUser: false,
          text: AppStrings.motivatorNeedDiagnostic,
        ),
      );
    });
  }

  Future<void> _askMotivator({String? studentMessage}) async {
    final examId = _studentExamId;
    if (examId == null) return;

    setState(() => _loading = true);

    try {
      final insight = await ref.read(agentsProvider).encourageStudent(
            AgentRunRequestDto(
              studentExamId: examId,
              studentMessage: studentMessage,
            ),
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messages.add(_ChatMessage(isUser: false, text: insight.content));
      });
      await ref.read(studyActivityProvider).recordActivity(
            StudyActivityTypes.motivator,
          );
      _scrollToEnd();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      final message = readApiException(error)?.message ??
          (error is ApiException ? error.message : AppStrings.resultsLoadError);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _loading) return;

    _inputController.clear();
    setState(() => _messages.add(_ChatMessage(isUser: true, text: text)));

    if (_studentExamId == null) {
      setState(() {
        _messages.add(
          const _ChatMessage(
            isUser: false,
            text: AppStrings.motivatorNeedDiagnostic,
          ),
        );
      });
      _scrollToEnd();
      return;
    }

    await _askMotivator(studentMessage: text);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final greetingName = _userName?.trim();

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.motivatorPageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go(RoutePaths.home),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
            ),
            child: Row(
              children: [
                Image.asset(AppAssets.mascotPose3, height: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greetingName != null && greetingName.isNotEmpty
                            ? '¡Hola, $greetingName!'
                            : AppStrings.motivatorPageGreeting,
                        style: AppTextStyles.cardTitle.copyWith(color: const Color(0xFF5B21B6)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.motivatorPageSubtitle,
                        style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _bootstrapping
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_loading && index == _messages.length) {
                        return const _TypingBubble();
                      }
                      return _ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: AppStrings.motivatorInputHint,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: AppSizes.buttonHeight - 4,
                    width: AppSizes.buttonHeight - 4,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Icon(Icons.send_rounded, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Image.asset(AppAssets.mascotIdea, width: 36, height: 36),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
                border: isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.welcome.copyWith(
                  color: isUser ? Colors.white : AppColors.navy,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Image.asset(AppAssets.mascotIdea, width: 36, height: 36),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
  }
}
