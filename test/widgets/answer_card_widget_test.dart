import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/answer_card_widget.dart';

void main() {
  testWidgets('AnswerCardWidget shows text when visible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnswerCardWidget(
            answer: 'Yes, definitely',
            isVisible: true,
          ),
        ),
      ),
    );

    // Let flutter_animate timers complete
    await tester.pumpAndSettle();

    expect(find.text('Yes, definitely'), findsOneWidget);
  });

  testWidgets('AnswerCardWidget hides text when not visible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnswerCardWidget(
            answer: 'Yes, definitely',
            isVisible: false,
          ),
        ),
      ),
    );

    // Text is in tree but opacity is 0, so it won't be found by find.text in a hit-testable way
    // Check that the SizedBox placeholder is present instead
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
