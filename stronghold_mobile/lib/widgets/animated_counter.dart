import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

class AnimatedCounter extends StatefulWidget {
  final int target;
  final Duration duration;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final String Function(int)? formatter;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.formatter,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = IntTween(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _animation = IntTween(
        begin: _animation.value,
        end: widget.target,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final formatted = widget.formatter?.call(_animation.value) ??
            _animation.value.toString();
        return Text(
          '${widget.prefix}$formatted${widget.suffix}',
          style: widget.style ?? AppTextStyles.stat,
        );
      },
    );
  }
}
