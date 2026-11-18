import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/design/miami_nights_scene.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_state.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// Device-local flag: the Miami Nights announcement has been shown. Once
/// per install, never synced (it's a nudge, not an entitlement).
const String miamiNightsPromoSeenKey = 'event_promo_miami_nights_seen';

/// Show the one-time "try the free Miami Nights theme" sheet if it's due:
/// the free window is open, the player isn't already on the theme, no run
/// is live, and this install hasn't seen it. Returns whether it was shown,
/// so the Home prompt queue can count it as the visit's interruption.
Future<bool> maybeShowMiamiNightsPromo(BuildContext context) async {
  if (!PremiumContent.isEventFree(GameTheme.miamiNights)) return false;
  final themeCubit = context.read<ThemeCubit>();
  if (themeCubit.state.currentTheme == GameTheme.miamiNights) return false;
  if (_runIsLive(context)) return false;

  final SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    return false;
  }
  if (prefs.getBool(miamiNightsPromoSeenKey) ?? false) return false;
  // Marked before showing: a crash or kill mid-sheet must not re-show it.
  await prefs.setBool(miamiNightsPromoSeenKey, true);
  if (!context.mounted) return false;

  final analytics = getIt.isRegistered<AnalyticsFacade>()
      ? getIt<AnalyticsFacade>()
      : null;
  final l10n = AppLocalizations.of(context)!;
  final untilDate = AppFormats.monthDay(
    PremiumContent.miamiNightsLastFreeDay,
    Localizations.localeOf(context),
  );
  analytics?.trackThemePromo(action: 'shown');
  final accepted = await showLBSheet<bool>(
    context: context,
    title: l10n.promoMiamiTitle,
    builder: (_) => _MiamiPromoBody(untilDate: untilDate),
  );
  if (accepted == true) {
    analytics?.trackThemePromo(action: 'accepted');
    await themeCubit.setTheme(GameTheme.miamiNights);
  } else {
    analytics?.trackThemePromo(action: 'dismissed');
  }
  return true;
}

bool _runIsLive(BuildContext context) {
  try {
    final status = context.read<GameCubit>().state.status;
    return status == GamePlayStatus.playing ||
        status == GamePlayStatus.paused ||
        status == GamePlayStatus.crashed;
  } catch (_) {
    return false;
  }
}

class _MiamiPromoBody extends StatefulWidget {
  const _MiamiPromoBody({required this.untilDate});

  final String untilDate;

  @override
  State<_MiamiPromoBody> createState() => _MiamiPromoBodyState();
}

class _MiamiPromoBodyState extends State<_MiamiPromoBody> {
  /// The first NOT NOW doesn't close the sheet: it asks once more, since
  /// the theme is free now and costs money later.
  bool _askedTwice = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final scale = context.uiScale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A live preview of the theme itself, not a screenshot.
        ClipRRect(
          borderRadius: BorderRadius.circular(LB.blockRadius),
          child: SizedBox(
            height: 170 * scale,
            child: const CustomPaint(painter: _PreviewPainter()),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _askedTwice
              ? l10n.promoMiamiSure(widget.untilDate)
              : l10n.promoMiamiBody(widget.untilDate),
          style: LBText.body(p, color: p.ink.withValues(alpha: .85), size: 13),
        ),
        const SizedBox(height: 16),
        LBPrimaryBlock(
          label: _askedTwice ? l10n.promoMiamiSureYes : l10n.promoMiamiTry,
          height: 52 * scale,
          onTap: () => Navigator.of(context).pop(true),
        ),
        LBBlock(
          kind: LBBlockKind.muted,
          height: 48 * scale,
          alignment: Alignment.center,
          onTap: () {
            if (_askedTwice) {
              Navigator.of(context).pop(false);
              return;
            }
            if (getIt.isRegistered<AnalyticsFacade>()) {
              getIt<AnalyticsFacade>().trackThemePromo(action: 'second_ask');
            }
            setState(() => _askedTwice = true);
          },
          child: Text(
            (_askedTwice ? l10n.promoMiamiSureNo : l10n.dfNotNow).toUpperCase(),
            style: LBText.button(p, color: p.inkMuted),
          ),
        ),
      ],
    );
  }
}

/// The scene with a short pink-to-orange snake crossing the sun.
class _PreviewPainter extends CustomPainter {
  const _PreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    MiamiNightsScene.paint(canvas, size, dim: .15);
    final cell = size.height / 9;
    final y = size.height * .64 - cell * 1.6;
    final x0 = size.width * .5 - cell * 3.5;
    const pink = GameConstants.miamiNightsSnake;
    const orange = GameConstants.miamiNightsAccent;
    final paint = Paint();
    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      paint.color = Color.lerp(orange, pink, t)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x0 + i * cell * 1.08, y, cell, cell),
          Radius.circular(cell * (i == 5 ? .25 : .15)),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => false;
}
