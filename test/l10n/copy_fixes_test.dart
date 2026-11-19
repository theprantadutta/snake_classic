import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/l10n/supported_locales.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/services/achievement_service.dart';

DailyChallenge _modeChallenge(String title, String mode, int target) =>
    DailyChallenge(
      id: 'x',
      title: title,
      description: 'server text',
      type: ChallengeType.gameMode,
      difficulty: ChallengeDifficulty.easy,
      targetValue: target,
      coinReward: 10,
      xpReward: 10,
      requiredGameMode: mode,
    );

void main() {
  group('dcDescMode', () {
    final en = lookupAppLocalizations(const Locale('en'));

    test('Zen reads "Zen Mode" once, not "Zen Mode mode"', () {
      final text =
          _modeChallenge('Zen Master', 'zen', 2).localizedDescription(en);
      expect(text, 'Play 2 games in Zen Mode');
    });

    test('Classic and Speed Challenge read naturally', () {
      expect(
        _modeChallenge('Classic Lover', 'classic', 1).localizedDescription(en),
        'Play 1 game in Classic',
      );
      expect(
        _modeChallenge('Speed Demon', 'speed', 3).localizedDescription(en),
        'Play 3 games in Speed Challenge',
      );
    });

    test('no locale doubles the word for "mode" around the Zen name', () {
      for (final locale in SupportedLocales.locales) {
        final l10n = lookupAppLocalizations(locale);
        final text =
            _modeChallenge('Zen Master', 'zen', 2).localizedDescription(l10n);
        final zen = l10n.modeZen;
        expect(text, contains(zen), reason: locale.languageCode);
        // The name already carries "Mode"/"Modo"/"Tryb"...; the template
        // must not repeat it right next to the name.
        final modeWord = zen.split(' ').firstWhere(
              (w) => w.toLowerCase() != 'zen' && w != 'ज़ेन',
              orElse: () => '',
            );
        if (modeWord.isEmpty) continue;
        final occurrences = modeWord.toLowerCase().allMatches(text.toLowerCase());
        expect(occurrences.length, 1,
            reason: '${locale.languageCode}: "$text" repeats "$modeWord"');
      }
    });
  });

  group('device-neutral copy', () {
    test('replays subtitle and How to Play header never say "phone"', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(en.lbReplaysSubtitle.toLowerCase(), isNot(contains('phone')));
      expect(en.insOnPhone.toLowerCase(), isNot(contains('phone')));
    });
  });

  group('AchievementService.wholePercent', () {
    test('2 of 147 is 1%, the same everywhere it is shown', () {
      expect(AchievementService.wholePercent(2 / 147), 1);
    });

    test('rounds half up and clamps', () {
      expect(AchievementService.wholePercent(0), 0);
      expect(AchievementService.wholePercent(0.004), 0);
      expect(AchievementService.wholePercent(0.005), 1);
      expect(AchievementService.wholePercent(0.995), 100);
      expect(AchievementService.wholePercent(1.4), 100);
      expect(AchievementService.wholePercent(-0.2), 0);
    });
  });
}
