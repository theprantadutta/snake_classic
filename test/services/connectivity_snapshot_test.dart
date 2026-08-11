import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/connectivity_service.dart';

/// What the app believes about reaching the network, and what it is allowed to
/// conclude from it.
///
/// The rule this replaced polled `GET /health/status` — a database-backed
/// endpoint — from every device every 30 seconds, and required a 200 from it
/// plus a `google.com` DNS lookup before it would say "online". That was the
/// permission gate for all sync work, which meant a probe failing on a LAN dev
/// backend, captive Wi-Fi or a split-tunnel VPN silently froze an outbox that
/// would have drained perfectly well.
void main() {
  group('what the state means', () {
    test('starts unknown, and unknown is usable', () {
      const snapshot = ConnectivitySnapshot();

      expect(snapshot.link, LinkState.unknown);
      expect(snapshot.backend, BackendState.unknown);

      // The important one. Cold start must not read as offline, or the app
      // talks itself out of working before it has looked.
      expect(snapshot.shouldAttemptNetworkWork, isTrue);
      expect(snapshot.isOnline, isTrue);
    });

    test('no link is the only state that forbids work', () {
      const noLink = ConnectivitySnapshot(link: LinkState.none);
      expect(noLink.shouldAttemptNetworkWork, isFalse);
      expect(noLink.isOnline, isFalse);
    });

    test('a backend believed unavailable may still be attempted', () {
      // Otherwise nothing ever clears it: the only thing that can prove the
      // backend is back is a request being allowed to try.
      const snapshot = ConnectivitySnapshot(
        link: LinkState.available,
        backend: BackendState.unavailable,
      );

      expect(snapshot.shouldAttemptNetworkWork, isTrue);
      expect(snapshot.isOnline, isFalse, reason: 'the UI may still say so');
    });

    test('reachable requires positive evidence', () {
      const unknown = ConnectivitySnapshot(link: LinkState.available);
      expect(unknown.isBackendConfirmedReachable, isFalse);

      const reachable = ConnectivitySnapshot(
        link: LinkState.available,
        backend: BackendState.reachable,
      );
      expect(reachable.isBackendConfirmedReachable, isTrue);
    });
  });

  group('a false negative must not freeze the outbox', () {
    // The scenario from the audit, and the reason the whole change exists.
    // SyncEngine._drain gates on shouldAttemptNetworkWork; these are the
    // states it is asked about.

    test('LAN dev backend: probe unreachable, link fine — still attempt', () {
      // The probe cannot resolve the backend but the API is reachable over
      // the same link. The old gate refused to sync here.
      const afterFailedProbe = ConnectivitySnapshot(
        link: LinkState.available,
        backend: BackendState.unavailable,
      );
      expect(afterFailedProbe.shouldAttemptNetworkWork, isTrue);
    });

    test('captive Wi-Fi: nothing observed yet — still attempt', () {
      const cold = ConnectivitySnapshot(link: LinkState.available);
      expect(cold.backend, BackendState.unknown);
      expect(cold.shouldAttemptNetworkWork, isTrue);
    });

    test('a later success clears the bad observation', () {
      // Something has to be able to prove the backend is back, and the only
      // thing that can is a request that was allowed to run.
      final service = ConnectivityService.forTesting(
        linkChanges: const Stream<List<ConnectivityResult>>.empty(),
        initialLink: () async => [ConnectivityResult.wifi],
      );

      service.recordBackendFailure();
      expect(service.snapshot.backend, BackendState.unavailable);
      expect(service.shouldAttemptNetworkWork, isTrue,
          reason: 'the attempt that clears this must be permitted');

      service.recordBackendSuccess();
      expect(service.snapshot.backend, BackendState.reachable);
      expect(service.isOnline, isTrue);
    });

    test('only a definite absence of link stops work', () {
      const none = ConnectivitySnapshot(link: LinkState.none);
      expect(none.shouldAttemptNetworkWork, isFalse);

      for (final state in [BackendState.unknown, BackendState.unavailable, BackendState.reachable]) {
        final withLink = ConnectivitySnapshot(
          link: LinkState.available,
          backend: state,
        );
        expect(withLink.shouldAttemptNetworkWork, isTrue,
            reason: 'backend ${state.name} must never block an attempt');
      }
    });
  });

  group('transitions', () {
    late ConnectivityService service;
    late StreamController<List<ConnectivityResult>> links;

    setUp(() {
      // Both the initial read AND the change stream are injected: touching
      // the real plugin would reach for a platform channel that does not
      // exist in a unit test, which is the point of the seam.
      links = StreamController<List<ConnectivityResult>>.broadcast();
      service = ConnectivityService.forTesting(
        linkChanges: links.stream,
        initialLink: () async => [ConnectivityResult.wifi],
        clock: () => DateTime.utc(2026, 8, 11, 12),
      );
    });

    tearDown(() => links.close());

    test('initialize awaits the first link read', () async {
      await service.initialize();

      // The old initialize() kicked off an async check without awaiting it,
      // so the first consumer could read "offline" purely because nothing had
      // come back yet.
      expect(service.snapshot.link, LinkState.available);
    });

    test('a subscriber attached late still receives the current state',
        () async {
      await service.initialize();
      service.recordBackendSuccess();

      // Attached after every transition has already happened. The old stream
      // was a bare broadcast with no replay, so this listener would have
      // waited for the next 30-second tick to learn anything.
      final first = await service.snapshots.first;

      expect(first.link, LinkState.available);
      expect(first.backend, BackendState.reachable);
    });

    test('losing the link discards the backend observation', () async {
      await service.initialize();
      service.recordBackendSuccess();
      expect(service.snapshot.backend, BackendState.reachable);

      service.forTestingApplyLink([ConnectivityResult.none]);

      // Whatever was proved was proved over a transport that is now gone.
      expect(service.snapshot.link, LinkState.none);
      expect(service.snapshot.backend, BackendState.unknown);
      expect(service.shouldAttemptNetworkWork, isFalse);
    });

    test('a successful call proves a link even if the OS has not caught up',
        () async {
      service.forTestingApplyLink([ConnectivityResult.none]);
      expect(service.shouldAttemptNetworkWork, isFalse);

      service.recordBackendSuccess();

      expect(service.snapshot.link, LinkState.available);
      expect(service.shouldAttemptNetworkWork, isTrue);
    });

    test('success and failure are both recorded with a timestamp', () async {
      await service.initialize();

      service.recordBackendSuccess();
      expect(service.snapshot.lastBackendSuccessAt, isNotNull);
      expect(service.snapshot.source, BackendObservationSource.apiCall);

      service.recordBackendFailure();
      expect(service.snapshot.backend, BackendState.unavailable);
      expect(service.snapshot.lastBackendFailureAt, isNotNull);
      // The success is still on file — "last contact succeeded at X" is more
      // useful to a player than a bare offline icon.
      expect(service.snapshot.lastBackendSuccessAt, isNotNull);
    });

    test('the legacy boolean stream still works, and replays', () async {
      await service.initialize();
      final seen = <bool>[];
      final sub = service.onlineStatusStream.listen(seen.add);

      await Future<void>.delayed(Duration.zero);
      service.recordBackendFailure();
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      expect(seen.first, isTrue, reason: 'replayed the current value');
      expect(seen.last, isFalse);
    });
  });
}
