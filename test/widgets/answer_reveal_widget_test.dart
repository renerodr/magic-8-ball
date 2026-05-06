import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/answer_reveal_widget.dart';
import 'package:magic_8_ball/constants/app_theme.dart';

void main() {
  testWidgets('AnswerRevealWidget shows text when isVisible=true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: const Scaffold(
          body: Center(
            child: AnswerRevealWidget(
              answer: 'Outlook good',
              isVisible: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Outlook good'), findsOneWidget);
  });

  testWidgets('AnswerRevealWidget is invisible when isVisible=false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: const Scaffold(
          body: Center(
            child: AnswerRevealWidget(
              answer: 'Outlook good',
              isVisible: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, equals(0.0));
  });
}
