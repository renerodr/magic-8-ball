import 'package:flutter/material.dart';
import '../models/question_category.dart';

enum AppVisualState { idle, listening, thinking, revealed, streak }

class SceneColors {
  static const idleDark = Color(0xFF0A0A0F);
  static const idleLight = Color(0xFFF5F0FF);

  static const listeningDark = Color(0xFF1A0A1A);
  static const listeningLight = Color(0xFFFFF0F5);

  static const thinkingDark = Color(0xFF0A0A1A);
  static const thinkingLight = Color(0xFFF0F0FF);

  static const revealedDark = Color(0xFF0F0A14);
  static const revealedLight = Color(0xFFFAF5FF);

  static const streakDark = Color(0xFF1A140A);
  static const streakLight = Color(0xFFFFF8E7);

  static Color backgroundFor(AppVisualState state, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (state) {
      case AppVisualState.idle:
        return isDark ? idleDark : idleLight;
      case AppVisualState.listening:
        return isDark ? listeningDark : listeningLight;
      case AppVisualState.thinking:
        return isDark ? thinkingDark : thinkingLight;
      case AppVisualState.revealed:
      case AppVisualState.streak:
        return isDark ? revealedDark : revealedLight;
    }
  }

  static Color? tintFor(QuestionCategory category, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (category) {
      case QuestionCategory.general:
        return isDark ? const Color(0xFFFF6B6B) : const Color(0xFFFFE4E1);
      case QuestionCategory.love:
        return isDark ? const Color(0xFFFF1493) : const Color(0xFFFFC0CB);
      case QuestionCategory.career:
        return isDark ? const Color(0xFFFFD700) : const Color(0xFFFFF8DC);
      case QuestionCategory.daily:
        return isDark ? const Color(0xFFFF8C00) : const Color(0xFFFFE4B5);
      case QuestionCategory.yesNo:
        return isDark ? const Color(0xFF4ECDC4) : const Color(0xFFE0FFFF);
    }
  }
}
