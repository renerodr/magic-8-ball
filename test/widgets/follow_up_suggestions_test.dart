import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/follow_up_suggestions.dart';
import 'package:magic_8_ball/models/question_category.dart';

void main() {
  group('FollowUpSuggestions', () {
    testWidgets('renders suggestion chips for general category', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUpSuggestions(
              category: QuestionCategory.general,
              onSuggestionTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('What should I focus on?'), findsOneWidget);
      expect(find.text('Give me a sign'), findsOneWidget);
      expect(find.text('What is coming next?'), findsOneWidget);
    });

    testWidgets('renders love category suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUpSuggestions(
              category: QuestionCategory.love,
              onSuggestionTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Will I find love?'), findsOneWidget);
    });

    testWidgets('renders career category suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUpSuggestions(
              category: QuestionCategory.career,
              onSuggestionTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Should I change jobs?'), findsOneWidget);
    });

    testWidgets('renders yesNo category suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUpSuggestions(
              category: QuestionCategory.yesNo,
              onSuggestionTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Ask why'), findsOneWidget);
    });

    testWidgets('renders daily category suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUpSuggestions(
              category: QuestionCategory.daily,
              onSuggestionTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('What is special about today?'), findsOneWidget);
    });

    testWidgets('calls onSuggestionTap when chip tapped', (tester) async {
      String? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUpSuggestions(
              category: QuestionCategory.general,
              onSuggestionTap: (s) => tapped = s,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Give me a sign'));
      expect(tapped, equals('Give me a sign'));
    });
  });
}
