import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _usernameFocused = false;
  bool _passwordFocused = false;

  // Intro animations
  late AnimationController _logoAnimController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _glowOpacity;

  late AnimationController _formAnimController;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  // Exit animations
  late AnimationController _exitAnimController;
  late Animation<double> _exitFormFade;
  late Animation<double> _exitShieldScale;
  late Animation<double> _exitShieldFade;
  late Animation<double> _exitOverlayOpacity;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    _usernameFocus.addListener(() {
      setState(() => _usernameFocused = _usernameFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });

    // Intro — logo
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoFade = CurvedAnimation(
      parent: _logoAnimController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Intro — form
    _formAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formFade = CurvedAnimation(
      parent: _formAnimController,
      curve: Curves.easeOut,
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimController,
      curve: Curves.easeOut,
    ));

    // Exit
    _exitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _exitFormFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitAnimController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );
    _exitShieldScale = Tween<double>(begin: 1.0, end: 18.0).animate(
      CurvedAnimation(
        parent: _exitAnimController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInCubic),
      ),
    );
    _exitShieldFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitAnimController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
    _exitOverlayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitAnimController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _exitAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(authStateProvider.notifier).completeLogin();
      }
    });

    _logoAnimController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _formAnimController.forward();
    });
  }

  @override
  void dispose() {
    _logoAnimController.dispose();
    _formAnimController.dispose();
    _exitAnimController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) return;

    final success =
        await ref.read(authStateProvider.notifier).login(username, password);
    if (success && mounted) {
      setState(() => _isExiting = true);
      _exitAnimController.forward();
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isFocused ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: const Color(0xFF141414),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffix,
            ),
            onSubmitted: (_) => _handleLogin(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _exitAnimController,
        builder: (context, child) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0F0F),
                Color(0xFF0A0A0A),
                Color(0xFF110D0A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Grid pattern
              Positioned.fill(
                child: CustomPaint(painter: _GridPatternPainter()),
              ),
              // Glow behind logo
              Center(
                child: AnimatedBuilder(
                  animation: _glowOpacity,
                  builder: (context, _) => Transform.translate(
                    offset: Offset(0, _isExiting ? 0 : -120),
                    child: Transform.scale(
                      scale: _isExiting ? _exitShieldScale.value : 1.0,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(
                                  alpha: 0.07 * _glowOpacity.value),
                              AppColors.primary.withValues(
                                  alpha: 0.02 * _glowOpacity.value),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Shield + brand — zooms on exit
                      Opacity(
                        opacity: _isExiting ? _exitShieldFade.value : 1.0,
                        child: Transform.scale(
                          scale:
                              _isExiting ? _exitShieldScale.value : 1.0,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 72,
                                    height: 80,
                                    child: CustomPaint(
                                        painter: _ShieldLogoPainter()),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'STRONGHOLD',
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Form — fades out on exit
                      Opacity(
                        opacity: _isExiting ? _exitFormFade.value : 1.0,
                        child: FadeTransition(
                          opacity: _formFade,
                          child: SlideTransition(
                            position: _formSlide,
                            child: SizedBox(
                              width: 360,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocus,
                                    isFocused: _usernameFocused,
                                    label: 'KORISNICKO IME',
                                    hint: 'Unesite korisnicko ime',
                                  ),
                                  const SizedBox(height: 22),
                                  _buildField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    isFocused: _passwordFocused,
                                    label: 'LOZINKA',
                                    hint: 'Unesite lozinku',
                                    obscure: _obscurePassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                    ),
                                  ),
                                  if (authState.error != null) ...[
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.06),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.error
                                              .withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: Text(
                                        authState.error!,
                                        style:
                                            AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF6B35),
                                            Color(0xFFE85D2A),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.25),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: authState.isLoading ||
                                                _isExiting
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: authState.isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color:
                                                      AppColors.textPrimary,
                                                ),
                                              )
                                            : Text(
                                                'Prijavi se',
                                                style: AppTextStyles.button
                                                    .copyWith(
                                                        fontSize: 15),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Dark overlay that fades in at the end
              if (_isExiting)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: AppColors.background
                          .withValues(alpha: _exitOverlayOpacity.value),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Geometric shield logo
class _ShieldLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shieldPath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.15)
      ..lineTo(w, h * 0.55)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.55)
      ..lineTo(0, h * 0.15)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x33FF6B35), Color(0x0DFF6B35)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(shieldPath, fillPaint);

    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(shieldPath, borderPaint);

    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(w * 0.2, h * 0.4),
      Offset(w * 0.8, h * 0.4),
      linePaint,
    );

    final chevronPath = Path()
      ..moveTo(w * 0.25, h * 0.28)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.75, h * 0.28);
    canvas.drawPath(chevronPath, linePaint..strokeWidth = 1.2);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.5),
      Offset(w * 0.5, h * 0.72),
      linePaint..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Subtle grid pattern
class _GridPatternPainter extends CustomPainter {
  final double opacity;

  _GridPatternPainter({this.opacity = 0.02});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
