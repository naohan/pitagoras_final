import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

class MascotHero extends StatelessWidget {
  const MascotHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 20,
            left: 30,
            child: _Cloud(width: 70, height: 28),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: _Cloud(width: 90, height: 32),
          ),
          Positioned(
            bottom: 30,
            left: 50,
            child: _Cloud(width: 60, height: 24),
          ),
          const Positioned(
            top: 18,
            left: 36,
            child: _FloatingBubble(
              icon: Icons.calculate_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          const Positioned(
            top: 8,
            right: 40,
            child: _FloatingBubble(
              asset: AppAssets.iconBook,
            ),
          ),
          const Positioned(
            bottom: 52,
            left: 28,
            child: _FloatingBubble(
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          const Positioned(
            bottom: 40,
            right: 32,
            child: _FloatingBubble(
              asset: AppAssets.iconTrophy,
            ),
          ),
          Image.asset(
            AppAssets.mascotPose1,
            height: AppSizes.mascotHeight,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cloud,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}

class _FloatingBubble extends StatelessWidget {
  const _FloatingBubble({
    this.icon,
    this.iconColor,
    this.asset,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final Color? iconColor;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.iconBubble,
      height: AppSizes.iconBubble,
      decoration: BoxDecoration(
        color: AppColors.bubble,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: iconColor, size: 22)
            : Image.asset(
                asset!,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
