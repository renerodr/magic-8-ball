import 'package:flutter/material.dart';

enum QuestionCategory {
  general('General', Icons.auto_awesome, 'The user asks a general question.'),
  love('Love', Icons.favorite, 'The user asks about love or relationships.'),
  career('Career', Icons.work, 'The user asks about their career or work.'),
  yesNo('Yes/No', Icons.check_circle, 'The user asks a yes or no question.'),
  daily('Daily', Icons.wb_sunny, 'The user asks about their day.'),
}

extension QuestionCategoryExtension on QuestionCategory {
  String get label => _label;
  IconData get icon => _icon;
  String get promptContext => _promptContext;

  String get _label {
    switch (this) {
      case QuestionCategory.general:
        return 'General';
      case QuestionCategory.love:
        return 'Love';
      case QuestionCategory.career:
        return 'Career';
      case QuestionCategory.yesNo:
        return 'Yes/No';
      case QuestionCategory.daily:
        return 'Daily';
    }
  }

  IconData get _icon {
    switch (this) {
      case QuestionCategory.general:
        return Icons.auto_awesome;
      case QuestionCategory.love:
        return Icons.favorite;
      case QuestionCategory.career:
        return Icons.work;
      case QuestionCategory.yesNo:
        return Icons.check_circle;
      case QuestionCategory.daily:
        return Icons.wb_sunny;
    }
  }

  String get _promptContext {
    switch (this) {
      case QuestionCategory.general:
        return 'The user asks a general question.';
      case QuestionCategory.love:
        return 'The user asks about love or relationships.';
      case QuestionCategory.career:
        return 'The user asks about their career or work.';
      case QuestionCategory.yesNo:
        return 'The user asks a yes or no question. Answer with yes, no, or maybe.';
      case QuestionCategory.daily:
        return 'The user asks about their day.';
    }
  }
}
