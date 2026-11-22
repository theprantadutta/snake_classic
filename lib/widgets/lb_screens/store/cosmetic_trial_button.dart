import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/temporary_grants_service.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_parts.dart';

/// Whether the store should offer "try it for a day" on a locked premium
/// item right now: ads can be shown (so never for Pro, who has every
/// cosmetic anyway) and no other ad trial is running (one at a time).
bool cosmeticTrialAvailable() {
  if (!getIt.isRegistered<AdService>() ||
      !getIt.isRegistered<TemporaryGrantsService>()) {
    return false;
  }
  if (!getIt<AdService>().adsEnabled) return false;
  return getIt<TemporaryGrantsService>().activeAdTrial == null;
}

/// "TRY 1 DAY · 2 ADS": a rewarded ad per tap. Progress (0/2, 1/2) is kept
/// for the day by [TemporaryGrantsService]; the second completed ad unlocks
/// the item for 24 hours and puts it on. An ad closed early counts for
/// nothing.
class CosmeticTrialButton extends StatefulWidget {
  const CosmeticTrialButton({
    super.key,
    required this.kind,
    required this.id,
    required this.displayName,
  });

  final TemporaryGrantKind kind;

  /// Skin id, trail id, or [TemporaryGrant.themeGrantId].
  final String id;
  final String displayName;

  @override
  State<CosmeticTrialButton> createState() => _CosmeticTrialButtonState();
}

class _CosmeticTrialButtonState extends State<CosmeticTrialButton> {
  StreamSubscription<TemporaryGrantLedger>? _sub;
  bool _busy = false;

  TemporaryGrantsService get _grants => getIt<TemporaryGrantsService>();

  @override
  void initState() {
    super.initState();
    _sub = _grants.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _watch() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final premium = context.read<PremiumCubit>();
    final ads = getIt<AdService>();
    final analytics = getIt<AnalyticsFacade>();

    setState(() => _busy = true);
    try {
      var rewarded = false;
      final outcome = await ads.showRewardedOrWait(
        placement: AdService.placementCosmeticTrial,
        onReward: () => rewarded = true,
        onWaitStart: () => messenger.showSnackBar(
          arcadeSnackBarFor(theme, message: l10n.rvoLoadingAd),
        ),
      );
      if (outcome == RewardedOutcome.unavailable) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          arcadeSnackBarFor(
            theme,
            message: l10n.homeNoAdReady,
            tone: ArcadeSnackTone.warning,
          ),
        );
        return;
      }
      if (!rewarded) return; // closed early: it doesn't count

      final watched = await _grants.recordTrialAd(widget.kind, widget.id);
      if (watched >= CosmeticTrialProgress.adsRequired) {
        await premium.grantCosmeticTrial(widget.kind, widget.id);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          arcadeSnackBarFor(
            theme,
            message: l10n.storeTrialUnlockedToast(widget.displayName),
            tone: ArcadeSnackTone.success,
          ),
        );
      } else {
        analytics.trackCosmeticTrial(
          stage: 'ad_1_done',
          cosmeticType: widget.kind.name,
          cosmeticId: widget.id,
        );
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          arcadeSnackBarFor(theme, message: l10n.storeTrialHalfToast),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final watched = _grants.trialAdsWatched(widget.kind, widget.id);
    return StoreActionBlock(
      label: watched == 0 ? l10n.storeTrialStart : l10n.storeTrialOneLeft,
      kind: LBBlockKind.outline,
      busy: _busy,
      onTap: _watch,
    );
  }
}

/// Footnote for an item the player is wearing on a temporary unlock.
String? temporaryUnlockFootnote(
  AppLocalizations l10n,
  PremiumState premium,
  TemporaryGrantKind kind,
  String id, {
  required bool permanentlyOwned,
}) {
  if (permanentlyOwned) return null;
  final expiry = premium.temporaryUnlockExpiry(kind, id);
  if (expiry == null) return null;
  final minutes = expiry.difference(DateTime.now()).inMinutes;
  final hours = ((minutes + 59) ~/ 60).clamp(1, 24);
  return l10n.storeTrialEndsIn(hours);
}
