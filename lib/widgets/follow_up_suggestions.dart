import 'package:flutter/material.dart';
import '../models/question_category.dart';

class FollowUpSuggestions extends StatelessWidget {
  final QuestionCategory category;
  final ValueChanged<String> onSuggestionTap;

  const FollowUpSuggestions({
    super.key,
    required this.category,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _getSuggestionsForCategory(category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) => ChoiceChip(
        label: Text(
          suggestion,
          style: const TextStyle(fontSize: 12),
        ),
        onSelected: (_) => onSuggestionTap(suggestion),
        selected: false,
        backgroundColor: isDark
            ? const Color(0xFF252530)
            : Colors.white,
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
      )).toList(),
    );
  }

  List<String> _getSuggestionsForCategory(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.general:
        return ['What should I focus on?', 'Give me a sign', 'What is coming next?'];
      case QuestionCategory.love:
        return ['Will I find love?', 'Is my relationship strong?', 'What should I know?'];
      case QuestionCategory.career:
        return ['Should I change jobs?', 'Will I succeed?', 'What is my next step?'];
      case QuestionCategory.yesNo:
        return ['Ask why', 'What if?', 'Give me more detail'];
      case QuestionCategory.daily:
        return ['What is special about today?', 'Any challenges?', 'Best moment of the day?'];
    }
  }
}
