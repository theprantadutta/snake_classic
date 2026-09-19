/// Whether an error is something the app recovers from, and therefore must
/// not be filed as a CRASH.
///
/// The original report was "Fatal Exception … HttpException: Connection closed
/// before full header was received, uri = https://lh3.googleusercontent.com/…"
/// — a user's Google profile picture failing to download. The app does not die
/// from that; the avatar just falls back. But the error surfaces through
/// [FlutterError.reportError], the global handler filed EVERYTHING as fatal,
/// and so a flaky connection while a leaderboard scrolled registered as a
/// crash.
///
/// It is not merely cosmetic. Those reports suppress the crash-free rate that
/// Play Console ranks on, and they bury real crashes in the issue list — the
/// replay-viewer fatal was sitting underneath exactly this kind of noise.
///
/// Note that every avatar in the app ALREADY passes onBackgroundImageError or
/// errorBuilder. Flutter routes an image failure to those listeners only if a
/// listener is still attached when it lands; if the widget was disposed first
/// (scrolled away, navigated off — precisely when slow images fail) the error
/// falls through to FlutterError instead. Handling it at the widget is
/// necessary but cannot be sufficient, which is why this classifier exists.
///
/// Deliberately string-based rather than `is SocketException` etc.: `dart:io`
/// is not web-safe and this is reachable from the web build. Deliberately
/// narrow, too — anything not positively identified stays fatal, because a
/// misfiled crash is far worse than a misfiled non-crash.
///
/// Lives here rather than in main.dart because two callers need it: the Sentry
/// `beforeSend` hook (which downgrades the event's level) and the test that
/// pins these rules. It used to be private to main.dart, which meant the test
/// kept a hand-copied duplicate that could silently drift.
library;

/// Types whose failure means "the network had a bad moment", never "the app
/// is broken".
const _recoverableTypes = {
  'NetworkImageLoadException', // HTTP status != 200 for an image
  'SocketException', // connection reset / no route / abort
  'HttpException', // truncated response, bad headers
  'HandshakeException', // TLS negotiation failed
  'ClientException', // package:http transport failure
  'TimeoutException', // a bounded wait elapsed
};

/// See the library docs above.
///
/// [silent] is `FlutterErrorDetails.silent` — the framework's own verdict that
/// an error is expected enough not to print in debug. Image decode/resolve
/// failures set it.
bool isRecoverableError(Object error, {bool silent = false}) {
  if (silent) return true;

  if (_recoverableTypes.contains(error.runtimeType.toString())) return true;

  // Fallback for wrapped/renamed transport errors that still name the host or
  // the failure in their message.
  final message = error.toString();
  return message.contains('lh3.googleusercontent.com') ||
      message.contains('Connection closed before full header was received');
}
