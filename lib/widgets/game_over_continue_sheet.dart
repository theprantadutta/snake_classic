import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/tap_arm_guard.dart';

/// The game-over CONTINUE choice: a rewarded ad (free), coins, or free for
/// Pro. Resolves true when the run has been resumed (the caller then
/// navigates back to the board), false when the player backed out.
///
/// The caller holds the continue window open before showing this, so the
/// player has time to choose.
Future<bool> showGameOverContinueSheet(BuildContext context, {required GameTheme theme}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showLBSheet<bool>(
    context: context,
    title: l10n.lbGoContinue,
    builder: (sheetContext) => const _ContinueChoices(),
  );
  return result ?? false;
}

class _ContinueChoices extends StatefulWidget {
  const _ContinueChoices();

  @override
  State<_ContinueChoices> createState() => _ContinueChoicesState();
}

class _ContinueChoicesState extends State<_ContinueChoices> {
  bool _loadingAd = false;
  bool _adUnavailable = false;

  Future<void> _watchAd() async {
    if (_loadingAd) return;
    final cubit = context.read<GameCubit>();
    final navigator = Navigator.of(context);
    setState(() {
      _loadingAd = true;
      _adUnavailable = false;
    });
    var resumed = false;
    // Never gated on a loaded ad: showRewardedOrWait loads on demand and
    // reports back whether anything could be shown.
    final outcome = await getIt<AdService>().showRewardedOrWait(
      placement: 'game_over_continue',
      onReward: () => resumed = cubit.continueAfterGameOver(),
    );
    if (!mounted) return;
    if (resumed) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _loadingAd = false;
      _adUnavailable = outcome == RewardedOutcome.unavailable;
    });
  }

  Future<void> _payCoins(int cost) async {
    final cubit = context.read<GameCubit>();
    final navigator = Navigator.of(context);
    final ok = await context.read<CoinsCubit>().spendCoins(
          cost,
          CoinSpendingCategory.extraLives,
          itemName: 'Continue',
        );
    if (!mounted) return;
    navigator.pop(ok && cubit.continueAfterGameOver());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cubit = context.read<GameCubit>();
    final gs = cubit.state.gameState;
    final cost = cubit.currentReviveCoinCost;
    final balance = context.watch<CoinsCubit>().state.balance.total;
    final isPro = context.read<PremiumCubit>().state.hasPremium;

    return TapArmGuard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (gs != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.lbReviveLine('${gs.snake.length}', context.formatInt(gs.score)),
                style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
              ),
            ),
          if (isPro)
            _Choice(
              kind: LBBlockKind.fill,
              icon: LBIcon.heart,
              label: l10n.lbRevivePro,
              onTap: () => Navigator.of(context).pop(cubit.continueAfterGameOver()),
            )
          else ...[
            _Choice(
              kind: LBBlockKind.fill,
              icon: _loadingAd ? LBIcon.hourglass : LBIcon.tv,
              label: _loadingAd ? l10n.rvoLoadingAd : l10n.lbReviveWatch,
              onTap: _loadingAd ? null : _watchAd,
            ),
            if (_adUnavailable)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  l10n.lbNoAdNow,
                  textAlign: TextAlign.center,
                  style: LBText.body(p, color: p.inkMuted, size: 11.5),
                ),
              ),
            Opacity(
              opacity: balance >= cost ? 1 : .45,
              child: _Choice(
                kind: LBBlockKind.gold,
                icon: LBIcon.coin,
                label: l10n.lbRevivePay(context.formatInt(cost)),
                aside: l10n.lbReviveYouHave(context.formatInt(balance)),
                onTap: balance >= cost ? () => _payCoins(cost) : null,
              ),
            ),
          ],
          const SizedBox(height: 6),
          LBBlock(
            kind: LBBlockKind.muted,
            height: 46,
            alignment: Alignment.center,
            onTap: () => Navigator.of(context).pop(false),
            child: Text(l10n.lbReviveDecline, style: LBText.button(p, color: p.inkMuted, size: 12)),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.kind,
    required this.icon,
    required this.label,
    required this.onTap,
    this.aside,
  });

  final LBBlockKind kind;
  final LBIcon icon;
  final String label;
  final String? aside;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      height: context.lbCell * 3,
      alignment: Alignment.center,
      feedback: false,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 3.4, color: fg),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.button(p, color: fg, size: 14).copyWith(letterSpacing: 2),
            ),
          ),
          if (aside != null) ...[
            const SizedBox(width: 10),
            Text(aside!, style: LBText.body(p, color: fg.withValues(alpha: .7), size: 11)),
          ],
        ],
      ),
    );
  }
}
