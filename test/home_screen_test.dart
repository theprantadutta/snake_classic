import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  group('HomeScreen', () {
    late GameProvider gameProvider;

    setUp(() {
      gameProvider = GameProvider();
    });

    testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: gameProvider,
            child: const HomeScreen(),
          ),
        ),
      );

      // Verify that the title is displayed
      expect(find.text('SNAKE'), findsOneWidget);
      
      // Verify that high score is displayed
      expect(find.text('HIGH SCORE'), findsOneWidget);
      
      // Verify that play button is displayed
      expect(find.text('PLAY'), findsOneWidget);
      
      // Verify that settings button is displayed
      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('HomeScreen play button navigates to game screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: gameProvider,
            child: const HomeScreen(),
          ),
        ),
      );

      // Tap the play button
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();

      // Verify that game has started
      expect(gameProvider.gameState.status, GameStatus.playing);
    });

    testWidgets('HomeScreen settings button navigates to settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: gameProvider,
            child: const HomeScreen(),
          ),
          routes: {
            '/settings': (context) => const Scaffold(body: Text('Settings Screen')),
          },
        ),
      );

      // Tap the settings button
      await tester.tap(find.text('SETTINGS'));
      await tester.pumpAndSettle();

      // Verify that we've navigated to settings screen
      expect(find.text('Settings Screen'), findsOneWidget);
    });

    testWidgets('HomeScreen displays high score correctly', (WidgetTester tester) async {
      gameProvider.gameState.loadHighScore(1000);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: gameProvider,
            child: const HomeScreen(),
          ),
        ),
      );

      // Verify that high score is displayed
      expect(find.text('1000'), findsOneWidget);
    });
  });
}