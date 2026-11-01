import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  // The server's daily-challenge templates (DailyChallengeJobService).
  const serverModes = {
    'classic': GameMode.classic,
    'zen': GameMode.zen,
    'speed': GameMode.speedChallenge,
  };

  test('every server challenge mode matches the run that plays it', () {
    serverModes.forEach((required, mode) {
      // What a finished run reports (display label) and the wire spelling.
      expect(challengeModeMatches(required, mode.name), isTrue,
          reason: '$required vs ${mode.name}');
      expect(challengeModeMatches(required, mode.wireName), isTrue,
          reason: '$required vs ${mode.wireName}');
    });
  });

  test('a run in another mode never counts', () {
    expect(challengeModeMatches('zen', GameMode.classic.name), isFalse);
    expect(challengeModeMatches('speed', GameMode.zen.name), isFalse);
    expect(challengeModeMatches('classic', GameMode.survival.name), isFalse);
  });

  test('each mode has its own key', () {
    final keys = GameMode.values.map((m) => gameModeKey(m.name)).toSet();
    expect(keys, hasLength(GameMode.values.length));
    for (final mode in GameMode.values) {
      expect(gameModeKey(mode.name), gameModeKey(mode.wireName));
    }
  });
}
