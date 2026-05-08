import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/classic_answers.dart';
import '../models/question_category.dart';

class AiService {
  final http.Client _client;
  final String _apiKey;

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'openai/gpt-3.5-turbo';

  AiService({required http.Client client, required String apiKey})
      : _client = client,
        _apiKey = apiKey;

  Future<String> getAnswer({
    required String question,
    QuestionCategory? category,
  }) async {
    try {
      final categoryContext = category != null ? ' ${category.promptContext}' : '';
      final prompt = question.trim().isEmpty
          ? 'Give a single cryptic Magic 8-Ball style fortune (max 8 words, no punctuation).$categoryContext'
          : 'The user asks: "$question".$categoryContext Reply as a Magic 8-Ball oracle with ONE cryptic answer (max 8 words, no punctuation, no explanation).';

      final response = await _client.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://localhost',
          'X-Title': 'Magic8Ball',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices'][0]['message']['content'] as String;
        return content.trim();
      }
      return _fallback();
    } catch (_) {
      return _fallback();
    }
  }

  String _fallback() {
    return kClassicAnswers[Random().nextInt(kClassicAnswers.length)];
  }
}
