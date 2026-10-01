import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Celebratory dialog shown when the player crosses a level threshold.
/// Shows the coin reward that ProgressionService credited for the level.
class LevelUpPopup extends StatelessWidget {
  final GameTheme theme;
  final int level;

  const LevelUpPopup({super.key, required this.theme, required this.level});

  static Future<void> show({
    required BuildContext context,
    required GameTheme theme,
    required int level,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (dialogContext) => LevelUpPopup(theme: theme, level: level),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final coins = ProgressionService.coinRewardForLevel(level);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: LBBlock(
          kind: LBBlockKind.sheet,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: LBPixelIcon(LBIcon.star, cell: 11, color: p.lime)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      duration: 900.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                    ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Semantics(
                  header: true,
                  child: LBCellText(l10n.luLevelUp, cell: 5, glow: true),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.luReached(level),
                textAlign: TextAlign.center,
                style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 13),
              ),
              const SizedBox(height: 14),
              // Coin reward — the amount ProgressionService credited for this
              // level (already in the balance by the time this dialog shows).
              Center(
                child: LBChip(
                  kind: LBChipKind.gold,
                  icon: LBIcon.coin,
                  height: 28,
                  label: l10n.lbCoinsReward(context.formatInt(coins)),
                ),
              ),
              const SizedBox(height: 20),
              LBBlock(
                kind: LBBlockKind.fill,
                height: 52,
                alignment: Alignment.center,
                onTap: () => dialogContextPop(context),
                child: Text(
                  l10n.luNice.toUpperCase(),
                  style: LBText.button(p, color: p.onLime, size: 14).copyWith(letterSpacing: 2.4),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms)
          .scale(begin: const Offset(0.9, 0.9)),
    );
  }

  void dialogContextPop(BuildContext context) => context.pop();
}
