import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/existing_install_probe.dart';

/// Where an existing player's history actually lives.
///
/// The `statistics` table has typed columns — `totalGamesPlayed`,
/// `highestScore` — that look exactly like what you would check. They are
/// inert: the field names never matched the model's, so
/// `updateStatisticsFromJson` stopped populating them and round-trips the
/// whole model through `modelJson` instead. A player with a thousand games
/// behind them therefore reads as zero on every typed column, and a probe
/// that trusted those columns would hand them the new-player experience —
/// which is the exact misclassification the migration exists to prevent.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<void> writeStats({
    required String modelJson,
    int typedGames = 0,
    int typedHighScore = 0,
  }) async {
    await db
        .into(db.statistics)
        .insert(
          StatisticsCompanion.insert(
            totalGamesPlayed: Value(typedGames),
            highestScore: Value(typedHighScore),
            modelJson: Value(modelJson),
          ),
        );
  }

  Future<void> writeHighScore(int score) async {
    await db
        .into(db.gameSettings)
        .insert(GameSettingsCompanion.insert(highScore: Value(score)));
  }

  group('a normal existing player', () {
    test('is found through modelJson, not the typed columns', () async {
      // THE regression. This is what every real install looks like.
      await writeStats(
        modelJson: jsonEncode({'totalGamesPlayed': 412, 'highScore': 2870}),
      );

      expect(await hasLocalGameplayEvidence(db), isTrue);
    });

    test('a high score alone in the model counts', () async {
      await writeStats(
        modelJson: jsonEncode({'totalGamesPlayed': 0, 'highScore': 90}),
      );

      expect(await hasLocalGameplayEvidence(db), isTrue);
    });

    test('games alone in the model count', () async {
      await writeStats(modelJson: jsonEncode({'totalGamesPlayed': 1}));

      expect(await hasLocalGameplayEvidence(db), isTrue);
    });

    test('a row from an older build that populated the typed columns counts',
        () async {
      // Not the path any current install takes — nothing writes these any
      // more — but if a legacy row has them, that is still evidence and
      // throwing it away would misclassify the same player twice over.
      await writeStats(modelJson: '{}', typedGames: 7, typedHighScore: 120);

      expect(await hasLocalGameplayEvidence(db), isTrue);
    });
  });

  group('the settings fallback', () {
    test('an old install with only a stored high score counts', () async {
      await writeHighScore(340);

      expect(await hasLocalGameplayEvidence(db), isTrue);
    });

    test('it is consulted even when a statistics row exists but is empty',
        () async {
      await writeStats(modelJson: '{}');
      await writeHighScore(55);

      expect(await hasLocalGameplayEvidence(db), isTrue);
    });
  });

  group('a device that has not played', () {
    test('an empty database is no evidence', () async {
      expect(await hasLocalGameplayEvidence(db), isFalse);
    });

    test('an empty statistics blob is no evidence', () async {
      await writeStats(modelJson: '{}');

      expect(await hasLocalGameplayEvidence(db), isFalse);
    });

    test('a zeroed model is no evidence', () async {
      await writeStats(
        modelJson: jsonEncode({'totalGamesPlayed': 0, 'highScore': 0}),
      );

      expect(await hasLocalGameplayEvidence(db), isFalse);
    });

    test('a zero high score in settings is no evidence', () async {
      await writeHighScore(0);

      expect(await hasLocalGameplayEvidence(db), isFalse);
    });
  });

  group('unreadable statistics', () {
    test('malformed JSON throws rather than answering "new"', () async {
      // The caller leaves the migration unstamped on a throw, so this means
      // "ask again next launch" — not a permanent wrong answer baked in
      // during one bad read.
      await writeStats(modelJson: '{not json at all');

      expect(hasLocalGameplayEvidence(db), throwsA(isA<FormatException>()));
    });

    test('a blob of the wrong shape throws too', () async {
      await writeStats(modelJson: '[1, 2, 3]');

      expect(hasLocalGameplayEvidence(db), throwsA(anything));
    });
  });
}
