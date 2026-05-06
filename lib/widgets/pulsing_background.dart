import 'package:flutter/material.dart';

class PulsingBackground extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final bool isDark;

  const PulsingBackground({
    super.key,
    required this.child,
    required this.glowColor,
    required this.isDark,
  });

  @override
  State<PulsingBackground> createState() => _PulsingBackgroundState();
}

class _PulsingBackgroundState extends State<PulsingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.05, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final alpha = reducedMotion ? 0.08 : _pulseAnimation.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.15),
              radius: 0.9,
              colors: [
                widget.glowColor.withValues(alpha: widget.isDark ? alpha : alpha * 1.2),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
