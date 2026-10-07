import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ExamTimerDisplay extends StatelessWidget {
  const ExamTimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.isWarning = false,
    this.isExpired = false,
  });

  final int remainingSeconds;
  final bool isWarning;
  final bool isExpired;

  String get _formatted {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = isExpired
        ? const Color(0xFFDC2626)
        : isWarning
            ? const Color(0xFFD97706)
            : AppColors.navy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_outlined, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          _formatted,
          style: AppTextStyles.cardSubtitle.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
