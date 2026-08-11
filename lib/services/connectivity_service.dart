import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';
import 'connectivity_snapshot.dart';

export 'connectivity_snapshot.dart';

/// What the app knows about reaching the network and the backend.
///
/// It used to poll `GET /health/status` from every device every 30 seconds and
/// require a 200 from it — plus a `google.com` DNS lookup — before `isOnline`
/// would say yes. Two things were wrong with that.
///
/// It was expensive in the worst possible place. That endpoint opens a scope
/// and runs `Database.CanConnectAsync()`, so at a thousand active devices it
/// is ~33 database reachability checks a second before any real traffic, and a
/// database incident turns the health endpoint itself into extra load.
///
/// And it was the wrong authority. A separate probe is not evidence about the
/// requests the app actually makes: on LAN dev backends, captive Wi-Fi and
/// split-tunnel VPNs the probe fails while the API works fine. The first
/// sign-in restore path had already removed its `isOnline` preflight for
/// exactly this reason, and recorded why in a comment — while the ordinary
/// sync drain still trusted it. A device that could sync sat waiting for a
/// probe instead.
///
/// So: the OS link is a scheduling hint, and the outcome of each REAL request
/// is the record of reachability. Nothing here probes anything;
/// [recordBackendSuccess] and [recordBackendFailure] are called by ApiService
/// as ordinary calls succeed and fail.
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal()
    : _linkChangesOverride = null,
      _initialLinkOverride = null;

  /// Test seam: build one with an injected link source and clock.
  @visibleForTesting
  ConnectivityService.forTesting({
    Stream<List<ConnectivityResult>>? linkChanges,
    Future<List<ConnectivityResult>> Function()? initialLink,
    DateTime Function()? clock,
  }) : _linkChangesOverride = linkChanges,
       _initialLinkOverride = initialLink,
       _clock = clock ?? DateTime.now;

  final Connectivity _connectivity = Connectivity();
  final Stream<List<ConnectivityResult>>? _linkChangesOverride;
  final Future<List<ConnectivityResult>> Function()? _initialLinkOverride;
  DateTime Function() _clock = DateTime.now;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  ConnectivitySnapshot _snapshot = const ConnectivitySnapshot();

  /// The current state. Always safe to read — it starts `unknown`, never
  /// `offline`, so a cold-start consumer is not told the device is offline
  /// merely because nothing has been observed yet.
  ConnectivitySnapshot get snapshot => _snapshot;

  // ---- Compatibility surface -------------------------------------------
  //
  // Kept so the ~25 existing call sites keep compiling, but redefined in
  // terms of the snapshot. The meanings are now honest ones.

  /// Optimistic: true unless the OS says there is no link, or a real request
  /// recently failed. Unknown counts as online.
  bool get isOnline => _snapshot.isOnline;

  /// The OS reports a transport. This is a link fact, not a claim about the
  /// internet — nothing here resolves DNS to decide it any more.
  bool get hasNetworkConnection => _snapshot.link == LinkState.available;

  /// Same as [hasNetworkConnection]. Kept because AdService deliberately reads
  /// this rather than [isOnline]: ad networks are not our backend, and our
  /// backend being unreachable says nothing about whether ads can load.
  bool get hasInternetAccess => _snapshot.link == LinkState.available;

  /// Positive evidence only — a real request has succeeded and none has
  /// failed since.
  bool get isBackendReachable => _snapshot.isBackendConfirmedReachable;

  DateTime? get lastOnlineTime => _snapshot.lastBackendSuccessAt;

  /// Whether background work is worth attempting. False only when the OS is
  /// certain there is no transport.
  bool get shouldAttemptNetworkWork => _snapshot.shouldAttemptNetworkWork;

  // ---- Streams ----------------------------------------------------------

  final StreamController<ConnectivitySnapshot> _snapshotController =
      StreamController<ConnectivitySnapshot>.broadcast();

  /// Every material change, with the CURRENT value replayed to each new
  /// subscriber.
  ///
  /// The old stream was a bare broadcast of a bool with no replay, so a
  /// listener attached after the first transition simply missed it and waited
  /// for the next 30-second tick. It also only fired when the combined
  /// boolean flipped, which meant a change in link state alone was invisible
  /// to the settlement and ad listeners that specifically look at it.
  Stream<ConnectivitySnapshot> get snapshots async* {
    yield _snapshot;
    yield* _snapshotController.stream;
  }

  /// Legacy boolean stream, kept for existing subscribers. Emits on every
  /// material change (deduped on the boolean itself), and replays.
  Stream<bool> get onlineStatusStream =>
      snapshots.map((s) => s.isOnline).distinct();

  // ---- Lifecycle --------------------------------------------------------

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final changes =
        _linkChangesOverride ?? _connectivity.onConnectivityChanged;
    _connectivitySubscription = changes.listen(_onLinkChanged);

    // Awaited, unlike before. initialize() used to kick off an async check
    // without awaiting it and return, so the first consumer could read
    // "offline" purely because nothing had come back yet.
    try {
      final initial = _initialLinkOverride != null
          ? await _initialLinkOverride()
          : await _connectivity.checkConnectivity();
      _applyLink(initial);
    } catch (e) {
      // Leave the link unknown rather than guessing none — unknown still
      // permits work, and a guess of "none" would suppress it.
      AppLogger.error('ConnectivityService: initial link check failed', e);
    }
  }

  void _onLinkChanged(List<ConnectivityResult> results) => _applyLink(results);

  void _applyLink(List<ConnectivityResult> results) {
    final hasLink =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    final link = hasLink ? LinkState.available : LinkState.none;

    // Losing the link is the one thing that can make a backend observation
    // obsolete on the spot: whatever we last proved was proved over a
    // transport that no longer exists.
    final backend = link == LinkState.none
        ? BackendState.unknown
        : _snapshot.backend;

    _publish(_snapshot.copyWith(link: link, backend: backend));
  }

  // ---- Observations from real traffic -----------------------------------

  /// A real API call reached the backend. Called by ApiService.
  void recordBackendSuccess() {
    _publish(
      _snapshot.copyWith(
        // A successful call is also proof of a link, whatever the OS thinks.
        link: LinkState.available,
        backend: BackendState.reachable,
        lastBackendSuccessAt: _clock(),
        source: BackendObservationSource.apiCall,
      ),
    );
  }

  /// A real API call failed at the transport layer, timed out, or the server
  /// answered 5xx. Advisory: it lowers priority, it does not forbid retries.
  ///
  /// Deliberately NOT called for 4xx. A 401 or a 422 is proof the backend is
  /// reachable and answering — treating it as unreachable would be exactly the
  /// false negative this whole change exists to remove.
  void recordBackendFailure() {
    _publish(
      _snapshot.copyWith(
        backend: BackendState.unavailable,
        lastBackendFailureAt: _clock(),
        source: BackendObservationSource.apiCall,
      ),
    );
  }

  void _publish(ConnectivitySnapshot next) {
    if (next == _snapshot) return;
    _snapshot = next;
    if (!_snapshotController.isClosed) _snapshotController.add(next);
    notifyListeners();
  }

  /// Re-read the OS link. There is no health request here any more; callers
  /// that want to know whether the backend is reachable should make the call
  /// they actually wanted to make.
  Future<bool> checkNow() async {
    try {
      final result = _initialLinkOverride != null
          ? await _initialLinkOverride()
          : await _connectivity.checkConnectivity();
      _applyLink(result);
    } catch (e) {
      AppLogger.error('ConnectivityService: link re-check failed', e);
    }
    return isOnline;
  }

  Duration? getTimeSinceOnline() {
    final last = _snapshot.lastBackendSuccessAt;
    if (isOnline || last == null) return null;
    return _clock().difference(last);
  }

  /// Drive a link transition directly, without a platform channel.
  @visibleForTesting
  void forTestingApplyLink(List<ConnectivityResult> results) =>
      _applyLink(results);

  @visibleForTesting
  void resetForTesting() {
    _snapshot = const ConnectivitySnapshot();
    _isInitialized = false;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _snapshotController.close();
    super.dispose();
  }
}
