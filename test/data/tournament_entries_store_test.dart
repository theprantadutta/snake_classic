import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';

/// Tournament entries live on the synced `premium_status` row. These pin the
/// storage half of "entries are the player's to keep": absorbing server
/// grants writes the count and the absorbed counter together with their
/// outbox row, and a Pro lapse leaves the entries where they are.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.initializeDefaults();
  });

  tearDown(() => db.close());

  Future<List<SyncQueueData>> premiumOutbox() async =>
      (await db.select(db.syncQueue).get())
          .where((r) => r.dataType == SyncDataType.premiumStatus)
          .toList();

  test('absorbing grants writes counts and absorbed counters together, '
      'with an outbox row', () async {
    await db.storeDao.setTournamentEntries(bronze: 1, silver: 0, gold: 2);
    await db.delete(db.syncQueue).go();

    await db.storeDao.absorbTournamentGrants({
      'bronze': (count: 2, absorbed: 1),
      'silver': (count: 1, absorbed: 1),
    });

    final status = (await db.storeDao.getPremiumStatus())!;
    expect(status.bronzeTournamentEntries, 2);
    expect(status.silverTournamentEntries, 1);
    expect(status.goldTournamentEntries, 2, reason: 'untouched tier kept');
    expect(status.bronzeGrantsAbsorbed, 1);
    expect(status.silverGrantsAbsorbed, 1);
    expect(status.goldGrantsAbsorbed, isNull);
    expect(await premiumOutbox(), isNotEmpty);
  });

  test('a lapse found offline keeps every entry', () async {
    await db.storeDao.setPremiumActive(
      true,
      expirationDate: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    await db.storeDao.absorbTournamentGrants({
      'bronze': (count: 3, absorbed: 2),
      'silver': (count: 1, absorbed: 1),
      'gold': (count: 1, absorbed: 1),
    });

    // What PremiumCubit.recheckLocalExpiry does on resume.
    expect(await db.storeDao.isPremiumActive(), isFalse);

    expect(await db.storeDao.getTournamentEntries(),
        {'bronze': 3, 'silver': 1, 'gold': 1});
    expect(await db.storeDao.getTournamentGrantsAbsorbed(),
        {'bronze': 2, 'silver': 1, 'gold': 1});
  });

  test('a cloud restore takes the totals with the server\'s absorbed '
      'counters', () async {
    await db.storeDao.applyPremiumStatusSnapshot(
      const PremiumStatusCompanion(
        bronzeTournamentEntries: Value(4),
        bronzeGrantsAbsorbed: Value(3),
      ),
    );

    final status = (await db.storeDao.getPremiumStatus())!;
    expect(status.bronzeTournamentEntries, 4);
    expect(status.bronzeGrantsAbsorbed, 3);
  });
}
