/// Sentry wiring for the app. Replaced Firebase Crashlytics.
///
/// Everything Sentry needs to know lives here rather than in main.dart, so
/// main() reads as "configure Sentry, then boot the app" and the tuning
/// decisions (sample rates, masking, what counts as a crash) sit in one file
/// with their reasons attached.
library;

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:snake_classic/core/observability/error_classification.dart';
import 'package:snake_classic/utils/logger.dart';

/// The project's DSN — `snake-classic-flutter` in the `pranta-corp` org.
///
/// Checked in on purpose. A DSN is not a secret: it is a write-only ingest
/// endpoint that ships inside every APK and IPA anyway, so anyone with the
/// app already has it. The alternative — reading it from `.env`, which is
/// gitignored — would mean a fresh clone or a CI runner silently builds an
/// app with no crash reporting at all, and nothing would fail to tell us.
///
/// `--dart-define=SENTRY_DSN=...` still overrides it, which is how you would
/// point a fork or a staging build somewhere else.
const String sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue:
      'https://ffbb7e1dc5919c720a212503e1dfe739@o4512111326199808.ingest.us.sentry.io/4512111364734976',
);

/// Which Sentry environment this build reports into.
///
/// Crashlytics had no such concept, so the old code had to disable collection
/// outright in debug and profile to keep local crashes out of the production
/// dashboard — which also meant that during development the crash reporter
/// was the one thing you could never actually test. Sentry separates events
/// by environment instead, so every build reports and the production view
/// stays clean by filtering. Profile builds are called out separately because
/// they are the ones used for performance work, and their traces would
/// otherwise be indistinguishable from real users'.
String get sentryEnvironment {
  if (kReleaseMode) return 'production';
  if (kProfileMode) return 'profile';
  return 'development';
}

/// Hosts that may receive `sentry-trace` / `baggage` headers, linking a tap
/// in the app to the request it caused on the API.
///
/// Explicit rather than the SDK default of `['.*']`: that default attaches
/// our trace headers to EVERY outbound request, including Firebase, Google
/// Sign-In and AdMob. Third parties have no use for them, some reject
/// unexpected headers outright, and sending our internal trace ids to
/// somebody else's server is not something to do by accident.
const List<String> _tracePropagationTargets = [
  // Production API.
  'snakeclassic\\.pranta\\.dev',
  // Local development backends — a LAN address (the pattern in .env's
  // DEV_API_BACKEND_URL) or a loopback/emulator host.
  '^https?://192\\.168\\.',
  '^https?://10\\.0\\.2\\.2',
  '^https?://localhost',
];

/// Applies the app's Sentry configuration. Passed straight to
/// `SentryFlutter.init` in main().
void configureSentryOptions(SentryFlutterOptions options) {
  options.dsn = sentryDsn;
  options.environment = sentryEnvironment;

  // Release is auto-detected on Android/iOS from the package info as
  // "com.pranta.snakeclassic@6.5.0+55", which is exactly the identifier
  // sentry_dart_plugin uploads debug symbols against. Do not set it by hand
  // or the two stop lining up and every release trace goes unsymbolicated.

  // SDK's own diagnostic chatter. Useful while wiring this up, never in a
  // build a player runs.
  options.debug = !kReleaseMode;

  // ---- Privacy -----------------------------------------------------------
  //
  // Off deliberately. `sendDefaultPii` would attach the device's IP address
  // and, in replays, unmasked widget text. The app asks for privacy consent
  // on a dedicated screen before it collects anything optional, and a crash
  // reporter that quietly opts everyone in regardless would make that screen
  // a lie. Nothing about diagnosing a crash needs to know who it happened to.
  options.sendDefaultPii = false;

  // ---- Errors ------------------------------------------------------------
  //
  // Every error, always. The classifier below decides how LOUD an error is,
  // not whether it is heard; sampling errors away is how you lose the one
  // report of the bug nobody can reproduce.
  options.sampleRate = 1.0;
  options.beforeSend = _classifyBeforeSend;

  // FlutterErrorDetails.silent stays unreported (this is the SDK default,
  // restated because it is load-bearing): the framework sets it for errors it
  // considers expected and does not even print in debug — image decode and
  // resolve failures, mostly. That is the same judgement isRecoverableError
  // makes for `silent: true`, so the two agree.
  options.reportSilentFlutterErrors = false;

  // Screenshot + widget tree alongside the stack trace. The screenshot is
  // masked by the same privacy rules as replay (below), so it shows layout,
  // not content.
  options.attachScreenshot = true;
  // Experimental in the SDK, hence the ignore. Worth the risk: a layout
  // overflow or a constraints assertion is nearly unreadable from the stack
  // trace alone, and the serialized widget tree says immediately which
  // subtree was wrong. If a future SDK drops it, the analyzer will say so.
  // ignore: experimental_member_use
  options.attachViewHierarchy = true;

  // ANRs. A 60 FPS game that stops answering the main thread for five
  // seconds is broken in a way no exception will ever report.
  options.anrEnabled = true;

  // ---- Tracing -----------------------------------------------------------
  //
  // 20% in production is enough to see app-start regressions and slow
  // screens without spending the whole quota on transactions. Everything in
  // development, because there the point is to see what you just changed.
  options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;

  // Time to Full Display. TTID (first frame) is always on, but for this app
  // it measures almost nothing: every screen paints its chrome immediately
  // and then waits on Drift or the API. TTFD is the number that matters, and
  // it is opt-in.
  options.enableTimeToFullDisplayTracing = true;

  // Distributed tracing into the .NET API. propagateTraceparent adds the W3C
  // header next to Sentry's own, so the backend links the two even where it
  // is reading OpenTelemetry rather than Sentry headers.
  options.tracePropagationTargets
    ..clear()
    ..addAll(_tracePropagationTargets);
  options.propagateTraceparent = true;

  // Failed HTTP requests become their own events. Bodies are never captured
  // — ours carry auth tokens and purchase receipts.
  options.captureFailedRequests = true;
  options.maxRequestBodySize = MaxRequestBodySize.never;

  // ---- Session Replay ----------------------------------------------------
  //
  // iOS and Android only; a no-op elsewhere.
  //
  // Always record the session that ended in an error — for a game, watching
  // the actual run that led to the crash is worth more than any breadcrumb
  // trail. Sample a thin slice of ordinary sessions in production to have
  // something to compare against; record none of them in development, where
  // a constant screen recorder is just overhead on the frame budget.
  // Error sessions only. Ordinary-session sampling is OFF.
  //
  // Replay is the smallest quota on Sentry's free plan by a wide margin, and
  // sampling ordinary sessions spends it on recordings of nothing happening.
  // At 5% of all sessions a few hundred players a day would exhaust the
  // month in days, after which replay stops recording — including for the
  // crashes it exists to explain. Error sessions are the ones worth having,
  // and at current volume (9 error events in 14 days) they fit comfortably.
  //
  // Set sessionSampleRate back above zero if the plan changes, or
  // temporarily when chasing something that only reproduces mid-session.
  options.replay.onErrorSampleRate = 1.0;
  options.replay.sessionSampleRate = 0.0;

  // Mask everything by default: usernames, friend lists, leaderboard entries
  // and profile avatars are all somebody's data. What is left — the board,
  // the snake, which buttons were pressed and in what order — is the part
  // that actually explains the crash.
  options.privacy.maskAllText = true;
  options.privacy.maskAllImages = true;

  // ---- Logs --------------------------------------------------------------
  //
  // Structured logs, correlated with the trace that produced them. AppLogger
  // still owns local console output; this is the copy that survives the
  // session.
  options.enableLogs = true;
}

/// Downgrades errors the app recovers from so they are not filed as crashes.
///
/// See [isRecoverableError] for the full story. In short: a player's Google
/// avatar failing to download is not a crash, but it reaches the global
/// Flutter error handler like one, and left alone it both suppresses the
/// crash-free rate Play Console ranks on and buries real crashes underneath
/// its volume.
///
/// The event is still SENT — the volume stays visible, and "avatar downloads
/// are failing for everyone in Brazil" is a real signal — it is just filed as
/// a warning rather than as something that killed the app.
SentryEvent? _classifyBeforeSend(SentryEvent event, Hint hint) {
  final throwable = event.throwable;
  if (throwable == null || !isRecoverableError(throwable)) return event;

  event.level = SentryLevel.warning;

  // Also mark it handled, so it does not count against release health. The
  // mechanism is what Sentry reads for "did this crash the app", and the
  // integrations set it to unhandled for anything that came through
  // FlutterError.onError — which is precisely the path these arrive on.
  final mechanism = event.throwableMechanism;
  if (mechanism is ThrowableMechanism) {
    mechanism.mechanism.handled = true;
  }

  return event;
}

/// Reports a failure that stopped the app from starting.
///
/// A failure that stops the app from starting is the single most important
/// thing to hear about, and it used to be the only class of failure reporting
/// nothing at all: every [AppLogger] method is wrapped in `if (kDebugMode)`,
/// so in a release build those calls compile to nothing — which is why the
/// "Snake Classic couldn't start" screen could be reproduced on a real device
/// with an empty logcat AND an empty dashboard.
///
/// [fatal] distinguishes "the player did not get an app" from "the player got
/// a degraded one". Only the former should move the crash-free rate.
///
/// Deliberately carries no user identifiers: the error and its stack are what
/// diagnose this, and a startup path that runs before consent is the last
/// place to be attaching anything about a person.
///
/// Unlike the Crashlytics version this replaced, there is no "only if
/// Firebase came up" guard. Sentry is initialized before anything else in
/// main(), so a failure that happens before Firebase — previously the one
/// kind of startup crash that was structurally unreportable — now reports
/// like any other.
Future<void> reportStartupFailure(
  Object error,
  StackTrace stackTrace, {
  required String reason,
  required bool fatal,
}) async {
  // Still logged for anyone attached to a debug session.
  AppLogger.error(reason, error, stackTrace);

  try {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.level = fatal ? SentryLevel.fatal : SentryLevel.error;
        // Searchable: `startup_failure:true` finds every one of these, and
        // the reason separates "timed out" from "threw" from "retry failed".
        scope.setTag('startup_failure', 'true');
        scope.setContexts('startup', {'reason': reason, 'fatal': fatal});
      },
    );
  } catch (_) {
    // Reporting a startup failure must never become one.
  }
}
