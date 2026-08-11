import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/database/settlement_write.dart';
import 'package:snake_classic/services/daily_challenge_settlement_service.dart';

/// Daily-challenge rewards, applied from server settlements exactly once.
///
/// Claiming used to flip a local Drift flag and then separately call
/// CoinsCubit. Two devices offline could each see the same challenge
/// legitimately unclaimed and each pay themselves; a crash between the flag
/// and the credit lost the reward for good on that install.
///
/// These run against a REAL in-memory database — real schema, real DAOs, real
/// transactions — because the guarantee is a transactional one and a fake
/// cannot fail in the ways that matter.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.coins).insert(
          CoinsCompanion.insert(
            balance: const Value(0),
            totalEarned: const Value(0),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    // A real battle pass, so the XP leg of the transaction actually writes.
    // Without one, _addBattlePassXp returns early and breaking battle_passes
    // proves nothing — which is how the first version of the
    // failing-at-each-table test passed a table it was not really exercising.
    await db.into(db.battlePasses).insert(
          BattlePassesCompanion.insert(
            seasonId: 'season-1',
            currentTier: const Value(0),
            currentXp: const Value(0),
            xpForNextTier: const Value(100),
          ),
        );
  });

  tearDown(() async => db.close());

  Future<int> balance() async =>
      (await (db.select(db.coins)..where((t) => t.id.equals(1))).getSingle())
          .balance;

  Future<int> coinTransactionCount() async =>
      (await db.select(db.coinTransactions).get()).length;

  Future<DailyChallengeWriteResult> apply({
    String id = 's1',
    String key = 'challenge-a',
    int coins = 25,
    int xp = 10,
  }) =>
      db.applyDailyChallengeSettlementOnce(
        settlementId: id,
        settlementKey: key,
        coinsAwarded: coins,
        xpAwarded: xp,
        description: 'Daily challenge',
      );

  /// Break a table's writes while leaving reads working, so a failure lands
  /// exactly where a real one would.
  Future<void> breakWrites(String table) async {
    for (final op in ['INSERT', 'UPDATE']) {
      await db.customStatement(
        "CREATE TRIGGER break_${table}_$op BEFORE $op ON $table "
        "BEGIN SELECT RAISE(ABORT, 'forced write failure'); END",
      );
    }
  }

  Future<void> unbreakWrites(String table) async {
    for (final op in ['INSERT', 'UPDATE']) {
      await db.customStatement('DROP TRIGGER IF EXISTS break_${table}_$op');
    }
  }

  group('applying a settlement', () {
    test('credits coins once and records the key', () async {
      final result = await apply();

      expect(result.applied, isTrue);
      expect(await balance(), 25);
      expect(await db.isDailyChallengeSettled('challenge-a'), isTrue);
    });

    test('a re-delivered settlement pays nothing', () async {
      // Duplicate delivery: the server offers it again because an ack was
      // lost in flight.
      await apply();
      final second = await apply();

      expect(second.applied, isFalse);
      expect(await balance(), 25);
      expect(await coinTransactionCount(), 1);
    });

    test('ten deliveries still pay once', () async {
      for (var i = 0; i < 10; i++) {
        await apply();
      }
      expect(await balance(), 25);
      expect(await coinTransactionCount(), 1);
    });

    test('a DIFFERENT settlement id for the same key pays nothing', () async {
      // Two devices claimed offline. The server settles once, but a stale
      // client could still be holding an older id for the same reward — and
      // the migration writes 'local:' ids for rewards already paid.
      await apply(id: 's1', key: 'challenge-a');
      final second = await apply(id: 's2', key: 'challenge-a');

      expect(second.applied, isFalse);
      expect(await balance(), 25, reason: 'one reward, one payment');
      expect(await coinTransactionCount(), 1);
    });

    test('different challenges are paid separately', () async {
      await apply(id: 's1', key: 'challenge-a', coins: 25);
      await apply(id: 's2', key: 'challenge-b', coins: 40);

      expect(await balance(), 65);
      expect(await coinTransactionCount(), 2);
    });
  });

  group('crash safety', () {
    test('a failure part-way through rolls the whole thing back', () async {
      await breakWrites('coin_transactions');
      await expectLater(apply(), throwsA(isA<Object>()));
      await unbreakWrites('coin_transactions');

      expect(await balance(), 0);
      expect(await db.isDailyChallengeSettled('challenge-a'), isFalse,
          reason: 'a rolled-back apply must not look applied');
    });

    test('the retry after a rollback credits exactly once', () async {
      await breakWrites('coins');
      await expectLater(apply(), throwsA(isA<Object>()));
      await unbreakWrites('coins');

      // "Restart": a fresh writer over the same database.
      final writer = DriftDailyChallengeSettlementWriter(db);
      final applied = await writer.applyOnce(const DailyChallengeSettlement(
        id: 's1',
        settlementKey: 'challenge-a',
        challengeId: 'challenge-a',
        coinsAwarded: 25,
        xpAwarded: 10,
        isSetBonus: false,
      ));

      expect(applied, isTrue);
      expect(await balance(), 25);
      expect(await coinTransactionCount(), 1);
    });

    test('failing at each table in turn still credits once', () async {
      for (final table in ['coins', 'coin_transactions', 'battle_passes']) {
        await breakWrites(table);
        try {
          await apply();
        } catch (_) {
          // expected
        }
        await unbreakWrites(table);
        expect(await balance(), 0, reason: '$table: nothing should have stuck');
      }

      await apply();
      expect(await balance(), 25);
      expect(await coinTransactionCount(), 1);
    });

    test('a marker failure rolls the coins back too', () async {
      // The dangerous one: coins land, the marker does not, and the retry
      // pays again. It has to be all-or-nothing.
      await breakWrites('applied_daily_challenge_settlements');
      await expectLater(apply(), throwsA(isA<Object>()));
      await unbreakWrites('applied_daily_challenge_settlements');

      expect(await balance(), 0);

      await apply();
      expect(await balance(), 25);
      expect(await coinTransactionCount(), 1);
    });
  });

  group('the all-complete bonus', () {
    test('is applied through the same path, keyed on the day', () async {
      await apply(id: 'b1', key: 'bonus:2026-08-11', coins: 50, xp: 100);

      expect(await balance(), 50);
      expect(await db.isDailyChallengeSettled('bonus:2026-08-11'), isTrue);
    });

    test('is paid exactly once however many times it arrives', () async {
      await apply(id: 'b1', key: 'bonus:2026-08-11', coins: 50);
      await apply(id: 'b2', key: 'bonus:2026-08-11', coins: 50);
      await apply(id: 'b1', key: 'bonus:2026-08-11', coins: 50);

      expect(await balance(), 50);
      expect(await coinTransactionCount(), 1);
    });

    test('a different day is a different bonus', () async {
      // The claim window straddles UTC midnight, so both can be owed at once.
      await apply(id: 'b1', key: 'bonus:2026-08-11', coins: 50);
      await apply(id: 'b2', key: 'bonus:2026-08-12', coins: 50);

      expect(await balance(), 100);
      expect(await coinTransactionCount(), 2);
    });
  });

  group('migration of rows this device already paid', () {
    test('a locally claimed reward is never paid again', () async {
      // What the v20 migration writes for every row that was claimed under
      // the old local-credit flow: a completed ledger entry under a synthetic
      // id, occupying the key.
      await db.into(db.appliedDailyChallengeSettlements).insert(
            AppliedDailyChallengeSettlementsCompanion.insert(
              settlementId: 'local:challenge-a',
              settlementKey: 'challenge-a',
              coinsApplied: const Value(25),
              completedAt: Value(DateTime.now()),
            ),
          );

      // The server offers a real settlement for the same reward — which can
      // happen if the device upgrades between the two deploys.
      final result = await apply(id: 'server-1', key: 'challenge-a');

      expect(result.applied, isFalse);
      expect(await balance(), 0, reason: 'it was already paid on this device');
    });

    test('the server id is still recorded so it stops being offered', () async {
      await db.into(db.appliedDailyChallengeSettlements).insert(
            AppliedDailyChallengeSettlementsCompanion.insert(
              settlementId: 'local:challenge-a',
              settlementKey: 'challenge-a',
              completedAt: Value(DateTime.now()),
            ),
          );

      await apply(id: 'server-1', key: 'challenge-a');

      final row = await (db.select(db.appliedDailyChallengeSettlements)
            ..where((t) => t.settlementId.equals('server-1')))
          .getSingleOrNull();
      expect(row, isA<AppliedDailyChallengeSettlement>());
      expect(row!.completedAt != null, isTrue);
      expect(row.coinsApplied, 0, reason: 'recorded as seen, not as paid');
    });

    test('an unfinished ledger row does NOT block a retry', () async {
      // A row with a null completedAt is a settlement that started and did
      // not finish. Treating it as done would lose the reward.
      await db.into(db.appliedDailyChallengeSettlements).insert(
            AppliedDailyChallengeSettlementsCompanion.insert(
              settlementId: 'half-done',
              settlementKey: 'challenge-a',
            ),
          );

      final result = await apply(id: 'half-done', key: 'challenge-a');

      expect(result.applied, isTrue);
      expect(await balance(), 25);
    });
  });

  group('what the player sees while offline', () {
    test('an unsettled claim is not reported as settled', () async {
      // The claim intent is durable, but no money has moved. The card must
      // read as pending rather than pretending it was paid.
      expect(await db.isDailyChallengeSettled('challenge-a'), isFalse);
      expect(await balance(), 0);
    });

    test('settled keys can be read in one go for the UI', () async {
      await apply(id: 's1', key: 'challenge-a');
      await apply(id: 's2', key: 'challenge-b');

      final settled = await db.settledDailyChallengeKeys();
      expect(settled, containsAll(['challenge-a', 'challenge-b']));
      expect(settled.contains('challenge-c'), isFalse);
    });
  });
}
