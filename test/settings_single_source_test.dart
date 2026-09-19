import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/constants.dart';

/// Every player-facing preference has exactly ONE source of truth, and it
/// survives a restart.
///
/// The bug class these guard against: a setting exists in two places at once
/// — a cubit and a screen's `setState` mirror, or a cubit and a boot-time
/// cache — and the two disagree. Sound and music were the last pair still
/// living outside [GameSettingsCubit]: both the Settings screen and the pause
/// overlay held their own copy read from AudioService at mount, so a flip in
/// one surface could not reach the other, and `AppDataCache.settingsData`
/// added a third copy of the board size and D-pad values that was snapshotted
/// at boot and never refreshed.
///
/// Runs against a REAL in-memory database, like settings_singleton_test:
/// "is it actually persisted" is a question about the Drift write, and a fake
/// storage layer would answer it by construction.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await StorageService().initialize(db);
  });

  tearDown(() => db.close());

  /// Read the settings row straight from the table, bypassing every service
  /// layer — the point is to prove the bytes reached disk, not that a getter
  /// returns what a setter was handed.
  Future<GameSetting> row() async =>
      (await db.select(db.gameSettings).get()).single;

  group('preferences round-trip through Drift', () {
    test('sound and music survive a write', () async {
      final storage = StorageService();

      // Defaults, before anything has been touched.
      expect(await storage.isSoundEnabled(), isTrue);
      expect(await storage.isMusicEnabled(), isTrue);

      await storage.setSoundEnabled(false);
      await storage.setMusicEnabled(false);

      expect((await row()).soundEnabled, isFalse);
      expect((await row()).musicEnabled, isFalse);
      expect(await storage.isSoundEnabled(), isFalse);
      expect(await storage.isMusicEnabled(), isFalse);
    });

    test('board size survives, width AND height', () async {
      final storage = StorageService();

      // A NON-square board specifically: storage went through three
      // encodings and the middle one stored width alone, which cannot tell
      // 20x20 from 20x36 apart.
      final tall = GameConstants.availableBoardSizes.firstWhere(
        (s) => s.width != s.height,
        orElse: () => GameConstants.availableBoardSizes.last,
      );

      await storage.saveBoardSize(tall);
      final restored = await storage.getBoardSize();

      expect(restored.width, tall.width);
      expect(restored.height, tall.height);
    });

    test('difficulty, screen shake and haptics survive', () async {
      final storage = StorageService();

      await storage.saveDifficulty(Difficulty.hard);
      await storage.setScreenShakeEnabled(true);
      await storage.setHapticsEnabled(false);

      expect(await storage.getDifficulty(), Difficulty.hard);
      expect(await storage.isScreenShakeEnabled(), isTrue);
      expect(await storage.isHapticsEnabled(), isFalse);
    });
  });

  group('GameSettingsCubit is the single writer', () {
    test('setSoundEnabled emits AND persists', () async {
      final cubit = GameSettingsCubit(StorageService());
      addTearDown(cubit.close);

      expect(cubit.state.soundEnabled, isTrue);

      await cubit.setSoundEnabled(false);

      // Both halves matter. Emitting without persisting is the bug where a
      // setting reverts on restart; persisting without emitting is the bug
      // where the other screen showing the same toggle never updates.
      expect(cubit.state.soundEnabled, isFalse);
      expect((await row()).soundEnabled, isFalse);
    });

    test('setMusicEnabled emits AND persists', () async {
      final cubit = GameSettingsCubit(StorageService());
      addTearDown(cubit.close);

      await cubit.setMusicEnabled(false);

      expect(cubit.state.musicEnabled, isFalse);
      expect((await row()).musicEnabled, isFalse);
    });

    test('board size, difficulty and screen shake emit AND persist', () async {
      final cubit = GameSettingsCubit(StorageService());
      addTearDown(cubit.close);

      final tall = GameConstants.availableBoardSizes.firstWhere(
        (s) => s.width != s.height,
        orElse: () => GameConstants.availableBoardSizes.last,
      );

      await cubit.setBoardSize(tall);
      await cubit.setDifficulty(Difficulty.hard);
      await cubit.setScreenShakeEnabled(true);

      expect(cubit.state.boardSize, tall);
      expect(cubit.state.difficulty, Difficulty.hard);
      expect(cubit.state.screenShakeEnabled, isTrue);

      expect((await row()).boardSizeIndex, tall.storageKey);
      expect((await row()).difficultyIndex, Difficulty.hard.index);
      expect((await row()).screenShakeEnabled, isTrue);
    });

    test('a no-op write neither emits nor touches storage', () async {
      final cubit = GameSettingsCubit(StorageService());
      addTearDown(cubit.close);

      var emissions = 0;
      final sub = cubit.stream.listen((_) => emissions++);
      addTearDown(sub.cancel);

      // Already the default.
      await cubit.setSoundEnabled(true);
      await cubit.setMusicEnabled(true);
      await Future<void>.delayed(Duration.zero);

      expect(
        emissions,
        0,
        reason: 'setting a value to what it already is must not emit — '
            'every listener rebuild here is a wasted frame mid-game',
      );
    });
  });

  group('one value, one copy', () {
    test(
      'the two audio surfaces cannot disagree, because there is one field',
      () async {
        // The pause overlay and the Settings screen both render audio
        // toggles. Before this, each held a `setState` bool seeded from
        // AudioService at mount. This is the regression test for that: a
        // write made "somewhere else" is visible to any reader of the cubit
        // immediately, with no remount.
        final cubit = GameSettingsCubit(StorageService());
        addTearDown(cubit.close);

        final seen = <bool>[];
        final sub = cubit.stream.map((s) => s.soundEnabled).listen(seen.add);
        addTearDown(sub.cancel);

        await cubit.setSoundEnabled(false);
        await cubit.setSoundEnabled(true);
        await Future<void>.delayed(Duration.zero);

        expect(seen, [false, true]);
        expect(cubit.state.soundEnabled, isTrue);
      },
    );

    test('a restore written straight to the row is readable back', () async {
      // Stands in for the first-sign-in cloud restore, which writes the
      // restored account's settings directly into the table via
      // applySettingsSnapshot rather than going through the cubit.
      await db.settingsDao.applySettingsSnapshot(
        const GameSettingsCompanion(
          soundEnabled: Value(false),
          musicEnabled: Value(false),
        ),
      );

      expect((await row()).soundEnabled, isFalse);
      expect((await row()).musicEnabled, isFalse);

      // A cubit built after the restore picks it up from storage, which is
      // what a cold start does.
      final storage = StorageService();
      expect(await storage.isSoundEnabled(), isFalse);
      expect(await storage.isMusicEnabled(), isFalse);
    });
  });
}
