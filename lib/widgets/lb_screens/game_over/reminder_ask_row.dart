import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// "Remind me tomorrow: one nudge to beat 340." on the game-over card after
/// a new best, while notifications are off (retention plan 2026-11, D1).
///
/// The notification permission used to be asked only after three games and
/// about three Home visits, after most players who leave on day 1 had gone,
/// so the day-1 reminder was silently dropped by Android 13+ for exactly the
/// players it was for. This asks at a moment the reminder means something,
/// inline (no dialog to stack on the level-up or sign-in prompts).
///
/// Shown until the player accepts, or dismisses it twice.
class ReminderAskRow extends StatefulWidget {
  const ReminderAskRow({super.key, required this.score});

  /// The best score the reminder will point at.
  final int score;

  /// Shared with the Home soft-ask (NotificationPermissionSoftAsk), so a
  /// player asked here isn't asked again by that dialog.
  static const String softAskShownKey = 'notif_soft_ask_shown';
  static const String _dismissedKey = 'reminder_ask_dismissed';
  static const int _maxDismissals = 2;

  @override
  State<ReminderAskRow> createState() => _ReminderAskRowState();
}

enum _AskState { checking, hidden, asking, done }

class _ReminderAskRowState extends State<ReminderAskRow> {
  _AskState _state = _AskState.checking;

  AnalyticsFacade? get _analytics =>
      getIt.isRegistered<AnalyticsFacade>() ? getIt<AnalyticsFacade>() : null;

  @override
  void initState() {
    super.initState();
    unawaited(_decide());
  }

  Future<void> _decide() async {
    var show = false;
    try {
      final enabled = await NotificationService().areNotificationsEnabled();
      if (!enabled) {
        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getInt(ReminderAskRow._dismissedKey) ?? 0;
        show = dismissed < ReminderAskRow._maxDismissals;
      }
    } catch (_) {
      show = false;
    }
    if (!mounted) return;
    setState(() => _state = show ? _AskState.asking : _AskState.hidden);
    if (show) {
      unawaited(
        _analytics?.trackNotificationPermission(
          stage: 'soft_shown',
          placement: 'first_best',
        ),
      );
    }
  }

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context)!;
    unawaited(
      _analytics?.trackNotificationPermission(
        stage: 'soft_accepted',
        placement: 'first_best',
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ReminderAskRow.softAskShownKey, true);
    final granted = await NotificationService().requestPermissionFlow();
    unawaited(
      _analytics?.trackNotificationPermission(
        stage: granted ? 'os_granted' : 'os_denied',
        placement: 'first_best',
      ),
    );
    unawaited(_analytics?.setNotificationPermission(granted ? 'granted' : 'denied'));
    if (granted) {
      // The game-over screen already tried to arm it, before permission
      // existed; arm it again now that it can actually be shown.
      unawaited(
        NotificationService().scheduleDayOneReminder(
          highScore: widget.score,
          l10n: l10n,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _state = granted ? _AskState.done : _AskState.hidden);
  }

  Future<void> _dismiss() async {
    unawaited(
      _analytics?.trackNotificationPermission(
        stage: 'soft_declined',
        placement: 'first_best',
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    final n = prefs.getInt(ReminderAskRow._dismissedKey) ?? 0;
    await prefs.setInt(ReminderAskRow._dismissedKey, n + 1);
    if (mounted) setState(() => _state = _AskState.hidden);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    switch (_state) {
      case _AskState.checking:
      case _AskState.hidden:
        return const SizedBox.shrink();
      case _AskState.done:
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: LBRow(
            leading: LBPixelIcon(LBIcon.check, cell: 3.2, color: p.lime),
            title: l10n.goRemindSet,
          ),
        );
      case _AskState.asking:
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: LBRow(
            kind: LBBlockKind.gold,
            leading: const LBPixelIcon(LBIcon.buzz, cell: 3.2, color: LB.gold),
            title: l10n.goRemindTitle,
            subtitle: l10n.goRemindBody(context.formatInt(widget.score)),
            onTap: _accept,
            trailing: Semantics(
              button: true,
              label: l10n.npNotNow,
              excludeSemantics: true,
              onTap: _dismiss,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: LBPixelIcon(LBIcon.x, cell: 2.6, color: p.inkDim),
                ),
              ),
            ),
          ),
        );
    }
  }
}
