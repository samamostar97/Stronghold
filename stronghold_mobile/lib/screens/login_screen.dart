import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/auth_provider.dart';
import '../utils/input_decoration_utils.dart';
import '../utils/validators.dart';
import '../widgets/shared/surface_card.dart';
import 'package:stronghold_core/stronghold_core.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(authProvider.notifier)
          .login(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      final user = ref.read(authProvider).user;
      if (user != null) {
        context.go('/login-success');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.dumbbell,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    )
                        .animate()
                        .fadeIn(
                            duration: Motion.dramatic, curve: Motion.curve)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: Motion.dramatic,
                          curve: Motion.curve,
                        ),
                    const SizedBox(height: AppSpacing.xl),
                    // Title
                    Text(
                      'STRONGHOLD',
                      style: AppTextStyles.stat.copyWith(
                        letterSpacing: 4,
                        color: AppColors.textPrimary,
                      ),
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(
                            duration: Motion.smooth, curve: Motion.curve),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Dobrodosli nazad',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                        .animate(delay: 250.ms)
                        .fadeIn(
                            duration: Motion.smooth, curve: Motion.curve),
                    const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),
                    // Login form card
                    _LoginFormCard(
                      formKey: _formKey,
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      obscurePassword: _obscurePassword,
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                      onTogglePassword: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      onLogin: _handleLogin,
                      onForgotPassword: () => context.push('/forgot-password'),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(
                            duration: Motion.smooth, curve: Motion.curve)
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: Motion.smooth,
                          curve: Motion.curve,
                        ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nemate racun? ',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Registrujte se',
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate(delay: 550.ms)
                        .fadeIn(
                            duration: Motion.normal, curve: Motion.curve),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.formKey,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('KORISNICKO IME', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: usernameCtrl,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: buildStrongholdInputDecoration(
                hintText: 'Unesite korisnicko ime',
                prefixIcon: LucideIcons.user,
              ),
              validator: (value) {
                return FormValidators.required(
                  value,
                  message: 'Molimo unesite korisnicko ime',
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('LOZINKA', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: passwordCtrl,
              obscureText: obscurePassword,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onLogin(),
              decoration: buildStrongholdInputDecoration(
                hintText: 'Unesite lozinku',
                prefixIcon: LucideIcons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? LucideIcons.eye
                        : LucideIcons.eyeOff,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              validator: (value) {
                return FormValidators.required(
                  value,
                  message: 'Molimo unesite lozinku',
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onForgotPassword,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    'Zaboravili ste lozinku?',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _ErrorBanner(message: errorMessage!),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white70,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(LucideIcons.logIn, size: 16),
                label: Text('PRIJAVI SE',
                    style: AppTextStyles.buttonMd
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorDim,
        borderRadius: AppSpacing.smallRadius,
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
