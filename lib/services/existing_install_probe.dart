import 'package:snake_classic/data/daos/game_dao.dart';
import 'package:snake_classic/data/daos/settings_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/models/game_statistics.dart';

/// Has this device actually played before?
///
/// The one question [FirstRunService.migrateExistingInstall] cannot answer
/// for itself, and the answer that decides whether a player upgrading from an
/// older build is handed the new-player experience or left alone.
///
/// **It has to read `modelJson`.** The `statistics` table's typed columns —
/// `totalGamesPlayed`, `highestScore` and the rest — are inert: field names
/// never matched the model's, so `GameDao.updateStatisticsFromJson` gave up
/// on them and round-trips the whole model through the `modelJson` blob
/// instead, leaving the typed columns zeroed by design. Reading them is
/// therefore reading zero for a player with a thousand games behind them,
/// which is precisely the misclassification this probe exists to prevent.
///
/// Local and durable only. Not the network, not "is signed in": a restored
/// cloud profile proves that somebody played, not that THIS device ever
/// rendered a frame, and first-run state describes the device.
///
/// Throws rather than guessing when the stored statistics cannot be read.
/// The caller leaves the migration unstamped on a throw, so an unreadable
/// database means "ask again next launch" instead of a permanent wrong
/// answer baked in during one bad read.
Future<bool> hasLocalGameplayEvidence(AppDatabase db) async {
  final stats = await GameDao(db).getStatistics();

  // Belt and braces: if some older build did populate the typed columns,
  // that is still evidence. It costs nothing — they are zero by default and
  // nothing writes them now, so this can produce no false positives.
  if (stats != null &&
      (stats.totalGamesPlayed > 0 || stats.highestScore > 0)) {
    return true;
  }

  final json = stats?.modelJson.trim();
  if (json != null && json.isNotEmpty && json != '{}') {
    // A parse failure propagates deliberately — see above.
    final model = GameStatistics.fromJsonString(json);
    if (model.totalGamesPlayed > 0 || model.highScore > 0) return true;
  }

  // Older installs whose statistics row never landed can still be identified
  // by the high score in settings, which is written separately and is the
  // longest-lived piece of local gameplay history the app keeps.
  final settings = await SettingsDao(db).getSettings();
  return (settings?.highScore ?? 0) > 0;
}
