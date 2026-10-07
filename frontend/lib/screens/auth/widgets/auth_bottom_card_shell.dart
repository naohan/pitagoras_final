import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

/// Contenedor visual de la card inferior (mismo estilo que [LoginBottomCard]).
class AuthBottomCardShell extends StatelessWidget {
  const AuthBottomCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusCard),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A2F6BEE),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        28,
        AppSizes.padding,
        AppSizes.padding,
      ),
      child: child,
    );
  }
}
