import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_text_styles.dart';

/// Acceso rápido al chat con Cachimbito.
class MotivatorEntryCard extends StatelessWidget {
  const MotivatorEntryCard({super.key, required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3E8FF),
      borderRadius: BorderRadius.circular(compact ? 14 : 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
            border: Border.all(color: const Color(0xFFDDD6FE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.mascotPose3,
                height: compact ? 64 : 88,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.motivatorCardTitle,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: compact ? 15 : 17,
                            color: const Color(0xFF5B21B6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.motivatorCardSubtitle,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: compact ? 12 : 13,
                        height: 1.35,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.motivatorCardCta,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (compact)
                const Icon(Icons.chevron_right, color: Color(0xFF7C3AED))
              else
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF7C3AED)),
            ],
          ),
        ),
      ),
    );
  }
}
