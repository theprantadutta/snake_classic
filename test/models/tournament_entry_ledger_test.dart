import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/tournament_entry_ledger.dart';

/// The device's half of the tournament-entry ledger. Entries are the
/// player's to keep — no lapse resets them — so the server's grants and the
/// device's own spending have to converge without either erasing the other.
void main() {
  ServerTierLedger server(int granted, [int absorbed = 0]) =>
      ServerTierLedger(granted: granted, absorbed: absorbed);

  group('absorb', () {
    test('folds in the grants the device has not absorbed yet', () {
      // Two Pro renewals while the app was closed.
      expect(
        TournamentEntryLedger.absorb(count: 1, absorbed: 1, server: server(3)),
        const TierBalance(count: 3, absorbed: 3),
      );
    });

    test('absorbs a grant exactly once however often it is fetched', () {
      final first =
          TournamentEntryLedger.absorb(count: 0, absorbed: 0, server: server(1))!;
      expect(first, const TierBalance(count: 1, absorbed: 1));
      expect(
        TournamentEntryLedger.absorb(
          count: first.count,
          absorbed: first.absorbed,
          server: server(1, 1),
        ),
        isNull,
      );
    });

    test('never undoes spending', () {
      // Absorbed one grant, then spent it (and one more) offline. The next
      // fetch reports the same grant: nothing comes back.
      expect(
        TournamentEntryLedger.absorb(count: 0, absorbed: 1, server: server(1, 1)),
        isNull,
      );
    });

    test('a later grant after spending adds only the new grant', () {
      expect(
        TournamentEntryLedger.absorb(count: 0, absorbed: 1, server: server(2, 1)),
        const TierBalance(count: 1, absorbed: 2),
      );
    });

    test('an install from before the ledger adopts the server\'s absorbed '
        'counter instead of re-adding grants its count already holds', () {
      // The older build raised its count to the server's total and pushed
      // it, so the server recorded all three grants as absorbed.
      expect(
        TournamentEntryLedger.absorb(count: 4, absorbed: null, server: server(3, 3)),
        const TierBalance(count: 4, absorbed: 3),
      );
      // ...and still picks up a grant that came after.
      expect(
        TournamentEntryLedger.absorb(count: 4, absorbed: null, server: server(4, 3)),
        const TierBalance(count: 5, absorbed: 4),
      );
    });

    test('a second device absorbs grants into its own count by its own '
        'counter, not the highest the server has seen', () {
      expect(
        TournamentEntryLedger.absorb(count: 2, absorbed: 1, server: server(3, 3)),
        const TierBalance(count: 4, absorbed: 3),
      );
    });
  });

  group('parse', () {
    test('reads the premium-content ledger', () {
      final ledger = TournamentEntryLedger.parse({
        'bronze': {'granted': 3, 'absorbed': 2},
        'silver': {'granted': 1, 'absorbed': 1},
        'gold': {'granted': 0, 'absorbed': 0},
      })!;
      expect(ledger['bronze']!.granted, 3);
      expect(ledger['bronze']!.absorbed, 2);
      expect(ledger.keys, unorderedEquals(['bronze', 'silver', 'gold']));
    });

    test('is null from a backend without the ledger', () {
      expect(TournamentEntryLedger.parse(null), isNull);
    });
  });

  test('tierOf accepts tiers and entry ids', () {
    expect(TournamentEntryLedger.tierOf('bronze'), 'bronze');
    expect(TournamentEntryLedger.tierOf('tournament_silver'), 'silver');
    expect(TournamentEntryLedger.tierOf('GOLD'), 'gold');
    expect(TournamentEntryLedger.tierOf('tournament_vip'), isNull);
  });
}
