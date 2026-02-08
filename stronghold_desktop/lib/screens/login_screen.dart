import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'package:stronghold_desktop/screens/admin_dashboard_screen.dart';

import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animations
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Logo scale-in animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoController.forward();

    // Continuous subtle pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Show success state
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Wait to show success animation, then navigate
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e.toString().contains('ACCESS_DENIED')) {
          _errorMessage = 'Pristup odbijen. Samo administratori mogu pristupiti.';
        } else if (e.toString().contains('INVALID_CREDENTIALS')) {
          _errorMessage = 'Neispravan username ili lozinka.';
        } else {
          _errorMessage = 'Greska prilikom prijave. Pokusajte ponovo.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
            ),
          ),

          // Animated background orbs
          const _AnimatedBackground(),

          // Login card
          LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth < 500 ? 20.0 : 40.0;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f0f1a).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: AppShadows.elevatedShadow,
                        ),
                        padding: const EdgeInsets.all(40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo and Title
                              Center(
                                child: AnimatedBuilder(
                                  animation: Listenable.merge([_logoScale, _pulseScale]),
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _logoScale.value * _pulseScale.value,
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.fitness_center,
                                    size: 50,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'STRONGHOLD',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Admin Panel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Username Field
                              Text(
                                'USERNAME',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Unesite vas username',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1a1a2e),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.accent,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Molimo unesite username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              Text(
                                'PASSWORD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Unesite vasu lozinku',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1a1a2e),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.accent,
                                      width: 1,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Molimo unesite password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Remember Me Checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.accent,
                                      side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Zapamti me',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],

                              const SizedBox(height: 10),

                              // Login Button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: _isSuccess
                                        ? [AppColors.success, AppColors.successDark]
                                        : _isLoading
                                            ? [
                                                AppColors.accent.withValues(alpha: 0.6),
                                                AppColors.accentLight.withValues(alpha: 0.6),
                                              ]
                                            : [AppColors.accent, AppColors.accentLight],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isSuccess
                                              ? AppColors.success
                                              : AppColors.accent)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: (_isLoading || _isSuccess) ? null : _handleLogin,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: _isSuccess
                                            ? const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.white, size: 22),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'USPJESNO!',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : _isLoading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                    'PRIJAVI SE',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                      ),
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated background with drifting blurred orbs
// ---------------------------------------------------------------------------

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;

  static const _orbCount = 3;

  // Each orb's base center (fractional, 0-1)
  static const _baseCenters = [
    Offset(0.25, 0.3),
    Offset(0.75, 0.6),
    Offset(0.5, 0.8),
  ];

  // Drift range per orb
  static const _driftRange = [
    Offset(0.08, 0.06),
    Offset(0.06, 0.08),
    Offset(0.07, 0.05),
  ];

  static const _colors = [
    AppColors.accent,
    AppColors.info,
    AppColors.success,
  ];

  static const _opacities = [0.08, 0.05, 0.03];
  static const _radii = [400.0, 350.0, 300.0];
  static const _durations = [15, 18, 20]; // seconds

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_orbCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: _durations[i]),
      )..repeat(reverse: true);
    });

    _animations = List.generate(_orbCount, (i) {
      final base = _baseCenters[i];
      final drift = _driftRange[i];
      return Tween<Offset>(
        begin: Offset(base.dx - drift.dx, base.dy - drift.dy),
        end: Offset(base.dx + drift.dx, base.dy + drift.dy),
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeInOut,
      ));
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (context, _) {
        return CustomPaint(
          painter: _OrbPainter(
            positions: _animations.map((a) => a.value).toList(),
            colors: _colors,
            opacities: _opacities,
            radii: _radii,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.positions,
    required this.colors,
    required this.opacities,
    required this.radii,
  });

  final List<Offset> positions;
  final List<Color> colors;
  final List<double> opacities;
  final List<double> radii;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < positions.length; i++) {
      final center = Offset(
        positions[i].dx * size.width,
        positions[i].dy * size.height,
      );
      final paint = Paint()
        ..color = colors[i].withValues(alpha: opacities[i])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
      canvas.drawCircle(center, radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) => true;
}
