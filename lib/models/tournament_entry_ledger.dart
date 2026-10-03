/// The device's half of the tournament-entry ledger the backend keeps
/// (TournamentEntryLedger on the server).
///
/// Tournament entries are the player's to keep — a lapse of Pro never takes
/// them, whether Pro granted them or the player bought them. Two parties
/// change them without seeing each other:
///   * the SERVER grants: Pro's one Bronze, Silver and Gold per billing
///     period (written by a store webhook while the app may be closed), and
///     Silver/Gold entry purchases;
///   * the DEVICE spends (a non-Pro player joining a tournament) and mints
///     its own (the rewarded-ad Bronze entry, battle-pass rewards), offline
///     as often as not.
///
/// So per tier the device keeps its COUNT (its balance) and ABSORBED: how
/// many of the server's grants that count already includes. The server
/// reports how many it has GRANTED; the device folds `granted - absorbed`
/// into its count exactly once and pushes both back. The server shows the
/// player `count + max(0, granted - absorbed)`, so a grant the device has
/// not fetched yet survives any push, and spending — which only lowers the
/// count — is never undone by a later grant.
class TournamentEntryLedger {
  TournamentEntryLedger._();

  static const tiers = ['bronze', 'silver', 'gold'];

  /// The tier an entry id names: `tournament_silver` → `silver`, `gold` →
  /// `gold`. Null for anything else.
  static String? tierOf(String entryId) {
    final id = entryId.toLowerCase();
    for (final tier in tiers) {
      if (id.contains(tier)) return tier;
    }
    return null;
  }

  /// The server's ledger from GET /purchases/premium-content
  /// (`tournament_entry_ledger`), or null when it didn't send one (an older
  /// backend).
  static Map<String, ServerTierLedger>? parse(Object? json) {
    if (json is! Map) return null;
    final result = <String, ServerTierLedger>{};
    for (final tier in tiers) {
      final raw = json[tier];
      if (raw is Map) {
        result[tier] = ServerTierLedger(
          granted: (raw['granted'] as num?)?.toInt() ?? 0,
          absorbed: (raw['absorbed'] as num?)?.toInt() ?? 0,
        );
      }
    }
    return result;
  }

  /// Folds the server's grants into one tier of the device's balance.
  ///
  /// [absorbed] null means the device doesn't know yet which grants its
  /// count holds (an install from before the ledger): it adopts the
  /// absorbed counter the server keeps from the device's earlier pushes,
  /// whose counts already held every grant fetched until then. Returns
  /// null when nothing changes.
  static TierBalance? absorb({
    required int count,
    required int? absorbed,
    required ServerTierLedger server,
  }) {
    final base = absorbed ?? server.absorbed;
    if (server.granted > base) {
      return TierBalance(
        count: count + server.granted - base,
        absorbed: server.granted,
      );
    }
    if (absorbed == null) return TierBalance(count: count, absorbed: base);
    return null;
  }
}

/// One tier of the server's ledger.
class ServerTierLedger {
  const ServerTierLedger({required this.granted, required this.absorbed});

  /// Every entry the server has granted in this tier.
  final int granted;

  /// The highest absorbed counter any of the player's devices has pushed.
  final int absorbed;
}

/// One tier of the device's balance.
class TierBalance {
  const TierBalance({required this.count, required this.absorbed});

  final int count;
  final int absorbed;

  @override
  bool operator ==(Object other) =>
      other is TierBalance && other.count == count && other.absorbed == absorbed;

  @override
  int get hashCode => Object.hash(count, absorbed);

  @override
  String toString() => 'TierBalance(count: $count, absorbed: $absorbed)';
}
