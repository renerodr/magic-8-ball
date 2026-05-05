import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/models/reading.dart';

void main() {
  group('Reading', () {
    final timestamp = DateTime(2026, 5, 4, 12, 0);

    test('serialises to JSON and back without loss', () {
      final original = Reading(
        question: 'Will I win?',
        answer: 'Outlook good',
        timestamp: timestamp,
      );
      final json = original.toJson();
      final restored = Reading.fromJson(json);

      expect(restored.question, equals(original.question));
      expect(restored.answer, equals(original.answer));
      expect(restored.timestamp, equals(original.timestamp));
    });

    test('empty question is allowed (user shook without typing)', () {
      final r = Reading(question: '', answer: 'Ask again later', timestamp: timestamp);
      expect(r.question, isEmpty);
    });
  });
}
