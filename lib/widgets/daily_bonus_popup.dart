import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Data class for daily bonus reward
class DailyBonusReward {
  final int day;
  final int coins;
  final String? bonusItem;
  final bool claimed;

  const DailyBonusReward({
    required this.day,
    required this.coins,
    this.bonusItem,
    this.claimed = false,
  });

  factory DailyBonusReward.fromJson(Map<String, dynamic> json) {
    return DailyBonusReward(
      day: json['day'],
      coins: json['coins'],
      bonusItem: json['bonus_item'],
      claimed: json['claimed'] ?? false,
    );
  }
}

/// Daily bonus status from API
class DailyBonusStatus {
  final bool canClaim;
  final int currentStreak;
  final DateTime? lastClaimDate;
  final DailyBonusReward? todayReward;
  final List<DailyBonusReward> weekRewards;

  const DailyBonusStatus({
    required this.canClaim,
    required this.currentStreak,
    this.lastClaimDate,
    this.todayReward,
    required this.weekRewards,
  });

  factory DailyBonusStatus.fromJson(Map<String, dynamic> json) {
    return DailyBonusStatus(
      canClaim: json['can_claim'] ?? false,
      currentStreak: json['current_streak'] ?? 0,
      lastClaimDate: json['last_claim_date'] != null
          ? DateTime.parse(json['last_claim_date'])
          : null,
      todayReward: json['today_reward'] != null
          ? DailyBonusReward.fromJson(json['today_reward'])
          : null,
      weekRewards:
          (json['week_rewards'] as List?)
              ?.map((r) => DailyBonusReward.fromJson(r))
              .toList() ??
          [],
    );
  }

  /// Create a default/fallback status for offline mode
  factory DailyBonusStatus.offline() {
    return DailyBonusStatus(
      canClaim: false,
      currentStreak: 0,
      weekRewards: _defaultWeekRewards,
    );
  }

  static const List<DailyBonusReward> _defaultWeekRewards = [
    DailyBonusReward(day: 1, coins: 10),
    DailyBonusReward(day: 2, coins: 15),
    DailyBonusReward(day: 3, coins: 20, bonusItem: 'Speed Boost'),
    DailyBonusReward(day: 4, coins: 25),
    DailyBonusReward(day: 5, coins: 30, bonusItem: '2x XP Boost'),
    DailyBonusReward(day: 6, coins: 40),
    DailyBonusReward(day: 7, coins: 50, bonusItem: 'Premium Theme'),
  ];
}

/// A popup dialog for daily login bonus
class DailyBonusPopup extends StatefulWidget {
  final GameTheme theme;
  final DailyBonusStatus status;
  final Future<void> Function() onClaim;
  final VoidCallback onClose;
  final bool isLoading;

  /// Optional "claim + watch ad to double" action. When non-null a secondary
  /// button is shown. The caller (home) only supplies this when ads are
  /// available and the user isn't Pro, so the popup stays ad-agnostic.
  final Future<void> Function()? onClaimDoubled;

  const DailyBonusPopup({
    super.key,
    required this.theme,
    required this.status,
    required this.onClaim,
    required this.onClose,
    this.isLoading = false,
    this.onClaimDoubled,
  });

  /// Show the daily bonus popup as a dialog
  /// [onClaim] is called when the user taps claim - it should handle the reward immediately
  /// and queue any API calls for background sync (offline-first approach)
  static Future<void> show({
    required BuildContext context,
    required GameTheme theme,
    required DailyBonusStatus status,
    required Future<bool> Function() onClaim,
    Future<void> Function()? onClaimDoubled,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
        return DailyBonusPopup(
          theme: theme,
          status: status,
          isLoading: false, // Never show loading - instant feedback
          onClaim: () async {
            // Await the claim BEFORE dismissing the dialog so the
            // Drift write + sync-outbox enqueue lands before
            // showDialog resolves. Previously the popup closed first
            // and the claim ran in the background — a fast remount of
            // home in that window could re-trigger the popup because
            // the Drift gate hadn't been flipped yet.
            await onClaim();
            // canPop as well as mounted. `mounted` says the element is still
            // in the tree; it says nothing about whether this route is still
            // on the navigator stack. The doubled claim below awaits a
            // rewarded ad, and by the time that returns the dialog can already
            // be gone — dismissed by a tap outside, by the back button, or by
            // this very path. GoRouter throws "GoError: There is nothing to
            // pop" for that, which Crashlytics reported as a fatal crash on
            // the way out of collecting a daily bonus.
            if (dialogContext.mounted && dialogContext.canPop()) {
              dialogContext.pop();
            }
          },
          onClaimDoubled: onClaimDoubled == null
              ? null
              : () async {
                  await onClaimDoubled();
                  if (dialogContext.mounted && dialogContext.canPop()) {
                    dialogContext.pop();
                  }
                },
          onClose: () {
            if (dialogContext.mounted && dialogContext.canPop()) {
              dialogContext.pop();
            }
          },
        );
      },
    );
  }


  @override
  State<DailyBonusPopup> createState() => _DailyBonusPopupState();
}

class _DailyBonusPopupState extends State<DailyBonusPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  // Guards against a fast double-tap firing the claim (and crediting the
  // reward) twice before the dialog pops. We deliberately don't flip to a
  // loading spinner here — the popup is meant to feel instant — we just
  // make the button inert while the claim is in flight.
  bool _isClaiming = false;

  Future<void> _handleClaim() async {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);
    try {
      await widget.onClaim();
    } finally {
      // onClaim normally pops the dialog, so this State is usually gone by
      // now — only reset if we're somehow still mounted (claim failed).
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  Future<void> _handleClaimDoubled() async {
    if (_isClaiming || widget.onClaimDoubled == null) return;
    setState(() => _isClaiming = true);
    try {
      await widget.onClaimDoubled!();
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final todayReward = widget.status.todayReward;
    final currentDay = widget.status.currentStreak > 0
        ? widget.status.currentStreak
        : 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: LBBlock(
          kind: LBBlockKind.sheet,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(l10n, p),
              const SizedBox(height: 16),
              _buildWeekProgress(currentDay),
              const SizedBox(height: 14),
              if (todayReward != null) ...[
                _buildTodayReward(todayReward),
                const SizedBox(height: 14),
              ],
              _buildClaimButton(),
              if (!widget.status.canClaim) _buildCloseButton(),
            ],
          ),
        ),
      ).animate().scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 220.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, LBPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: LBCellText(l10n.dbTitle, cell: 4.4, color: LB.gold, glow: true),
              ),
            ),
            const SizedBox(width: 10),
            LBIconBlock(
              icon: LBIcon.x,
              semanticLabel: l10n.commonClose,
              onTap: widget.onClose,
              size: 44,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.status.canClaim ? l10n.dbClaimToday : l10n.dbComeBack,
          style: LBText.body(p, size: 12),
        ),
        if (widget.status.currentStreak > 1) ...[
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LBChip(
              kind: LBChipKind.gold,
              icon: LBIcon.flame,
              label: l10n.lbBonusStreak(widget.status.currentStreak),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekProgress(int currentDay) {
    return Row(
      children: List.generate(7, (index) {
        final day = index + 1;
        final reward = widget.status.weekRewards.length > index
            ? widget.status.weekRewards[index]
            : DailyBonusReward(day: day, coins: 10 + (day * 5));

        return Expanded(
          child: _buildDayCell(
            day: day,
            coins: reward.coins,
            hasBonus: reward.bonusItem != null,
            isClaimed: reward.claimed,
            isToday: day == currentDay,
          ),
        );
      }),
    );
  }

  /// One rung of the 7-day ladder: a block per day. Claimed days carry a
  /// check, today is the gold one, the rest wait in muted outline.
  Widget _buildDayCell({
    required int day,
    required int coins,
    required bool hasBonus,
    required bool isClaimed,
    required bool isToday,
  }) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    final kind = isToday
        ? LBBlockKind.gold
        : isClaimed
            ? LBBlockKind.outline
            : LBBlockKind.muted;
    final fg = isToday ? LB.gold : (isClaimed ? p.lime : p.inkDim);

    Widget cell = LBBlock(
      kind: kind,
      selected: isToday,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LBPixelIcon(
            isClaimed ? LBIcon.check : (hasBonus ? LBIcon.gift : LBIcon.coin),
            cell: 2.8,
            color: fg,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.dbDayChip(day),
              maxLines: 1,
              style: LBText.label(p, color: fg).copyWith(fontSize: 9, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );

    if (isToday && widget.status.canClaim) {
      cell = cell
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.06, 1.06),
            duration: 800.ms,
          );
    }
    return Semantics(
      label: '${l10n.dbDayChip(day)}, ${l10n.lbCoinsReward('$coins')}',
      excludeSemantics: true,
      child: cell,
    );
  }

  Widget _buildTodayReward(DailyBonusReward reward) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    return LBBlock(
      kind: LBBlockKind.gold,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        children: [
          Text(
            l10n.dbTodaysReward.toUpperCase(),
            style: LBText.label(p, color: LB.gold.withValues(alpha: .8)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LBPixelIcon(LBIcon.coin, cell: 5, color: LB.gold),
              const SizedBox(width: 12),
              Flexible(
                child: LBCellText(
                  '+${reward.coins}',
                  cell: 6,
                  color: LB.gold,
                  glow: true,
                  semanticsLabel: l10n.lbCoinsReward('${reward.coins}'),
                ),
              ),
            ],
          ),
          if (reward.bonusItem != null) ...[
            const SizedBox(height: 12),
            LBChip(icon: LBIcon.gift, label: reward.bonusItem!.toUpperCase()),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildClaimButton() {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    if (!widget.status.canClaim) {
      return LBBlock(
        kind: LBBlockKind.muted,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LBPixelIcon(LBIcon.hourglass, cell: 3, color: p.inkDim),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                l10n.dbAlreadyClaimed,
                style: LBText.body(p, color: p.inkMuted, size: 12),
              ),
            ),
          ],
        ),
      );
    }

    final busy = widget.isLoading || _isClaiming;
    final claimButton = LBBlock(
      kind: LBBlockKind.fill,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      onTap: busy ? null : _handleClaim,
      child: widget.isLoading
          ? LBCellsBar(count: 3, value: 1, cell: 10, color: p.onLime)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LBPixelIcon(LBIcon.gift, cell: 3.6, color: p.onLime),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.dbClaim.toUpperCase(),
                    style: LBText.button(p, color: p.onLime, size: 14).copyWith(letterSpacing: 2),
                  ),
                ),
              ],
            ),
    );

    Widget animate(Widget w) =>
        w.animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.95, 0.95));

    // No ad option → just the normal claim button.
    if (widget.onClaimDoubled == null) return animate(claimButton);

    // Ad available → claim button + a "claim and double via ad" option.
    return animate(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          claimButton,
          LBBlock(
            kind: LBBlockKind.gold,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            feedback: false,
            onTap: busy ? null : _handleClaimDoubled,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LBPixelIcon(LBIcon.tv, cell: 3.2, color: LB.gold),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.dbClaim2x,
                    style: LBText.button(p, color: LB.gold, size: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.muted,
      height: 48,
      alignment: Alignment.center,
      onTap: widget.onClose,
      child: Text(
        AppLocalizations.of(context)!.commonClose.toUpperCase(),
        style: LBText.button(p, color: p.inkMuted, size: 12),
      ),
    );
  }
}
