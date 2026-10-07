import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/login_bottom_card.dart';
import 'widgets/login_header.dart';
import 'widgets/mascot_hero.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: LoginHeader(),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        AppStrings.registerGreeting,
                        style: AppTextStyles.greeting,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.registerWelcome,
                        style: AppTextStyles.welcome,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const MascotHero(),
                    ],
                  ),
                ),
              ),
              const Flexible(
                child: SingleChildScrollView(
                  child: LoginBottomCard(mode: AuthFormMode.register),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
