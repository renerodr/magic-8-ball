import '../models/question_category.dart';
import 'category_fallbacks.dart';

class CategoryPromptConfig {
  final String style;
  final int lengthTarget;
  final String tone;
  final List<String> fallbackSet;

  const CategoryPromptConfig({
    required this.style,
    required this.lengthTarget,
    required this.tone,
    required this.fallbackSet,
  });
}

class CategoryPromptTemplates {
  static const Map<QuestionCategory, CategoryPromptConfig> templates = {
    QuestionCategory.general: CategoryPromptConfig(
      style: 'General fortune',
      lengthTarget: 8,
      tone: 'Neutral but helpful',
      fallbackSet: kGeneralFallbacks,
    ),
    QuestionCategory.love: CategoryPromptConfig(
      style: 'Love and relationships',
      lengthTarget: 8,
      tone: 'Warm, empathetic, romantic',
      fallbackSet: kLoveFallbacks,
    ),
    QuestionCategory.career: CategoryPromptConfig(
      style: 'Career and work',
      lengthTarget: 8,
      tone: 'Professional, encouraging, practical',
      fallbackSet: kCareerFallbacks,
    ),
    QuestionCategory.yesNo: CategoryPromptConfig(
      style: 'Yes or no question',
      lengthTarget: 4,
      tone: 'Direct, clear',
      fallbackSet: kYesNoFallbacks,
    ),
    QuestionCategory.daily: CategoryPromptConfig(
      style: 'Daily fortune',
      lengthTarget: 8,
      tone: 'Optimistic, actionable',
      fallbackSet: kDailyFallbacks,
    ),
  };

  static CategoryPromptConfig getForCategory(QuestionCategory category) {
    return templates[category] ?? templates[QuestionCategory.general]!;
  }

  static List<String> getFallbacksForCategory(QuestionCategory category) {
    return getForCategory(category).fallbackSet;
  }
}
