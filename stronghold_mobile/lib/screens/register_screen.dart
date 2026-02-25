import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../utils/input_decoration_utils.dart';
import '../utils/validators.dart';
import 'package:stronghold_core/stronghold_core.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String? _usernameError, _emailError, _phoneError;
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    _usernameError = null;
    _emailError = null;
    _phoneError = null;
  }

  void _setFieldError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('username')) {
      _usernameError = message;
    } else if (lower.contains('email')) {
      _emailError = message;
    } else if (lower.contains('broj')) {
      _phoneError = message;
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _clearFieldErrors());
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            username: _usernameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (!mounted) return;
      final user = ref.read(authProvider).user;
      if (user != null) {
        context.go('/login-success');
      }
    } catch (e) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        setState(() => _setFieldError(error));
        _formKey.currentState!.validate();
      }
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
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleBackground()),
          SafeArea(
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Registracija',
                          style: AppTextStyles.headingMd,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDim,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.userPlus,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Kreirajte novi racun',
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _field(
                                  'IME',
                                  _firstNameCtrl,
                                  LucideIcons.user,
                                  'Unesite vase ime',
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) => FormValidators.stringLength(
                                    v,
                                    min: 2,
                                    max: 100,
                                    requiredMessage: 'Molimo unesite ime',
                                    minMessage:
                                        'Ime mora imati najmanje 2 karaktera',
                                    maxMessage:
                                        'Ime moze imati maksimalno 100 karaktera',
                                  ),
                                ),
                                _field(
                                  'PREZIME',
                                  _lastNameCtrl,
                                  LucideIcons.user,
                                  'Unesite vase prezime',
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) => FormValidators.stringLength(
                                    v,
                                    min: 2,
                                    max: 100,
                                    requiredMessage: 'Molimo unesite prezime',
                                    minMessage:
                                        'Prezime mora imati najmanje 2 karaktera',
                                    maxMessage:
                                        'Prezime moze imati maksimalno 100 karaktera',
                                  ),
                                ),
                                _field(
                                  'EMAIL',
                                  _emailCtrl,
                                  LucideIcons.mail,
                                  'Unesite email adresu',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (_emailError != null) return _emailError;
                                    return FormValidators.email(v);
                                  },
                                ),
                                _field(
                                  'BROJ TELEFONA',
                                  _phoneCtrl,
                                  LucideIcons.phone,
                                  '061 123 456',
                                  keyboardType: TextInputType.phone,
                                  validator: (v) {
                                    if (_phoneError != null) return _phoneError;
                                    return FormValidators.phoneBiH(v);
                                  },
                                ),
                                _field(
                                  'KORISNICKO IME',
                                  _usernameCtrl,
                                  LucideIcons.user,
                                  'Odaberite korisnicko ime',
                                  validator: (v) {
                                    if (_usernameError != null) {
                                      return _usernameError;
                                    }
                                    return FormValidators.stringLength(
                                      v,
                                      min: 3,
                                      max: 50,
                                      requiredMessage:
                                          'Molimo unesite korisnicko ime',
                                      minMessage:
                                          'Korisnicko ime mora imati najmanje 3 karaktera',
                                      maxMessage:
                                          'Korisnicko ime moze imati maksimalno 50 karaktera',
                                    );
                                  },
                                ),
                                Text('LOZINKA', style: AppTextStyles.label),
                                const SizedBox(height: AppSpacing.sm),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  decoration: buildStrongholdInputDecoration(
                                    hintText: 'Kreirajte lozinku',
                                    prefixIcon: LucideIcons.lock,
                                    suffixIcon: _eyeToggle(
                                      _obscurePassword,
                                      () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    return FormValidators.password(
                                      v,
                                      requiredMessage: 'Molimo unesite lozinku',
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'POTVRDITE LOZINKU',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextFormField(
                                  controller: _confirmPasswordCtrl,
                                  obscureText: _obscureConfirm,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleRegister(),
                                  decoration: buildStrongholdInputDecoration(
                                    hintText: 'Ponovite lozinku',
                                    prefixIcon: LucideIcons.lock,
                                    suffixIcon: _eyeToggle(
                                      _obscureConfirm,
                                      () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    return FormValidators.confirmPassword(
                                      v,
                                      _passwordCtrl.text,
                                      requiredMessage:
                                          'Molimo potvrdite lozinku',
                                    );
                                  },
                                ),
                                if (errorMessage != null &&
                                    _usernameError == null &&
                                    _emailError == null &&
                                    _phoneError == null) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorDim,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
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
                                            errorMessage,
                                            style: AppTextStyles.bodySm
                                                .copyWith(
                                                  color: AppColors.error,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xl),
                                GradientButton(
                                  label: 'REGISTRUJ SE',
                                  icon: LucideIcons.userPlus,
                                  isLoading: isLoading,
                                  onPressed: isLoading ? null : _handleRegister,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vec imate racun? ',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Prijavite se',
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData prefixIcon,
    String hint, {
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          textInputAction: TextInputAction.next,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          decoration: buildStrongholdInputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
          ),
          validator: validator,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
