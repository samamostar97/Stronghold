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
import 'package:stronghold_core/stronghold_core.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: _currentPasswordCtrl.text,
            newPassword: _newPasswordCtrl.text,
          );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _success = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (e) {
      final authState = ref.read(authProvider);
      setState(() {
        _isLoading = false;
        _errorMessage =
            authState.error ??
            'Greska prilikom povezivanja. Provjerite internet konekciju.';
      });
    }
  }

  Widget _eyeToggle(bool obscure, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        obscure ? LucideIcons.eye : LucideIcons.eyeOff,
        color: AppColors.textMuted,
        size: 20,
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Promijeni lozinku',
                      style: AppTextStyles.headingMd.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: (_success ? _buildSuccessView() : _buildFormView())
                    .animate()
                    .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                    .slideY(
                      begin: 0.04,
                      end: 0,
                      duration: Motion.smooth,
                      curve: Motion.curve,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: const BoxDecoration(
              color: AppColors.successDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Lozinka uspjesno promijenjena!',
            style: AppTextStyles.headingSm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.navyBlue, width: 1),
                ),
                child: const Icon(
                  LucideIcons.lock,
                  size: 40,
                  color: AppColors.navyBlue,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('TRENUTNA LOZINKA', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _currentPasswordCtrl,
              obscureText: _obscureCurrent,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.next,
              decoration: buildStrongholdInputDecoration(
                hintText: 'Unesite trenutnu lozinku',
                prefixIcon: LucideIcons.lock,
                suffixIcon: _eyeToggle(
                  _obscureCurrent,
                  () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (value) {
                return FormValidators.required(
                  value,
                  message: 'Molimo unesite trenutnu lozinku',
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('NOVA LOZINKA', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNew,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.next,
              decoration: buildStrongholdInputDecoration(
                hintText: 'Unesite novu lozinku',
                prefixIcon: LucideIcons.keyRound,
                suffixIcon: _eyeToggle(
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (value) {
                final validationError = FormValidators.password(
                  value,
                  requiredMessage: 'Molimo unesite novu lozinku',
                );
                if (validationError != null) {
                  return validationError;
                }

                if (value == _currentPasswordCtrl.text) {
                  return 'Nova lozinka mora biti razlicita od trenutne';
                }

                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('POTVRDI NOVU LOZINKU', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleChangePassword(),
              decoration: buildStrongholdInputDecoration(
                hintText: 'Potvrdite novu lozinku',
                prefixIcon: LucideIcons.keyRound,
                suffixIcon: _eyeToggle(
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) {
                return FormValidators.confirmPassword(
                  value,
                  _newPasswordCtrl.text,
                  requiredMessage: 'Molimo potvrdite novu lozinku',
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorDim,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            GradientButton(
              label: 'PROMIJENI LOZINKU',
              icon: LucideIcons.lock,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleChangePassword,
            ),
          ],
        ),
      ),
    );
  }
}
