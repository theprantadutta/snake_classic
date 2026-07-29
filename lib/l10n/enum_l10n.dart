import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/utils/constants.dart';

/// Localized display text for gameplay enums.
///
/// The enums' own getters (`GameMode.name`, `Difficulty.label`,
/// `GameTheme.name`, …) stay English on purpose: they double as stable
/// identifiers in analytics events and logs. UI call sites use these
/// extensions instead, passing the ambient [AppLocalizations].
extension GameModeL10n on GameMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        GameMode.classic => l10n.modeClassic,
        GameMode.zen => l10n.modeZen,
        GameMode.speedChallenge => l10n.modeSpeedChallenge,
        GameMode.multiFood => l10n.modeMultiFood,
        GameMode.survival => l10n.modeSurvival,
        GameMode.timeAttack => l10n.modeTimeAttack,
        GameMode.powerUpMadness => l10n.modePowerUpMadness,
        GameMode.perfectGame => l10n.modePerfectGame,
      };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
        GameMode.classic => l10n.modeClassicDesc,
        GameMode.zen => l10n.modeZenDesc,
        GameMode.speedChallenge => l10n.modeSpeedChallengeDesc,
        GameMode.multiFood => l10n.modeMultiFoodDesc,
        GameMode.survival => l10n.modeSurvivalDesc,
        GameMode.timeAttack => l10n.modeTimeAttackDesc,
        GameMode.powerUpMadness => l10n.modePowerUpMadnessDesc,
        GameMode.perfectGame => l10n.modePerfectGameDesc,
      };
}

extension DifficultyL10n on Difficulty {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        Difficulty.easy => l10n.diffEasy,
        Difficulty.normal => l10n.diffNormal,
        Difficulty.hard => l10n.diffHard,
      };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
        Difficulty.easy => l10n.diffEasyDesc,
        Difficulty.normal => l10n.diffNormalDesc,
        Difficulty.hard => l10n.diffHardDesc,
      };
}

extension GameThemeL10n on GameTheme {
  String localizedName(AppLocalizations l10n) => switch (this) {
        GameTheme.classic => l10n.themeClassic,
        GameTheme.modern => l10n.themeModern,
        GameTheme.neon => l10n.themeNeon,
        GameTheme.retro => l10n.themeRetro,
        GameTheme.space => l10n.themeSpace,
        GameTheme.ocean => l10n.themeOcean,
        GameTheme.cyberpunk => l10n.themeCyberpunk,
        GameTheme.forest => l10n.themeForest,
        GameTheme.desert => l10n.themeDesert,
        GameTheme.crystal => l10n.themeCrystal,
      };
}

extension DPadPositionL10n on DPadPosition {
  String localizedName(AppLocalizations l10n) => switch (this) {
        DPadPosition.bottomLeft => l10n.dpadLeft,
        DPadPosition.bottomCenter => l10n.dpadCenter,
        DPadPosition.bottomRight => l10n.dpadRight,
      };
}

extension MultiplayerGameModeL10n on MultiplayerGameMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        MultiplayerGameMode.classic => l10n.mpModeClassicBattle,
        MultiplayerGameMode.speedRun => l10n.mpModeSpeedRun,
        MultiplayerGameMode.survival => l10n.mpModeSurvivalMode,
        MultiplayerGameMode.powerUpMadness => l10n.mpModePowerUpMadnessName,
      };
}
