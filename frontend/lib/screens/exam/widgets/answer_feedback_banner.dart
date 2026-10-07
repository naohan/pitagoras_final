import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';

/// Banner inline tras enviar respuesta (`POST .../answers` → `is_correct`).
class AnswerFeedbackBanner extends StatelessWidget {
  const AnswerFeedbackBanner({
    super.key,
    required this.isCorrect,
    this.onAskTutor,
    this.wrongMessage,
    this.helpButtonLabel,
  });

  final bool? isCorrect;
  final VoidCallback? onAskTutor;
  final String? wrongMessage;
  final String? helpButtonLabel;

  static const _successBg = Color(0xFFDCFCE7);
  static const _successFg = Color(0xFF16A34A);
  static const _errorBg = Color(0xFFFEE2E2);
  static const _errorFg = Color(0xFFDC2626);
  static const _neutralBg = Color(0xFFF0F6FF);
  static const _neutralFg = Color(0xFF2E4278);

  @override
  Widget build(BuildContext context) {
    final bool? correct = isCorrect;
    final Color bg;
    final Color fg;
    final IconData icon;
    final String message;

    if (correct == true) {
      bg = _successBg;
      fg = _successFg;
      icon = Icons.check_circle_outline;
      message = AppStrings.examAnswerCorrect;
    } else if (correct == false) {
      bg = _errorBg;
      fg = _errorFg;
      icon = Icons.cancel_outlined;
      message = wrongMessage ?? AppStrings.examAnswerWrong;
    } else {
      bg = _neutralBg;
      fg = _neutralFg;
      icon = Icons.info_outline;
      message = AppStrings.examAnswerSaved;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (correct == false && onAskTutor != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onAskTutor,
              icon: const Icon(Icons.school_outlined, size: 18),
              label: Text(helpButtonLabel ?? AppStrings.examAskTutor),
              style: TextButton.styleFrom(
                foregroundColor: fg,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
