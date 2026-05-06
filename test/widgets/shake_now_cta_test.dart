import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/shake_now_cta.dart';

void main() {
  testWidgets('ShakeNowCta renders text and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShakeNowCta(onTap: () {}),
        ),
      ),
    );

    expect(find.text('Shake Now'), findsOneWidget);
    expect(find.byIcon(Icons.vibration_rounded), findsOneWidget);
  });

  testWidgets('ShakeNowCta calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShakeNowCta(onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(ShakeNowCta));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
