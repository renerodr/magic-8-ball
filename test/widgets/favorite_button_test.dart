import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/widgets/favorite_button.dart';

void main() {
  testWidgets('FavoriteButton shows filled heart when favorite', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteButton(
            isFavorite: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('FavoriteButton shows border heart when not favorite', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteButton(
            isFavorite: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('FavoriteButton calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteButton(
            isFavorite: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FavoriteButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
