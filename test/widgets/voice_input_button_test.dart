import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/voice_input_button.dart';

void main() {
  testWidgets('VoiceInputButton shows mic_none when idle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceInputButton(
            isListening: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });

  testWidgets('VoiceInputButton shows mic when listening', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceInputButton(
            isListening: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.mic), findsOneWidget);
  });

  testWidgets('VoiceInputButton calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceInputButton(
            isListening: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(VoiceInputButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
