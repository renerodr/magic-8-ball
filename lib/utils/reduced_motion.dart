import 'package:flutter/material.dart';

extension ReducedMotionExtension on BuildContext {
  bool get prefersReducedMotion {
    return MediaQuery.of(this).accessibleNavigation;
  }
}

class ReducedMotionBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool reducedMotion) builder;

  const ReducedMotionBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).accessibleNavigation;
    return builder(context, reducedMotion);
  }
}
