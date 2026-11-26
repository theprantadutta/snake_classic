import 'analytics_client.dart';

/// Online Versus diagnostics, added with the 8.2 Versus fixes after a
/// two-device test against production (2026-11-26). Documented in CLAUDE.md,
/// "Versus analytics (8.2)".
///
/// They answer what the device test could only answer for two phones on one
/// Wi-Fi: how often lobbies die and why, how often players drop mid-match and
/// whether they get back, and what the link quality of real matches is.
extension VersusEvents on AnalyticsClient {
  /// A matchmade lobby closed without a match. [reason]: `ready_timeout`
  /// (somebody never pressed READY) or `host_did_not_start` (everyone was
  /// ready, the host never pressed START).
  Future<void> trackVersusLobbyClosed({required String reason}) =>
      trackEvent('versus_lobby_closed', {'reason': reason});

  /// The live link mid-match. [stage]: `reconnecting` (socket dropped),
  /// `recovered` (back in the match), `ended_away` (the match ended while we
  /// were offline), `lost` (gave up reconnecting).
  Future<void> trackVersusConnection({required String stage}) =>
      trackEvent('versus_connection', {'stage': stage});

  /// One per finished match: link quality as this device saw it.
  /// [roundTripMs] is the measured input round trip; [lateSnapshots] counts
  /// gaps over 400 ms between server ticks (tick is ~300 ms); [maxGapMs] is
  /// the longest gap; [correctionPct] is the share of locally predicted steps
  /// the server corrected. [result] is `win` / `loss` / `draw`.
  Future<void> trackVersusMatchQuality({
    required int roundTripMs,
    required int lateSnapshots,
    required int maxGapMs,
    required int correctionPct,
    required String result,
  }) =>
      trackEvent('versus_match_quality', {
        'rtt_ms': roundTripMs,
        'late_snapshots': lateSnapshots,
        'max_gap_ms': maxGapMs,
        'correction_pct': correctionPct,
        'result': result,
      });
}
