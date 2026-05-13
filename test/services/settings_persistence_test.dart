import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_8_ball/services/speech_service.dart';
import 'package:magic_8_ball/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeechService persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadPreferences loads persisted disabled state', () async {
      SharedPreferences.setMockInitialValues({'voice_input_enabled': false});
      final service = SpeechService();
      await service.loadPreferences();
      expect(service.isEnabled, isFalse);
    });

    test('loadPreferences loads persisted enabled state', () async {
      SharedPreferences.setMockInitialValues({'voice_input_enabled': true});
      final service = SpeechService();
      await service.loadPreferences();
      expect(service.isEnabled, isTrue);
    });

    test('loadPreferences defaults to enabled when not set', () async {
      SharedPreferences.setMockInitialValues({});
      final service = SpeechService();
      await service.loadPreferences();
      expect(service.isEnabled, isTrue);
    });

    test('setEnabled persists value', () async {
      final service = SpeechService();
      await service.setEnabled(false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('voice_input_enabled'), isFalse);
    });
  });

  group('HapticService persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initialize loads persisted disabled state', () async {
      SharedPreferences.setMockInitialValues({'haptics_enabled': false});
      final service = HapticService();
      await service.initialize();
      expect(service.isEnabled, isFalse);
    });

    test('initialize loads persisted enabled state', () async {
      SharedPreferences.setMockInitialValues({'haptics_enabled': true});
      final service = HapticService();
      await service.initialize();
      expect(service.isEnabled, isTrue);
    });

    test('initialize defaults to enabled when not set', () async {
      SharedPreferences.setMockInitialValues({});
      final service = HapticService();
      await service.initialize();
      expect(service.isEnabled, isTrue);
    });

    test('setEnabled persists value', () async {
      final service = HapticService();
      await service.setEnabled(false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('haptics_enabled'), isFalse);
    });
  });
}
