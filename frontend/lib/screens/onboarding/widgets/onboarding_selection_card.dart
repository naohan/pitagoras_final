import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingSelectionCard extends StatelessWidget {
  const OnboardingSelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isSelected = false,
    this.onTap,
    this.scoreRange,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? scoreRange;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSelectionCard),
        child: Ink(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSelectionCard),
            border: Border.all(
              color: isSelected ? AppColors.selectedBorder : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.selectionTitle),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: AppTextStyles.selectionSubtitle),
                    ],
                  ],
                ),
              ),
              if (scoreRange != null) ...[
                Text(
                  scoreRange!,
                  style: AppTextStyles.scoreRange,
                ),
                const SizedBox(width: 8),
              ],
              trailing ??
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: isSelected ? AppColors.success : AppColors.textMuted,
                    size: isSelected ? 24 : 28,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class UniversityLogoAvatar extends StatelessWidget {
  const UniversityLogoAvatar({
    super.key,
    this.logoAsset,
    this.initials,
    this.initialsColor,
  });

  final String? logoAsset;
  final String? initials;
  final int? initialsColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoAsset != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(logoAsset!, fit: BoxFit.contain),
            )
          : Center(
              child: Text(
                initials ?? '?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(initialsColor ?? 0xFF64748B),
                ),
              ),
            ),
    );
  }
}

class AreaIconAvatar extends StatelessWidget {
  const AreaIconAvatar({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class CareerIconAvatar extends StatelessWidget {
  const CareerIconAvatar({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class SelectedAreaChip extends StatelessWidget {
  const SelectedAreaChip({super.key, required this.areaName});

  final String areaName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Área seleccionada: $areaName',
        style: AppTextStyles.chipLabel,
      ),
    );
  }
}

class VocationalWarningBanner extends StatelessWidget {
  const VocationalWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusSelectionCard),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.warningText,
                children: const [
                  TextSpan(
                    text: 'Tu carrera requiere Evaluación de Perfil Vocacional',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' — pesa 30% de tu puntaje',
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

class MascotConfirmationBubble extends StatelessWidget {
  const MascotConfirmationBubble({
    super.key,
    required this.message,
    this.mascotAsset,
  });

  final String message;
  final String? mascotAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Text(message, style: AppTextStyles.mascotBubble),
          ),
        ),
        const SizedBox(width: 8),
        if (mascotAsset != null)
          Image.asset(
            mascotAsset!,
            height: 72,
            fit: BoxFit.contain,
          ),
      ],
    );
  }
}
