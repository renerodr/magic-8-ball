import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/oracle_persona.dart';
import '../models/question_category.dart';
import '../constants/category_prompts.dart';
import 'oracle_context_service.dart';

class AiService {
  final http.Client _client;
  final String _apiKey;
  final OracleContextService _contextService;

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'openai/gpt-3.5-turbo';

  AiService({
    required http.Client client,
    required String apiKey,
    OracleContextService? contextService,
  })  : _client = client,
        _apiKey = apiKey,
        _contextService = contextService ?? OracleContextService();

  Future<String> getAnswer({
    required String question,
    QuestionCategory? category,
    OraclePersona? persona,
    int? streak,
  }) async {
    try {
      final personaConfig = persona ?? OraclePersona.spark;
      final categoryConfig = CategoryPromptTemplates.getForCategory(
        category ?? QuestionCategory.general,
      );
      final context = _contextService.buildContextForPrompt(streak: streak);

      final systemPrompt = _buildSystemPrompt(
        persona: personaConfig,
        categoryConfig: categoryConfig,
        context: context,
      );

      final prompt = question.trim().isEmpty
          ? 'Give a single cryptic Magic 8-Ball style fortune.'
          : 'The user asks: "$question"';

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
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 50,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices'][0]['message']['content'] as String;
        final processed = _postProcess(
          content,
          persona: personaConfig,
          category: category ?? QuestionCategory.general,
        );
        _contextService.recordExchange(question, processed);
        return processed;
      }
      return _fallback(category ?? QuestionCategory.general);
    } catch (_) {
      return _fallback(category ?? QuestionCategory.general);
    }
  }

  String _buildSystemPrompt({
    required OraclePersona persona,
    required CategoryPromptConfig categoryConfig,
    required String context,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('You are ${persona.name}, a ${persona.description} Magic 8-Ball oracle.');
    buffer.writeln('Style: ${persona.style}');
    buffer.writeln('Tone: ${categoryConfig.tone}');
    buffer.writeln('Category: ${categoryConfig.style}');
    if (context.isNotEmpty) {
      buffer.writeln(context);
    }
    buffer.writeln();
    buffer.writeln('Rules:');
    buffer.writeln('- Answer in ${persona.lengthTarget} words max');
    buffer.writeln('- No punctuation');
    buffer.writeln('- No explanations');
    buffer.writeln('- Be cryptic but helpful');
    return buffer.toString();
  }

  String _postProcess(
    String answer, {
    required OraclePersona persona,
    required QuestionCategory category,
  }) {
    var processed = answer;

    final maxWords = persona.maxWords;
    final words = processed.split(RegExp(r'\s+'));
    if (words.length > maxWords) {
      processed = words.take(maxWords).join(' ');
    }

    processed = processed
        .replaceAll(RegExp(r'^(I think|I believe|I feel|Perhaps|Maybe|Probably),?\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    processed = processed.replaceAll(RegExp(r'[.,!?;:]'), '');

    if (_contextService.isRecentAnswer(processed)) {
      return _fallback(category);
    }

    if (processed.isEmpty) {
      return _fallback(category);
    }

    return processed;
  }

  String _fallback(QuestionCategory category) {
    final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(category);
    return fallbacks[Random().nextInt(fallbacks.length)];
  }

  OracleContextService get contextService => _contextService;
}
