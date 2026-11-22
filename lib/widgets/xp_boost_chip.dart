import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/services/temporary_grants_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// "2× XP · 23 H LEFT" while the daily-bonus Season XP boost runs; nothing
/// otherwise. Shown on the Season screen, where the XP lands.
class XpBoostChip extends StatefulWidget {
  const XpBoostChip({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  State<XpBoostChip> createState() => _XpBoostChipState();
}

class _XpBoostChipState extends State<XpBoostChip> {
  StreamSubscription<TemporaryGrantLedger>? _sub;

  TemporaryGrantsService? get _grants =>
      getIt.isRegistered<TemporaryGrantsService>()
      ? getIt<TemporaryGrantsService>()
      : null;

  @override
  void initState() {
    super.initState();
    _sub = _grants?.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grants = _grants;
    if (grants == null) return const SizedBox.shrink();
    final now = grants.now();
    final boost = grants.ledger.find(
      TemporaryGrantKind.xpBoost,
      TemporaryGrant.xpBoostId,
    );
    if (boost == null || !boost.isActiveAt(now)) {
      return const SizedBox.shrink();
    }
    final minutes = boost.expiresAt.difference(now).inMinutes;
    final hours = ((minutes + 59) ~/ 60).clamp(1, 24);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: widget.padding,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: LBChip(
          kind: LBChipKind.gold,
          icon: LBIcon.gift,
          label: l10n.bpXpBoostActive(hours).toUpperCase(),
        ),
      ),
    );
  }
}
