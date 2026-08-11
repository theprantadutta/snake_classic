/// Whether the OS reports a network link.
enum LinkState {
  /// No transport at all. The only state in which background work is
  /// definitively futile.
  none,

  /// The OS reports a transport. Says nothing about whether anything is
  /// actually reachable through it.
  available,

  /// Not established yet — the very first moments of a cold start.
  unknown,
}

/// What the last REAL request to our backend proved.
enum BackendState {
  /// Nothing has been attempted yet, or the last observation has been
  /// deliberately discarded. Must be treated as "worth trying", never as
  /// offline: at startup this is the normal state, and refusing to sync in it
  /// is how an app talks itself out of working.
  unknown,

  /// A real request succeeded.
  reachable,

  /// A real request failed at the transport layer, or the server answered
  /// 5xx. Advisory only — the next attempt is still allowed to prove
  /// otherwise, and something has to, or this never clears.
  unavailable,
}

/// Where the current backend observation came from.
enum BackendObservationSource {
  /// Nothing has looked yet.
  none,

  /// The outcome of an ordinary API call the app was making anyway. This is
  /// the authoritative source, and after this change the only one.
  apiCall,

  /// An explicit probe, if one is ever reintroduced for a specific UX need.
  probe,
}

/// An immutable, replayable view of what we know about reaching the network
/// and the backend.
///
/// It replaces a single `isOnline` boolean that was being asked to mean four
/// different things at once — network link, general internet, API
/// reachability, and permission to sync — and was fed by a database-backed
/// health probe running on every device every 30 seconds. One boolean cannot
/// carry that, and the probe was the wrong authority: a device can reach the
/// API perfectly well over a route that makes a separate probe fail (LAN dev
/// backends, captive Wi-Fi, VPN split routing), and the app would then refuse
/// to attempt writes that would have succeeded.
///
/// The split here is deliberate: [link] is a hint about whether work is worth
/// attempting; [backend] is a record of what actually happened last time.
/// Only the first is a reason not to try.
class ConnectivitySnapshot {
  const ConnectivitySnapshot({
    this.link = LinkState.unknown,
    this.backend = BackendState.unknown,
    this.lastBackendSuccessAt,
    this.lastBackendFailureAt,
    this.source = BackendObservationSource.none,
  });

  final LinkState link;
  final BackendState backend;
  final DateTime? lastBackendSuccessAt;
  final DateTime? lastBackendFailureAt;
  final BackendObservationSource source;

  /// Whether background work should be attempted right now.
  ///
  /// False ONLY when the OS is certain there is no transport. Unknown link,
  /// unknown backend, and even a backend believed unavailable all return true:
  /// the request itself is the authority, retries are bounded and idempotent,
  /// and a backend marked unavailable has to be allowed to prove otherwise or
  /// nothing ever clears it.
  bool get shouldAttemptNetworkWork => link != LinkState.none;

  /// Optimistic "are we online" for UI and for callers that predate the
  /// snapshot. Unknown counts as online, because the app must stay usable
  /// before anything has been observed.
  bool get isOnline =>
      link != LinkState.none && backend != BackendState.unavailable;

  /// True only when we have positive evidence — used where a wrong guess is
  /// expensive, rather than merely unhelpful.
  bool get isBackendConfirmedReachable => backend == BackendState.reachable;

  ConnectivitySnapshot copyWith({
    LinkState? link,
    BackendState? backend,
    DateTime? lastBackendSuccessAt,
    DateTime? lastBackendFailureAt,
    BackendObservationSource? source,
  }) {
    return ConnectivitySnapshot(
      link: link ?? this.link,
      backend: backend ?? this.backend,
      lastBackendSuccessAt: lastBackendSuccessAt ?? this.lastBackendSuccessAt,
      lastBackendFailureAt: lastBackendFailureAt ?? this.lastBackendFailureAt,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ConnectivitySnapshot &&
      other.link == link &&
      other.backend == backend &&
      other.lastBackendSuccessAt == lastBackendSuccessAt &&
      other.lastBackendFailureAt == lastBackendFailureAt &&
      other.source == source;

  @override
  int get hashCode => Object.hash(
    link,
    backend,
    lastBackendSuccessAt,
    lastBackendFailureAt,
    source,
  );

  @override
  String toString() =>
      'ConnectivitySnapshot(link: ${link.name}, backend: ${backend.name}, '
      'source: ${source.name})';
}
