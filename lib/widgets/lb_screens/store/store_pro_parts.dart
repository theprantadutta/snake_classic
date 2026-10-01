import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_state.dart'
    show PremiumContent;
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_parts.dart';

/// The Pro pitch pieces shared by the store's PRO tab and the premium
/// benefits screen (screen 14), so both say the same thing the same way.

/// What Pro actually grants, in COPY.md's words. The counts come from the
/// catalogue, so adding a skin or theme updates the pitch. Board sizes and
/// the premium power-up bundle are deliberately absent: every board is free,
/// and the bundle's power-ups do nothing in play yet.
List<String> lbProPerks(AppLocalizations l10n) {
  final skins = SnakeSkinType.values.where((s) => s.isPremium).length;
  final trails = TrailEffectType.values.where((t) => t.isPremium).length;
  return [
    l10n.lbProPerkNoAds,
    l10n.lbProPerkRevive,
    l10n.lbProPerkThemes('${PremiumContent.premiumThemes.length}'),
    l10n.lbProPerkCosmetics('$skins', '$trails'),
    l10n.lbProPerkCoins,
  ];
}

/// Restore purchases with the same feedback Settings gives: "restoring",
/// then restored / failed. The purchase stream does the actual granting.
Future<void> lbRestorePurchases(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  try {
    messenger.showSnackBar(
      arcadeSnackBar(context, message: l10n.settingsRestoring),
    );
    await PurchaseService().restorePurchases();
    if (context.mounted) {
      messenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.settingsRestored,
          tone: ArcadeSnackTone.success,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.settingsRestoreFailed,
          tone: ArcadeSnackTone.error,
        ),
      );
    }
  }
}

/// One perk: a lime check cell and the line.
class StorePerkLine extends StatelessWidget {
  const StorePerkLine(this.text, {super.key, this.detail});

  final String text;

  /// Optional second line (premium screen's extra perks).
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: LBPixelIcon(LBIcon.check, cell: 3, color: p.lime),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: LBText.body(p, color: p.ink, size: 12.5)),
                if (detail != null)
                  Text(detail!, style: LBText.body(p, size: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The Pro card: Cell S mark, "PRO" in gold cells, SNAKE CLASSIC PRO, and
/// the perk list.
class StoreProCard extends StatelessWidget {
  const StoreProCard({
    super.key,
    required this.perks,
    this.extra,
    this.expand = false,
  });

  final List<String> perks;

  /// Appended under the perks (premium screen's ALSO INCLUDED rows).
  final Widget? extra;

  /// Set when the card is given a bounded height (inside [Expanded] in a
  /// [StoreFillScroll]): the perks spread over the spare height instead of
  /// leaving it empty under the card.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final s = context.uiScale;
    final perkLines = [for (final perk in perks) StorePerkLine(perk)];
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LBCellSMark(size: 54 * s),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LBCellText(l10n.lbPro, cell: 8 * s, color: LB.gold, glow: true),
                    const SizedBox(height: 8),
                    Text(
                      l10n.lbProName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LBText.label(p).copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (expand)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: perkLines,
              ),
            )
          else
            ...perkLines,
          ?extra,
        ],
      ),
    );
  }
}

/// MONTHLY / YEARLY price block. The selected plan is the lime fill.
class StorePlanBlock extends StatelessWidget {
  const StorePlanBlock({
    super.key,
    required this.label,
    required this.price,
    required this.line,
    required this.selected,
    this.trialLabel,
    this.onTap,
  });

  final String label;

  /// Always the store's price string.
  final String price;
  final String line;
  final bool selected;

  /// Free-trial badge text, when the store offers one on this plan.
  final String? trialLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final kind = selected ? LBBlockKind.fill : LBBlockKind.outline;
    final fg = LBBlock.foregroundOf(kind, p);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: LBBlock(
        kind: kind,
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.label(p, color: fg.withValues(alpha: .75))
                  .copyWith(fontSize: 10.5),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                price,
                maxLines: 1,
                style: LBText.value(p, color: fg, size: 24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              line,
              style: LBText.body(p, color: fg.withValues(alpha: .72), size: 11),
            ),
            if (trialLabel != null) ...[
              const SizedBox(height: 6),
              Text(
                trialLabel!,
                style: LBText.button(p, color: selected ? fg : LB.gold, size: 10.5)
                    .copyWith(letterSpacing: .6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Two plan blocks side by side at equal height.
class StorePlanRow extends StatelessWidget {
  const StorePlanRow({super.key, required this.monthly, required this.yearly});

  final Widget monthly;
  final Widget yearly;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: monthly), Expanded(child: yearly)],
        ),
      );
}

/// The gold GO PRO button. When the selected plan has a free trial the
/// label says so instead (the stores expect "Start free trial" there).
class StoreGoProButton extends StatelessWidget {
  const StoreGoProButton({
    super.key,
    required this.onTap,
    this.trialLabel,
    this.busyLabel,
  });

  final VoidCallback? onTap;
  final String? trialLabel;

  /// Non-null = a purchase is verifying: spinner + this label, disabled.
  final String? busyLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final fg = LBBlock.foregroundOf(LBBlockKind.goldFill, p);
    final s = context.uiScale;
    final Widget child;
    if (busyLabel != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StoreSpinner(color: fg, size: 16),
          const SizedBox(width: 10),
          Text(busyLabel!, style: LBText.button(p, color: fg, size: 14)),
        ],
      );
    } else if (trialLabel != null) {
      child = Text(
        trialLabel!.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 2,
        style: LBText.button(p, color: fg, size: 16),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(LBIcon.crown, cell: 4.4 * s, color: fg),
          const SizedBox(width: 14),
          Flexible(child: LBCellText(l10n.lbGoPro, cell: 6.5 * s, color: fg)),
        ],
      );
    }
    return LBBlock(
      kind: LBBlockKind.goldFill,
      height: context.lbCell * 3.5,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // The store sheet is the feedback.
      feedback: false,
      onTap: busyLabel != null ? null : onTap,
      child: child,
    );
  }
}

/// "You have Pro" status block: crown, title in cells, detail lines, and an
/// optional chip / action.
class StoreProActiveBlock extends StatelessWidget {
  const StoreProActiveBlock({
    super.key,
    required this.title,
    required this.line,
    this.detail,
    this.chip,
    this.action,
  });

  final String title;
  final String line;
  final String? detail;
  final Widget? chip;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.gold,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LBPixelIcon(LBIcon.crown, cell: 5 * context.uiScale, color: LB.gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LBCellText(
                      title,
                      cell: 4.5 * context.uiScale,
                      color: LB.gold,
                      glow: true,
                    ),
                    if (chip != null) ...[const SizedBox(height: 8), chip!],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(line, style: LBText.body(p, color: p.ink, size: 12)),
          if (detail != null) ...[
            const SizedBox(height: 3),
            Text(detail!, style: LBText.body(p, size: 11.5)),
          ],
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

/// Footer: "Prices come from your app store." and RESTORE PURCHASES.
class StoreFooter extends StatelessWidget {
  const StoreFooter({super.key, required this.onRestore});

  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.lbStoreFooter,
          textAlign: TextAlign.center,
          style: LBText.body(p, color: p.inkDim, size: 11),
        ),
        Semantics(
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              LBFeedback.tap();
              onRestore();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                l10n.lbRestorePurchases,
                style: LBText.button(p, color: p.lime, size: 12).copyWith(
                  letterSpacing: 2,
                  decoration: TextDecoration.underline,
                  decorationColor: p.lime,
                  decorationThickness: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
