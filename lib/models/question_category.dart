import 'package:flutter/material.dart';

enum QuestionCategory {
  general(
    label: 'General',
    icon: Icons.auto_awesome,
    promptContext: 'The user asks a general question.',
  ),
  love(
    label: 'Love',
    icon: Icons.favorite,
    promptContext: 'The user asks about love or relationships.',
  ),
  career(
    label: 'Career',
    icon: Icons.work,
    promptContext: 'The user asks about their career or work.',
  ),
  yesNo(
    label: 'Yes/No',
    icon: Icons.check_circle,
    promptContext: 'The user asks a yes or no question. Answer with yes, no, or maybe.',
  ),
  daily(
    label: 'Daily',
    icon: Icons.wb_sunny,
    promptContext: 'The user asks about their day.',
  );

  const QuestionCategory({
    required this.label,
    required this.icon,
    required this.promptContext,
  });

  final String label;
  final IconData icon;
  final String promptContext;
}
