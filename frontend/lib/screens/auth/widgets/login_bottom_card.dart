import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_flow_resolver.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/api/interceptors/error_interceptor.dart';
import '../../../data/dto/auth_dto.dart';

enum AuthFormMode { login, register }

enum _AuthFormStatus { idle, loading, success, error }

class LoginBottomCard extends ConsumerStatefulWidget {
  const LoginBottomCard({super.key, this.mode = AuthFormMode.login});

  final AuthFormMode mode;

  @override
  ConsumerState<LoginBottomCard> createState() => _LoginBottomCardState();
}

class _LoginBottomCardState extends ConsumerState<LoginBottomCard> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthFormStatus _status = _AuthFormStatus.idle;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isLogin => widget.mode == AuthFormMode.login;
  bool get _isLoading => _status == _AuthFormStatus.loading;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
      if (_status == _AuthFormStatus.error) {
        _status = _AuthFormStatus.idle;
      }
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _status = _AuthFormStatus.loading);

    try {
      // ── MODO SIN BACKEND (OFFLINE_MODE=true) ────────────────────────────
      // No hace HTTP. AuthProvider.login/register guardan un token mock
      // local (OfflineData) y luego navegas al onboarding.
      // Para volver al API real: OFFLINE_MODE=false en app_config.dart
      // ───────────────────────────────────────────────────────────────────
      final auth = ref.read(authProvider);
      if (_isLogin) {
        await auth.login(
          LoginRequestDto(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
      } else {
        await auth.register(
          RegisterRequestDto(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          ),
        );
      }

      if (!mounted) return;

      setState(() => _status = _AuthFormStatus.success);
      final session = ref.read(sessionManagerProvider);
      final route = await AppFlowResolver.resolveAfterAuth(
        session,
        isNewUser: !_isLogin,
        examService: ref.read(examProvider),
      );
      if (!mounted) return;
      context.go(route);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _status = _AuthFormStatus.error;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  String _resolveErrorMessage(Object error) {
    final apiException = readApiException(error);
    if (apiException != null) {
      if (_isLogin) {
        if (apiException.statusCode == 401) {
          return AppStrings.loginErrorInvalidCredentials;
        }
        if (apiException.statusCode == 403) {
          return AppStrings.loginErrorInactive;
        }
      } else if (apiException.statusCode == 409) {
        return AppStrings.registerErrorEmailTaken;
      }
      return apiException.message;
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isLogin ? AppStrings.loginTitle : AppStrings.registerTitle,
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(
              _isLogin ? AppStrings.loginSubtitle : AppStrings.registerSubtitle,
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              _buildTextField(
                controller: _fullNameController,
                label: AppStrings.fullNameLabel,
                hint: AppStrings.fullNameHint,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return AppStrings.fullNameRequired;
                  if (trimmed.length < 2) return AppStrings.fullNameTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            _buildTextField(
              controller: _emailController,
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return AppStrings.emailRequired;
                if (!trimmed.contains('@') || !trimmed.contains('.')) {
                  return AppStrings.emailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: AppStrings.passwordLabel,
              hint: _isLogin ? AppStrings.passwordHint : AppStrings.registerPasswordHint,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
              onFieldSubmitted: _isLogin ? (_) => _submit() : null,
              suffixIcon: IconButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.passwordRequired;
                }
                if (!_isLogin && value.length < 8) {
                  return AppStrings.passwordMinLength;
                }
                return null;
              },
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                label: AppStrings.confirmPasswordLabel,
                hint: AppStrings.confirmPasswordHint,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword,
                          ),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.confirmPasswordRequired;
                  }
                  if (value != _passwordController.text) {
                    return AppStrings.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isLoading
                            ? (_isLogin
                                ? AppStrings.loginSubmitting
                                : AppStrings.registerSubmitting)
                            : (_isLogin
                                ? AppStrings.loginButton
                                : AppStrings.registerButton),
                        style: AppTextStyles.buttonLight,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () => context.go(
                          _isLogin ? RoutePaths.register : RoutePaths.login,
                        ),
                child: Text(
                  _isLogin
                      ? AppStrings.loginLinkRegister
                      : AppStrings.registerLinkLogin,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      onFieldSubmitted: onFieldSubmitted,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      labelStyle: AppTextStyles.cardSubtitle,
      hintStyle: AppTextStyles.cardSubtitle,
    );
  }
}
