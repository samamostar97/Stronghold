import 'dart:math';
import 'package:flutter/material.dart';

/// Animated particle network background with drifting dots
/// connected by lines when within proximity.
class ParticleBackground extends StatefulWidget {
  final Color particleColor;
  final int particleCount;
  final double connectDistance;

  const ParticleBackground({
    super.key,
    this.particleColor = const Color(0xFF22D3EE),
    this.particleCount = 60,
    this.connectDistance = 120.0,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (_) => _Particle(_rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            connectDistance: widget.connectDistance,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x, y, vx, vy, baseAlpha;

  _Particle(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        vx = (rng.nextDouble() - 0.5) * 0.0004,
        vy = (rng.nextDouble() - 0.5) * 0.0004,
        baseAlpha = 0.3 + rng.nextDouble() * 0.5;

  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.connectDistance,
    required this.color,
  });

  final List<_Particle> particles;
  final double connectDistance;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..strokeWidth = 0.5;
    final dotPaint = Paint();

    for (final p in particles) {
      p.update();
    }

    for (int i = 0; i < particles.length; i++) {
      final a = particles[i];
      final ax = a.x * size.width;
      final ay = a.y * size.height;

      for (int j = i + 1; j < particles.length; j++) {
        final b = particles[j];
        final bx = b.x * size.width;
        final by = b.y * size.height;
        final dx = ax - bx;
        final dy = ay - by;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < connectDistance) {
          final alpha = (1.0 - dist / connectDistance) * 0.15;
          linePaint.color = color.withValues(alpha: alpha);
          canvas.drawLine(Offset(ax, ay), Offset(bx, by), linePaint);
        }
      }

      dotPaint.color = color.withValues(alpha: a.baseAlpha * 0.6);
      canvas.drawCircle(Offset(ax, ay), 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
