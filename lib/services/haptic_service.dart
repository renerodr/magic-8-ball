import 'package:flutter/services.dart';

class HapticService {
  /// Medium impact for physical shake detection.
  Future<void> onShake() => HapticFeedback.mediumImpact();

  /// Double light pulse for answer reveal.
  Future<void> onReveal() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.lightImpact();
  }

  /// Heavy impact for errors or dismissals.
  Future<void> onError() => HapticFeedback.heavyImpact();

  /// Light tap for button press.
  Future<void> onButtonPress() => HapticFeedback.lightImpact();

  /// Selection click for button release.
  Future<void> onButtonRelease() => HapticFeedback.selectionClick();

  /// Success pattern: light then medium.
  Future<void> onSuccess() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// Warning pattern: heavy impact.
  Future<void> onWarning() => HapticFeedback.heavyImpact();
}
