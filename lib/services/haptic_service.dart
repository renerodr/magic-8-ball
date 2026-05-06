import 'package:flutter/services.dart';

class HapticService {
  Future<void> onShake() => HapticFeedback.mediumImpact();

  Future<void> onReveal() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.lightImpact();
  }

  Future<void> onError() => HapticFeedback.heavyImpact();
}
