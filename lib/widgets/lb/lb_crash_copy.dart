import 'dart:math' as math;

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';

/// Why a run ended, as the copy deck names it (COPY.md "Crash headlines").
enum LBEndReason { wall, self, timeout, stepped, quit }

/// The cell-font title, the plain line under it, and an optional tagline.
class LBCrashCopy {
  const LBCrashCopy(this.title, this.line, [this.tagline]);

  final String title;
  final String line;
  final String? tagline;

  /// Resolves the end reason for a finished or crashed [state].
  static LBEndReason reasonOf(GameState state) {
    if (state.crashReason == CrashReason.wallCollision) return LBEndReason.wall;
    if (state.crashReason == CrashReason.selfCollision) {
      return state.gameMode.enforcesNoRevisit ? LBEndReason.stepped : LBEndReason.self;
    }
    if (state.gameMode == GameMode.timeAttack) return LBEndReason.timeout;
    return LBEndReason.quit;
  }

  /// One of the reason's lines, picked with [seed] so a screen keeps the
  /// same joke across rebuilds.
  static LBCrashCopy of(
    AppLocalizations l10n,
    LBEndReason reason, {
    required int length,
    required int food,
    int seed = 0,
  }) {
    final r = math.Random(seed);
    switch (reason) {
      case LBEndReason.wall:
        final lines = [l10n.lbCrashWall1('$length'), l10n.lbCrashWall2, l10n.lbCrashWall3];
        return LBCrashCopy(l10n.lbCrashWallTitle, lines[r.nextInt(lines.length)], l10n.lbCrashWallScore);
      case LBEndReason.self:
        final lines = [l10n.lbCrashSelf1, l10n.lbCrashSelf2, l10n.lbCrashSelf3];
        return LBCrashCopy(l10n.lbCrashSelfTitle, lines[r.nextInt(lines.length)]);
      case LBEndReason.timeout:
        final lines = [l10n.lbCrashTime1, l10n.lbCrashTime2('$food')];
        return LBCrashCopy(l10n.lbCrashTimeTitle, lines[r.nextInt(lines.length)]);
      case LBEndReason.stepped:
        return LBCrashCopy(l10n.lbCrashStepTitle, l10n.lbCrashStep1);
      case LBEndReason.quit:
        return LBCrashCopy(l10n.lbCrashQuitTitle, l10n.lbCrashQuit1);
    }
  }
}
