import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

/// Tier 1 — Animated count-up number using implicit animation.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.style,
    this.prefix,
    this.suffix,
    this.formatter,
  });

  final int target;
  final Duration duration;
  final Duration delay;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final String Function(int)? formatter;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _buildAnimation();
    _scheduleStart();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _buildAnimation();
      _controller.forward(from: 0);
    }
  }

  void _buildAnimation() {
    _animation = IntTween(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  void _scheduleStart() {
    if (widget.delay == Duration.zero) {
      _controller.forward();
      _started = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
          _started = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? AppTextStyles.statLg;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final val = _started ? _animation.value : 0;
        final formatted = widget.formatter?.call(val) ?? '$val';
        final text = '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}';
        return Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
