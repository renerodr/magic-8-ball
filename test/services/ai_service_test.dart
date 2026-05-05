import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:magic_8_ball/services/ai_service.dart';
import 'package:magic_8_ball/constants/classic_answers.dart';

void main() {
  group('AiService', () {
    test('returns trimmed AI answer on 200 response', () async {
      final mockClient = MockClient((request) async {
        final body = {
          'choices': [
            {
              'message': {'content': '  Signs point to yes  '}
            }
          ]
        };
        return http.Response(jsonEncode(body), 200);
      });

      final service = AiService(client: mockClient, apiKey: 'test-key');
      final answer = await service.getAnswer(question: 'Will I succeed?');
      expect(answer, equals('Signs point to yes'));
    });

    test('returns a classic answer when API returns non-200', () async {
      final mockClient = MockClient((_) async => http.Response('error', 429));

      final service = AiService(client: mockClient, apiKey: 'test-key');
      final answer = await service.getAnswer(question: 'Will I fail?');
      expect(kClassicAnswers, contains(answer));
    });

    test('returns a classic answer when network throws', () async {
      final mockClient = MockClient((_) async => throw Exception('no network'));

      final service = AiService(client: mockClient, apiKey: 'test-key');
      final answer = await service.getAnswer(question: '');
      expect(kClassicAnswers, contains(answer));
    });
  });
}
