import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/magic_ball_widget.dart';
import 'package:magic_8_ball/constants/app_theme.dart';

void main() {
  testWidgets('MagicBallWidget renders the "8" label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: const Scaffold(
          body: Center(child: MagicBallWidget()),
        ),
      ),
    );
    expect(find.text('8'), findsOneWidget);
  });
}
