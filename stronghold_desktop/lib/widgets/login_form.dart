import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../screens/admin_dashboard_screen.dart';

/// Right-panel login form with email/password, error banner, submit button.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  // Shake animation for error
  late final AnimationController _shakeCtl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _shakeCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.login(
        username: _emailCtl.text.trim(),
        password: _passCtl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        final msg = e.toString();
        if (msg.contains('ACCESS_DENIED')) {
          _error = 'Pristup odbijen. Samo administratori mogu pristupiti.';
        } else if (msg.contains('INVALID_CREDENTIALS')) {
          _error = 'Neispravan username ili lozinka.';
        } else {
          _error = 'Greska prilikom prijave. Pokusajte ponovo.';
        }
      });
      _shakeCtl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl + 16, vertical: AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Dobrodosli nazad', style: AppTextStyles.statLg),
                const SizedBox(height: AppSpacing.sm),
                Text('Prijavite se na administratorski panel',
                    style: AppTextStyles.bodyMd),
                const SizedBox(height: AppSpacing.xxxl + 8),
                _label('KORISNICKO IME'),
                const SizedBox(height: AppSpacing.sm),
                _emailField(),
                const SizedBox(height: AppSpacing.xl),
                _label('LOZINKA'),
                const SizedBox(height: AppSpacing.sm),
                _passwordField(),
                const SizedBox(height: AppSpacing.xxl),
                if (_error != null) ...[
                  _errorBanner(),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _submitButton(),
                const SizedBox(height: AppSpacing.xxxl + 16),
                Center(
                  child: Text('TheStronghold Admin v1.0.0',
                      style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: AppTextStyles.label);

  Widget _emailField() => _FocusGlowField(
        controller: _emailCtl,
        hint: 'Unesite korisnicko ime',
        prefix: LucideIcons.user,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Molimo unesite korisnicko ime' : null,
      );

  Widget _passwordField() => _FocusGlowField(
        controller: _passCtl,
        hint: 'Unesite vasu lozinku',
        prefix: LucideIcons.lock,
        obscure: _obscure,
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Molimo unesite lozinku' : null,
        suffix: IconButton(
          icon: Icon(
            _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
            color: AppColors.textMuted,
            size: 18,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        onSubmitted: (_) => _submit(),
      );

  Widget _errorBanner() => AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) =>
            Transform.translate(offset: Offset(_shakeAnim.value, 0), child: child),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.errorDim,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(_error!,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
            ),
          ]),
        ),
      );

  Widget _submitButton() => _HoverLiftButton(
        loading: _loading,
        onTap: _submit,
      );
}

// ── Focus glow input ────────────────────────────────────────────────────

class _FocusGlowField extends StatefulWidget {
  const _FocusGlowField({
    required this.controller,
    required this.hint,
    required this.prefix,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefix;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_FocusGlowField> createState() => _FocusGlowFieldState();
}

class _FocusGlowFieldState extends State<_FocusGlowField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure,
          onFieldSubmitted: widget.onSubmitted,
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            prefixIcon:
                Icon(widget.prefix, color: AppColors.textMuted, size: 18),
            suffixIcon: widget.suffix,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primaryBorder),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.error),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hover-lift gradient button ──────────────────────────────────────────

class _HoverLiftButton extends StatefulWidget {
  const _HoverLiftButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_HoverLiftButton> createState() => _HoverLiftButtonState();
}

class _HoverLiftButtonState extends State<_HoverLiftButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
              0, _hover && !widget.loading ? -1 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            gradient: LinearGradient(
              colors: widget.loading
                  ? [
                      AppColors.primary.withValues(alpha: 0.6),
                      AppColors.secondary.withValues(alpha: 0.6),
                    ]
                  : [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                    alpha: _hover && !widget.loading ? 0.4 : 0.25),
                blurRadius: _hover && !widget.loading ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Prijavljivanje...',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: Colors.white)),
                  ])
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Sign In',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: Colors.white, fontSize: 15)),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(LucideIcons.arrowRight,
                        color: Colors.white, size: 18),
                  ]),
          ),
        ),
      ),
    );
  }
}
