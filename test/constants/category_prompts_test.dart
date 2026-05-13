import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/constants/category_prompts.dart';
import 'package:magic_8_ball/constants/category_fallbacks.dart';
import 'package:magic_8_ball/models/question_category.dart';

void main() {
  group('CategoryPromptTemplates', () {
    test('every category has a template', () {
      for (final category in QuestionCategory.values) {
        final config = CategoryPromptTemplates.getForCategory(category);
        expect(config, isNotNull);
        expect(config.style, isNotEmpty);
        expect(config.tone, isNotEmpty);
        expect(config.lengthTarget, greaterThan(0));
      }
    });

    test('every category has 20 fallback answers', () {
      for (final category in QuestionCategory.values) {
        final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(category);
        expect(fallbacks.length, equals(20));
      }
    });

    test('general fallbacks match kGeneralFallbacks', () {
      final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(QuestionCategory.general);
      expect(fallbacks, equals(kGeneralFallbacks));
    });

    test('love fallbacks match kLoveFallbacks', () {
      final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(QuestionCategory.love);
      expect(fallbacks, equals(kLoveFallbacks));
    });

    test('career fallbacks match kCareerFallbacks', () {
      final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(QuestionCategory.career);
      expect(fallbacks, equals(kCareerFallbacks));
    });

    test('yesNo fallbacks match kYesNoFallbacks', () {
      final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(QuestionCategory.yesNo);
      expect(fallbacks, equals(kYesNoFallbacks));
    });

    test('daily fallbacks match kDailyFallbacks', () {
      final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(QuestionCategory.daily);
      expect(fallbacks, equals(kDailyFallbacks));
    });

    test('no fallback answer contains punctuation', () {
      for (final category in QuestionCategory.values) {
        final fallbacks = CategoryPromptTemplates.getFallbacksForCategory(category);
        for (final answer in fallbacks) {
          expect(answer, isNot(contains(RegExp(r'[.,!?;:]'))));
        }
      }
    });
  });

  group('CategoryFallbacks', () {
    test('total fallback count is 100', () {
      final all = [
        ...kGeneralFallbacks,
        ...kLoveFallbacks,
        ...kCareerFallbacks,
        ...kYesNoFallbacks,
        ...kDailyFallbacks,
      ];
      expect(all.length, equals(100));
    });

    test('no duplicate answers across categories', () {
      final all = [
        ...kGeneralFallbacks,
        ...kLoveFallbacks,
        ...kCareerFallbacks,
        ...kYesNoFallbacks,
        ...kDailyFallbacks,
      ];
      final unique = all.toSet();
      expect(unique.length, equals(all.length));
    });
  });
}
