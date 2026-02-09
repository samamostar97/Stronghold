import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../utils/input_decoration_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/particle_background.dart';
import 'register_screen.dart';
import 'login_success_screen.dart';
import 'forgot_password_screen.dart';

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
      await ref.read(authProvider.notifier).login(
            _usernameCtrl.text.trim(),
            _passwordCtrl.text,
          );
      if (!mounted) return;
      final user = ref.read(authProvider).user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginSuccessScreen(),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.dumbbell,
                          size: 60, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('STRONGHOLD',
                        style: AppTextStyles.stat.copyWith(letterSpacing: 4)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Dobrodosli nazad',
                        style: AppTextStyles.bodyLg
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('KORISNICKO IME', style: AppTextStyles.label),
                            const SizedBox(height: AppSpacing.sm),
                            TextFormField(
                              controller: _usernameCtrl,
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.textPrimary),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: buildStrongholdInputDecoration(
                                hintText: 'Unesite korisnicko ime',
                                prefixIcon: LucideIcons.user,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Molimo unesite korisnicko ime';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text('LOZINKA', style: AppTextStyles.label),
                            const SizedBox(height: AppSpacing.sm),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.textPrimary),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: buildStrongholdInputDecoration(
                                hintText: 'Unesite lozinku',
                                prefixIcon: LucideIcons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? LucideIcons.eye
                                        : LucideIcons.eyeOff,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword =
                                          !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Molimo unesite lozinku';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen()),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xs),
                                  child: Text('Zaboravili ste lozinku?',
                                      style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.textSecondary)),
                                ),
                              ),
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.errorDim,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.alertCircle,
                                        color: AppColors.error, size: 18),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(errorMessage,
                                          style: AppTextStyles.bodySm.copyWith(
                                              color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            GradientButton(
                              label: 'PRIJAVI SE',
                              icon: LucideIcons.logIn,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _handleLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Nemate racun? ',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: Text('Registrujte se',
                              style: AppTextStyles.bodyBold
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
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
