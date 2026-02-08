import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../utils/input_decoration_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _isLoading = false;
  bool _codeSent = false;
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _showFeedback(
      {required bool isSuccess, required String message}) async {
    if (isSuccess) {
      await showSuccessFeedback(context, message);
    } else {
      await showErrorFeedback(context, message);
    }
  }

  Future<void> _handleSendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeSent = true;
      });
      await _showFeedback(
          isSuccess: true, message: 'Kod je poslan na vasu email adresu');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final error =
          ref.read(authProvider).error ?? 'Greska prilikom slanja koda';
      await _showFeedback(isSuccess: false, message: error);
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showFeedback(
          isSuccess: true,
          message: 'Kod je ponovo poslan na vasu email adresu');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final error =
          ref.read(authProvider).error ?? 'Greska prilikom slanja koda';
      await _showFeedback(isSuccess: false, message: error);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: _emailCtrl.text.trim(),
            code: _codeCtrl.text.trim(),
            newPassword: _newPasswordCtrl.text,
          );
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showFeedback(
          isSuccess: true, message: 'Lozinka uspjesno resetovana');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final error = ref.read(authProvider).error ??
          'Greska prilikom resetovanja lozinke';
      await _showFeedback(isSuccess: false, message: error);
    }
  }

  Widget _eyeToggle(bool obscure, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(obscure ? LucideIcons.eye : LucideIcons.eyeOff,
          color: AppColors.textMuted, size: 20),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.arrowLeft,
                        color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text('Zaboravljena lozinka',
                        style: AppTextStyles.headingMd,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDim,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          _codeSent ? LucideIcons.keyRound : LucideIcons.mail,
                          size: 48,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _codeSent
                          ? 'Unesite kod i novu lozinku'
                          : 'Unesite email adresu vaseg racuna',
                      style: AppTextStyles.bodyLg
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child:
                          !_codeSent ? _buildEmailStep() : _buildResetStep(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('EMAIL', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _emailCtrl,
            style:
                AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendCode(),
            decoration: buildStrongholdInputDecoration(
                hintText: 'Unesite email adresu',
                prefixIcon: LucideIcons.mail),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Molimo unesite email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Unesite ispravnu email adresu';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'POSALJI KOD',
            icon: LucideIcons.send,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleSendCode,
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('KOD', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _codeCtrl,
            style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary, letterSpacing: 8),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: buildStrongholdInputDecoration(
                    hintText: '------', prefixIcon: LucideIcons.hash)
                .copyWith(counterText: ''),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Molimo unesite kod';
              if (value.length != 6) return 'Kod mora imati 6 cifara';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('NOVA LOZINKA', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _newPasswordCtrl,
            obscureText: _obscurePassword,
            style:
                AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            textInputAction: TextInputAction.next,
            decoration: buildStrongholdInputDecoration(
              hintText: 'Unesite novu lozinku',
              prefixIcon: LucideIcons.lock,
              suffixIcon: _eyeToggle(_obscurePassword,
                  () => setState(() => _obscurePassword = !_obscurePassword)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Molimo unesite novu lozinku';
              }
              if (value.length < 6) {
                return 'Lozinka mora imati najmanje 6 karaktera';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('POTVRDITE LOZINKU', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscureConfirm,
            style:
                AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: buildStrongholdInputDecoration(
              hintText: 'Ponovite novu lozinku',
              prefixIcon: LucideIcons.lock,
              suffixIcon: _eyeToggle(_obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Molimo potvrdite lozinku';
              }
              if (value != _newPasswordCtrl.text) {
                return 'Lozinke se ne podudaraju';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'RESETUJ LOZINKU',
            icon: LucideIcons.keyRound,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleResetPassword,
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : _handleResendCode,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text('Posalji kod ponovo',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
