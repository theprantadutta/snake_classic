import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/purchase_service.dart';

/// The ISO-8601 duration parser behind the free-trial copy.
///
/// Google Play reports a trial's length as the `billingPeriod` of its
/// zero-priced pricing phase, in ISO-8601 ("P3D", "P1W"). That string is the
/// only thing standing between the store's real offer and what the UI claims,
/// and getting it wrong is not a cosmetic bug: advertising a trial the store
/// does not grant is a store-review rejection and, arguably, a false claim
/// about a paid product. So the parser is pinned here rather than trusted.
void main() {
  int? days(String period) => PurchaseService.iso8601PeriodInDays(period);

  group('the periods a trial is actually configured in', () {
    test('P3D is the monthly plan', () => expect(days('P3D'), 3));
    test('P7D is the yearly plan', () => expect(days('P7D'), 7));

    test('a week is seven days, not one', () {
      // The trap: Play accepts either form for the same offer, and a naive
      // "read the number" parse turns a 7-day trial into "1-day free trial".
      expect(days('P1W'), 7);
      expect(days('P2W'), 14);
    });

    test('longer offers still resolve', () {
      expect(days('P1M'), 30);
      expect(days('P1Y'), 365);
    });

    test('combined designators add up', () {
      expect(days('P1M15D'), 45);
      expect(days('P1W3D'), 10);
    });
  });

  group('what it refuses', () {
    test('an empty period is not a trial', () {
      // "P0D" and "PT0S" both mean no time at all. Returning 0 here would put
      // a "0-day free trial" badge on the card.
      expect(days('P0D'), isNull);
      expect(days('P'), isNull);
    });

    test('garbage returns null rather than a guess', () {
      // Every null here means the UI silently says nothing, which is exactly
      // the behaviour before any of this existed — the safe direction to fail.
      for (final junk in ['', '3D', 'P3X', 'weekly', 'PT30M', 'P-3D']) {
        expect(days(junk), isNull, reason: 'refused: "$junk"');
      }
    });

    test('a time component is not a subscription period', () {
      // ISO-8601 allows PnDTnH; Play never sends it for a billing period, and
      // accepting it would mean parsing something we have not verified.
      expect(days('P1DT12H'), isNull);
    });
  });
}
