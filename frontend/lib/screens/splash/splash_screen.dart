import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/providers.dart';
import '../../core/router/app_flow_resolver.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/widgets/login_header.dart';

/// Pantalla de arranque: valida JWT y redirige según sesión.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minDisplayDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveInitialRoute());
  }

  Future<void> _resolveInitialRoute() async {
    final minDelay = Future<void>.delayed(_minDisplayDuration);

    // ── MODO SIN BACKEND (OFFLINE_MODE=true) ──────────────────────────────
    // No valida JWT contra la API. Siempre va al login.
    // Por defecto la app usa el backend: arranca login o simulacro según sesión.
    if (AppConfig.offlineMode) {
      await minDelay;
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (!await auth.hasSession()) {
        if (!mounted) return;
        context.go(RoutePaths.login);
        return;
      }
      final session = ref.read(sessionManagerProvider);
      final route = await AppFlowResolver.resolve(
        session,
        examService: ref.read(examProvider),
      );
      if (!mounted) return;
      context.go(route);
      return;
    }
    // ── FIN modo offline ──────────────────────────────────────────────────

    final auth = ref.read(authProvider);
    final hasToken = await auth.hasSession();
    if (!hasToken) {
      await minDelay;
      if (!mounted) return;
      context.go(RoutePaths.login);
      return;
    }

    try {
      await Future.wait([
        minDelay,
        auth.getMe(),
      ]);
      if (!mounted) return;
      final session = ref.read(sessionManagerProvider);
      final route = await AppFlowResolver.resolve(
        session,
        examService: ref.read(examProvider),
      );
      if (!mounted) return;
      context.go(route);
    } catch (_) {
      await auth.logout();
      if (!mounted) return;
      context.go(RoutePaths.login);
    }
  }

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.slogan,
                    style: AppTextStyles.welcome,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
