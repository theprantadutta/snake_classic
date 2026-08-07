import 'package:snake_classic/l10n/app_localizations.dart';

/// Stable multiplayer error codes carried in state instead of baked
/// English sentences. Emitted by [MultiplayerService] /
/// [MultiplayerCubit] and resolved to a localized message at render
/// time via [MultiplayerErrorL10n.localizedMessage].
enum MultiplayerError {
  matchmaking,
  createFailed,
  joinFailed,
  readyFailed,
  startFailed,
  startTimeout,
  /// A matchmade lobby expired because both players did not confirm
  /// READY inside the deadline. Not a failure — the player is being
  /// requeued — but it explains why the lobby vanished.
  readyTimeout,
  reconnectFailed,
  connectionLost,
  matchEndedAway,
  waitingReady,
  onlyHost,
  sessionExpired,
  alreadyStarted,
  needTwoPlayers,
  signIn,
  reconnectExpired,
  checkInternet,
  unableJoin,
  generic,
}

/// Render-time resolution of a [MultiplayerError] to a localized,
/// user-facing message. The single mapping shared by every render site.
extension MultiplayerErrorL10n on MultiplayerError {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
        MultiplayerError.matchmaking => l10n.mpErrMatchmaking,
        MultiplayerError.createFailed => l10n.mpErrCreateFailed,
        MultiplayerError.joinFailed => l10n.mpErrJoinFailed,
        MultiplayerError.readyFailed => l10n.mpErrReadyFailed,
        MultiplayerError.startFailed => l10n.mpErrStartFailed,
        MultiplayerError.startTimeout => l10n.mpErrStartTimeout,
        MultiplayerError.readyTimeout => l10n.mpErrReadyTimeout,
        MultiplayerError.reconnectFailed => l10n.mpErrReconnectFailed,
        MultiplayerError.connectionLost => l10n.mpErrConnectionLost,
        MultiplayerError.matchEndedAway => l10n.mpErrMatchEndedAway,
        MultiplayerError.waitingReady => l10n.mpErrWaitingReady,
        MultiplayerError.onlyHost => l10n.mpErrOnlyHost,
        MultiplayerError.sessionExpired => l10n.mpErrSessionExpired,
        MultiplayerError.alreadyStarted => l10n.mpErrAlreadyStarted,
        MultiplayerError.needTwoPlayers => l10n.mpErrNeedTwoPlayers,
        MultiplayerError.signIn => l10n.mpErrSignIn,
        MultiplayerError.reconnectExpired => l10n.mpErrReconnectExpired,
        MultiplayerError.checkInternet => l10n.mpErrCheckInternet,
        MultiplayerError.unableJoin => l10n.mpErrUnableJoin,
        MultiplayerError.generic => l10n.mpErrGeneric,
      };
}
