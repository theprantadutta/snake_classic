import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/temporary_grants_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Grants the item a daily login bonus day advertises, on top of its coins:
/// day 3 a Speed Boost, day 5 2x Season XP for 24 h, day 7 a premium theme
/// for 24 h. Called by CoinsCubit.collectDailyBonus after the claim landed,
/// so every claim surface (popup, a Home tile) grants exactly once.
class DailyBonusItemGranter {
  DailyBonusItemGranter({
    required this._powerUps,
    required this._premium,
    required this._grants,
    required this._analytics,
  });

  final PowerUpCubit _powerUps;
  final PremiumCubit _premium;
  final TemporaryGrantsService _grants;
  final AnalyticsFacade _analytics;

  /// Grant [reward]'s item, if it has one. Returns what was granted, or null.
  Future<DailyBonusItem?> grant(DailyLoginBonus reward) async {
    final item = reward.item;
    if (item == null) return null;
    try {
      switch (item) {
        case DailyBonusItem.speedBoost:
          await _powerUps.grantDailyBonusSpeedBoost();
        case DailyBonusItem.xpBoost:
          await _grants.grant(
            TemporaryGrant(
              kind: TemporaryGrantKind.xpBoost,
              id: TemporaryGrant.xpBoostId,
              expiresAt: _grants.now().add(TemporaryGrant.duration),
              source: TemporaryGrantSource.dailyBonus,
            ),
          );
          _analytics.trackXpBoost(stage: 'activated');
        case DailyBonusItem.themeDay:
          final theme = await _premium.grantDailyBonusTheme();
          if (theme == null) {
            // Pro, or every premium theme already unlocked: nothing to lend.
            AppLogger.info('Daily bonus theme skipped: nothing left to lend');
            return null;
          }
      }
      _analytics.trackDailyBonusItemGranted(
        item: item.analyticsId,
        day: reward.day,
      );
      AppLogger.info('Daily bonus item granted: ${item.analyticsId}');
      return item;
    } catch (e) {
      AppLogger.error('Daily bonus item grant failed (${item.name})', e);
      return null;
    }
  }
}
