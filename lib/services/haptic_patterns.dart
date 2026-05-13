import 'package:flutter/services.dart';

enum HapticPattern {
  shake,
  reveal,
  favorite,
  error,
  streak,
  share,
  buttonPress,
}

class HapticPatterns {
  static Future<void> execute(HapticPattern pattern) async {
    switch (pattern) {
      case HapticPattern.shake:
        await HapticFeedback.mediumImpact();
      case HapticPattern.reveal:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.lightImpact();
      case HapticPattern.favorite:
        await HapticFeedback.selectionClick();
      case HapticPattern.error:
        await HapticFeedback.heavyImpact();
      case HapticPattern.streak:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
      case HapticPattern.share:
        await HapticFeedback.lightImpact();
      case HapticPattern.buttonPress:
        await HapticFeedback.lightImpact();
    }
  }
}
