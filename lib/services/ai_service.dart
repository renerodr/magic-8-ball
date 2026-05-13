import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
  static const _maxContextChars = 400;

  @visibleForTesting
  static int get maxContextCharsForTest => _maxContextChars;

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
        context: _truncateContext(context),
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
        final normalizedQuestion = question.trim();
        if (normalizedQuestion.isNotEmpty && processed.isNotEmpty) {
          _contextService.recordExchange(normalizedQuestion, processed);
        }
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

    processed = processed
        .replaceAll(RegExp(r'^(I think|I believe|I feel|Perhaps|Maybe|Probably),?\s*'), '')
        .replaceAll(RegExp(r'[\u201C\u201D]'), '"')
        .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
        .replaceAll(RegExp(r'[\u2013\u2014]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final maxWords = persona.maxWords;
    final words = processed.split(RegExp(r'\s+'));
    if (words.length > maxWords) {
      processed = words.take(maxWords).join(' ');
    }

    processed = processed
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('—', '')
        .replaceAll('–', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('!', '')
        .replaceAll('?', '')
        .replaceAll(';', '')
        .replaceAll(':', '');

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

  String _truncateContext(String context) {
    if (context.length <= _maxContextChars) return context;
    final truncated = context.substring(0, _maxContextChars);
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > _maxContextChars * 0.8) {
      return truncated.substring(0, lastSpace) + '...';
    }
    return truncated + '...';
  }

  OracleContextService get contextService => _contextService;
}
