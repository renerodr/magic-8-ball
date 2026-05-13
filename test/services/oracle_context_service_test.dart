import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/services/oracle_context_service.dart';
import 'package:magic_8_ball/models/oracle_persona.dart';

void main() {
  group('OracleContextService', () {
    late OracleContextService service;

    setUp(() {
      service = OracleContextService();
    });

    test('defaults to spark persona', () {
      expect(service.currentPersona, equals(OraclePersona.spark));
    });

    test('recordExchange stores question and answer', () {
      service.recordExchange('Will I succeed?', 'Signs point to yes');
      expect(service.recentQuestions, contains('Will I succeed?'));
      expect(service.recentAnswers, contains('Signs point to yes'));
    });

    test('ring buffer caps at 10 entries', () {
      for (var i = 0; i < 15; i++) {
        service.recordExchange('Q$i', 'A$i');
      }
      expect(service.recentQuestions.length, equals(10));
      expect(service.recentAnswers.length, equals(10));
      expect(service.recentQuestions.first, equals('Q5'));
      expect(service.recentAnswers.first, equals('A5'));
    });

    test('isRecentAnswer matches case-insensitively', () {
      service.recordExchange('test', 'Stars Align');
      expect(service.isRecentAnswer('stars align'), isTrue);
      expect(service.isRecentAnswer('STARS ALIGN'), isTrue);
      expect(service.isRecentAnswer('different answer'), isFalse);
    });

    test('buildContextForPrompt includes recent exchanges', () {
      service.recordExchange('Will I?', 'Yes');
      final context = service.buildContextForPrompt();
      expect(context, contains('Will I?'));
      expect(context, contains('Yes'));
    });

    test('buildContextForPrompt includes streak when >= 7', () {
      final context = service.buildContextForPrompt(streak: 7);
      expect(context, contains('7-day streak'));
    });

    test('buildContextForPrompt omits streak when < 7', () {
      final context = service.buildContextForPrompt(streak: 6);
      expect(context, isNot(contains('streak')));
    });

    test('addFavoriteTheme stores themes', () {
      service.addFavoriteTheme('career');
      expect(service.favoriteThemes, contains('career'));
    });

    test('favorite themes caps at 5', () {
      for (var i = 0; i < 7; i++) {
        service.addFavoriteTheme('theme$i');
      }
      expect(service.favoriteThemes.length, equals(5));
    });

    test('clear resets all state', () {
      service.recordExchange('Q', 'A');
      service.addFavoriteTheme('love');
      service.clear();
      expect(service.recentQuestions, isEmpty);
      expect(service.recentAnswers, isEmpty);
      expect(service.favoriteThemes, isEmpty);
    });
  });
}
