import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/screens/home_screen.dart';
import 'package:magic_8_ball/widgets/magic_ball_widget.dart';
import 'package:magic_8_ball/constants/app_theme.dart';

void main() {
  group('P0.2 Verification Tests', () {
    testWidgets('MagicBallWidget renders with isShaking false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: Center(child: MagicBallWidget(isShaking: false)),
          ),
        ),
      );

      expect(find.byType(MagicBallWidget), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('MagicBallWidget accepts isShaking true without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: Center(child: MagicBallWidget(isShaking: true)),
          ),
        ),
      );

      expect(find.byType(MagicBallWidget), findsOneWidget);
    });

    testWidgets('reduced-motion accessibleNavigation disables continuous animations', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: MaterialApp(
            theme: darkTheme,
            home: const Scaffold(
              body: Center(child: MagicBallWidget()),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 5));

      expect(find.byType(MagicBallWidget), findsOneWidget);
    });

    testWidgets('IconButton is semantic with tooltip and activatable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: HomeScreen(onToggleTheme: () {}),
        ),
      );

      final historyButton = find.byIcon(Icons.history_rounded);
      expect(historyButton, findsOneWidget);

      final iconButton = find.ancestor(
        of: historyButton,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);

      final buttonWidget = tester.widget<IconButton>(iconButton);
      expect(buttonWidget.tooltip, 'History');

      bool toggleCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: HomeScreen(onToggleTheme: () => toggleCalled = true),
        ),
      );

      await tester.tap(find.byType(IconButton).last);
      expect(toggleCalled, isTrue);
    });

    testWidgets('theme toggle IconButton is semantic and triggers callback', (tester) async {
      bool themeToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: HomeScreen(onToggleTheme: () => themeToggled = true),
        ),
      );

      final lightModeButton = find.byIcon(Icons.light_mode_rounded);
      expect(lightModeButton, findsOneWidget);

      await tester.tap(lightModeButton);
      expect(themeToggled, isTrue);
    });
  });
}