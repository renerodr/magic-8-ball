import 'haptic_patterns.dart';

class HapticService {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {}

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> trigger(HapticPattern pattern) async {
    if (!_isEnabled) return;
    try {
      await HapticPatterns.execute(pattern);
    } catch (_) {
      // Haptic failures are non-critical
    }
  }

  // Legacy compatibility methods
  @Deprecated('Use trigger(HapticPattern.shake) instead')
  Future<void> onShake() => trigger(HapticPattern.shake);

  @Deprecated('Use trigger(HapticPattern.reveal) instead')
  Future<void> onReveal() => trigger(HapticPattern.reveal);

  @Deprecated('Use trigger(HapticPattern.error) instead')
  Future<void> onError() => trigger(HapticPattern.error);

  @Deprecated('Use trigger(HapticPattern.buttonPress) instead')
  Future<void> onButtonPress() => trigger(HapticPattern.buttonPress);

  @Deprecated('Use trigger(HapticPattern.favorite) instead')
  Future<void> onSuccess() => trigger(HapticPattern.favorite);

  @Deprecated('Use trigger(HapticPattern.error) instead')
  Future<void> onWarning() => trigger(HapticPattern.error);
}
