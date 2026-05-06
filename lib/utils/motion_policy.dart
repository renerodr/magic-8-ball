import 'package:flutter/material.dart';

enum MotionLevel { full, reduced }

class MotionPolicy {
  final MotionLevel level;

  const MotionPolicy(this.level);

  factory MotionPolicy.of(BuildContext context) {
    final prefersReduced = MediaQuery.of(context).accessibleNavigation;
    return MotionPolicy(prefersReduced ? MotionLevel.reduced : MotionLevel.full);
  }

  bool get isReduced => level == MotionLevel.reduced;

  Duration staggerDelay(int index) {
    return isReduced ? Duration.zero : Duration(milliseconds: 50 * index);
  }

  Duration cardEntryDuration() {
    return isReduced ? const Duration(milliseconds: 100) : const Duration(milliseconds: 400);
  }

  Duration revealDuration() {
    return isReduced ? const Duration(milliseconds: 100) : const Duration(milliseconds: 300);
  }

  Duration longDuration() {
    return isReduced ? const Duration(milliseconds: 100) : const Duration(milliseconds: 1500);
  }
}
