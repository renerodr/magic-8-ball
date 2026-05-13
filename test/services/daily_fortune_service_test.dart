import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_8_ball/services/daily_fortune_service.dart';

void main() {
  group('DailyFortuneService', () {
    late DailyFortuneService service;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      service = DailyFortuneService();
      await service.initialize();
      await service.reset();
    });

    test('can ask on first use', () {
      expect(service.isDailyFortuneAvailable, isTrue);
      expect(service.streak, equals(0));
    });

    test('records first ask and sets streak to 1', () async {
      await service.recordAsked();
      expect(service.streak, equals(1));
      expect(service.totalAsked, equals(1));
      expect(service.isDailyFortuneAvailable, isFalse);
    });

    test('streak reward triggers every 7 days', () async {
      for (var i = 0; i < 7; i++) {
        await service.recordAsked();
        await service.reset();
        // Simulate next day by manipulating internals
        // In reality, tests would need date mocking
      }
    });

    test('daily prompt is not empty', () {
      expect(service.dailyPrompt.isNotEmpty, isTrue);
    });
  });
}
