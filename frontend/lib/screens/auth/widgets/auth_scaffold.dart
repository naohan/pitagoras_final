import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

/// Layout compartido de pantallas de autenticación (gradiente + hero + card inferior).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.hero,
    required this.bottom,
    this.scrollableBottom = false,
  });

  final Widget hero;
  final Widget bottom;
  final bool scrollableBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundBottom,
            ],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.padding,
                  ),
                  child: hero,
                ),
              ),
              if (scrollableBottom)
                Flexible(
                  child: SingleChildScrollView(
                    child: bottom,
                  ),
                )
              else
                bottom,
            ],
          ),
        ),
      ),
    );
  }
}
