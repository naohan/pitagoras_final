import 'package:flutter/material.dart';

import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class HubActionCard extends StatelessWidget {
  const HubActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: highlight ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusCard),
              border: Border.all(
                color: highlight ? AppColors.primary : AppColors.border,
                width: highlight ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(subtitle, style: AppTextStyles.cardSubtitle),
                    ],
                  ),
                ),
                trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
