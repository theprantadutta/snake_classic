import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/services/storage_service.dart';

/// Control size and swipe sensitivity (8.3): device-local, persisted, and
/// read back on a cold start. Real in-memory database, like
/// settings_single_source_test: "is it persisted" is a question about the
/// Drift write.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await StorageService().initialize(db);
  });

  tearDown(() => db.close());

  test('defaults are normal for both, so nobody\'s controls change', () async {
    final cubit = GameSettingsCubit(StorageService());
    addTearDown(cubit.close);
    expect(cubit.state.controlSize, ControlSize.normal);
    expect(cubit.state.swipeSensitivity, SwipeSensitivity.normal);
    // And what a cold start reads from an untouched install.
    expect(await StorageService().getControlSize(), ControlSize.normal);
    expect(
      await StorageService().getSwipeSensitivity(),
      SwipeSensitivity.normal,
    );
  });

  test('both emit, persist and survive a restart', () async {
    final cubit = GameSettingsCubit(StorageService());
    await cubit.setControlSize(ControlSize.extraLarge);
    await cubit.setSwipeSensitivity(SwipeSensitivity.high);
    expect(cubit.state.controlSize, ControlSize.extraLarge);
    expect(cubit.state.swipeSensitivity, SwipeSensitivity.high);
    await cubit.close();

    // A cold start reads them through the same storage calls
    // GameSettingsCubit.initialize makes (initialize itself needs Firebase).
    expect(await StorageService().getControlSize(), ControlSize.extraLarge);
    expect(
      await StorageService().getSwipeSensitivity(),
      SwipeSensitivity.high,
    );
  });

  test('they are device preferences: an account-data wipe keeps them',
      () async {
    final cubit = GameSettingsCubit(StorageService());
    addTearDown(cubit.close);
    await cubit.setControlSize(ControlSize.large);
    await cubit.setSwipeSensitivity(SwipeSensitivity.low);

    await db.clearAllData();

    expect(await db.settingsDao.getControlSizeIndex(), ControlSize.large.index);
    expect(
      await db.settingsDao.getSwipeSensitivityIndex(),
      SwipeSensitivity.low.index,
    );
  });

  test('a no-op write does not emit', () async {
    final cubit = GameSettingsCubit(StorageService());
    addTearDown(cubit.close);

    var emissions = 0;
    final sub = cubit.stream.listen((_) => emissions++);
    addTearDown(sub.cancel);
    await cubit.setControlSize(ControlSize.normal);
    await cubit.setSwipeSensitivity(SwipeSensitivity.normal);
    await Future<void>.delayed(Duration.zero);
    expect(emissions, 0);
  });

  group('stored indexes', () {
    // Index-stored enums: reordering would silently change every player's
    // saved choice.
    test('order is pinned', () {
      expect(ControlSize.values.map((e) => e.name), [
        'small',
        'normal',
        'large',
        'extraLarge',
      ]);
      expect(SwipeSensitivity.values.map((e) => e.name), [
        'low',
        'normal',
        'high',
      ]);
    });

    test('out-of-range values clamp instead of throwing', () {
      expect(ControlSize.fromIndex(-1), ControlSize.small);
      expect(ControlSize.fromIndex(99), ControlSize.extraLarge);
      expect(SwipeSensitivity.fromIndex(99), SwipeSensitivity.high);
    });

    test('bigger means bigger, more sensitive means less travel', () {
      final factors = ControlSize.values.map((e) => e.factor).toList();
      expect(factors, orderedEquals([...factors]..sort()));
      expect(ControlSize.normal.factor, 1.0);
      expect(
        SwipeSensitivity.high.distance,
        lessThan(SwipeSensitivity.normal.distance),
      );
      expect(
        SwipeSensitivity.normal.distance,
        lessThan(SwipeSensitivity.low.distance),
      );
    });
  });
}
