import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_8_ball/models/reading.dart';
import 'package:magic_8_ball/services/history_service.dart';

void main() {
  group('HistoryService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('addReading persists and getReadings retrieves it', () async {
      final service = HistoryService();
      final reading = Reading(
        question: 'Test?',
        answer: 'Yes',
        timestamp: DateTime(2026, 5, 4),
      );

      await service.addReading(reading);
      final results = await service.getReadings();

      expect(results.length, equals(1));
      expect(results.first.answer, equals('Yes'));
    });

    test('getReadings returns newest first', () async {
      final service = HistoryService();
      final older = Reading(question: 'Old', answer: 'No', timestamp: DateTime(2026, 1, 1));
      final newer = Reading(question: 'New', answer: 'Yes', timestamp: DateTime(2026, 6, 1));

      await service.addReading(older);
      await service.addReading(newer);
      final results = await service.getReadings();

      expect(results.first.answer, equals('Yes'));
    });

    test('clearHistory removes all readings', () async {
      final service = HistoryService();
      await service.addReading(
        Reading(question: '', answer: 'Maybe', timestamp: DateTime.now()),
      );
      await service.clearHistory();
      final results = await service.getReadings();
      expect(results, isEmpty);
    });
  });
}
