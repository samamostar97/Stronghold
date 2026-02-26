import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/motion.dart';

/// Centered login form with integrated branding — glass card over particle bg.
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
      context.go('/dashboard');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (e.isUnauthorized) {
          _error = 'Neispravan username ili lozinka.';
        } else if (e.isForbidden) {
          _error = e.message;
        } else if (e.isServerError) {
          _error = 'Greska na serveru. Pokusajte ponovo.';
        } else {
          _error = e.message.isNotEmpty
              ? e.message
              : 'Greska prilikom prijave. Pokusajte ponovo.';
        }
      });
      _shakeCtl.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Greska prilikom prijave. Pokusajte ponovo.';
      });
      _shakeCtl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Branding
              _branding(),
              const SizedBox(height: AppSpacing.xxxl),
              // Glass form card
              Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppColors.deepBlue.withOpacity(0.55),
                  borderRadius: AppSpacing.cardRadius,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Dobrodosli nazad',
                              style: AppTextStyles.pageTitle
                                  .copyWith(color: Colors.white))
                          .animate()
                          .fadeIn(
                              duration: Motion.smooth, curve: Motion.curve)
                          .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: Motion.smooth),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Prijavite se na administratorski panel',
                              style: AppTextStyles.bodySecondary
                                  .copyWith(color: AppColors.textMuted))
                          .animate(delay: 100.ms)
                          .fadeIn(
                              duration: Motion.smooth, curve: Motion.curve),
                      const SizedBox(height: AppSpacing.huge),
                      _label('KORISNICKO IME'),
                      const SizedBox(height: AppSpacing.sm),
                      _emailField(),
                      const SizedBox(height: AppSpacing.lg),
                      _label('LOZINKA'),
                      const SizedBox(height: AppSpacing.sm),
                      _passwordField(),
                      const SizedBox(height: AppSpacing.xl),
                      if (_error != null) ...[
                        _errorBanner(),
                        const SizedBox(height: AppSpacing.base),
                      ],
                      _submitButton(),
                    ],
                  ),
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
                  .slideY(
                      begin: 0.06,
                      end: 0,
                      duration: Motion.smooth,
                      curve: Motion.curve),
              const SizedBox(height: AppSpacing.xl),
              Text('TheStronghold Admin v1.0.0',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _branding() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: AppSpacing.panelRadius,
          boxShadow: AppColors.cyanGlow,
        ),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.shield, color: Colors.white, size: 32),
      )
          .animate()
          .fadeIn(duration: Motion.dramatic, curve: Motion.curve)
          .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: Motion.dramatic,
              curve: Motion.curve),
      const SizedBox(height: AppSpacing.lg),
      Text('TheStronghold',
              style: AppTextStyles.heroTitle.copyWith(color: Colors.white))
          .animate(delay: 200.ms)
          .fadeIn(duration: Motion.smooth, curve: Motion.curve)
          .slideY(begin: 0.2, end: 0, duration: Motion.smooth),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'ADMINISTRATORSKI CENTAR',
        style: AppTextStyles.overline.copyWith(
          color: AppColors.cyan,
          letterSpacing: 3,
        ),
      )
          .animate(delay: 400.ms)
          .fadeIn(duration: Motion.smooth, curve: Motion.curve),
    ]);
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.overline.copyWith(color: AppColors.cyan));

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
        builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnim.value, 0), child: child),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.15),
            borderRadius: AppSpacing.badgeRadius,
            border: Border.all(color: AppColors.danger.withOpacity(0.4)),
          ),
          child: Row(children: [
            const Icon(LucideIcons.alertCircle,
                color: AppColors.danger, size: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(_error!,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.danger)),
            ),
          ]),
        ),
      );

  Widget _submitButton() => _HoverLiftButton(
        loading: _loading,
        onTap: _submit,
      );
}

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
      duration: Motion.fast,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.smallRadius,
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.electric.withOpacity(0.2),
                  blurRadius: 16,
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
          style: const TextStyle(color: Colors.white),
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.base),
            prefixIcon:
                Icon(widget.prefix, color: AppColors.textMuted, size: 18),
            suffixIcon: widget.suffix,
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1)),
              borderRadius: AppSpacing.smallRadius,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.electric),
              borderRadius: AppSpacing.smallRadius,
            ),
            errorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.danger.withOpacity(0.5)),
              borderRadius: AppSpacing.smallRadius,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.danger),
              borderRadius: AppSpacing.smallRadius,
            ),
            errorStyle: const TextStyle(color: AppColors.danger),
          ),
        ),
      ),
    );
  }
}

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
          duration: Motion.fast,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
              0, _hover && !widget.loading ? -1 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.buttonRadius,
            gradient: LinearGradient(
              colors: widget.loading
                  ? [
                      AppColors.electric.withOpacity(0.6),
                      AppColors.cyan.withOpacity(0.6),
                    ]
                  : [AppColors.electric, AppColors.cyan],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electric.withOpacity(
                    _hover && !widget.loading ? 0.35 : 0.25),
                blurRadius: _hover && !widget.loading ? 24 : 16,
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
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white)),
                  ])
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Prijavi se',
                        style: AppTextStyles.bodyMedium
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
