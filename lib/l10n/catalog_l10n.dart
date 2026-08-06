import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/models/premium_power_up.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/utils/constants.dart';

/// Localized display text for model-layer catalogs.
///
/// The English getters/fields on the models stay untouched — they are wire
/// values (analytics properties, coin-ledger itemNames, stats-map keys).
/// These extensions are render-time lookups keyed on the stable id/enum.
extension PowerUpTypeL10n on PowerUpType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        PowerUpType.speedBoost => l10n.puSpeedBoost,
        PowerUpType.invincibility => l10n.puInvincibility,
        PowerUpType.scoreMultiplier => l10n.puScoreMultiplier,
        PowerUpType.slowMotion => l10n.puSlowMotion,
      };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
        PowerUpType.speedBoost => l10n.puSpeedBoostDesc,
        PowerUpType.invincibility => l10n.puInvincibilityDesc,
        PowerUpType.scoreMultiplier => l10n.puScoreMultiplierDesc,
        PowerUpType.slowMotion => l10n.puSlowMotionDesc,
      };
}

/// Localizes a raw `PowerUpType.name` English string (as stored in the
/// statistics `powerUpTypeCount` map, e.g. "Speed Boost"). Falls back to
/// the raw value for unknown input.
String localizedPowerUpStatName(String raw, AppLocalizations l10n) =>
    switch (raw) {
      'Speed Boost' => l10n.puSpeedBoost,
      'Invincibility' => l10n.puInvincibility,
      'Score Multiplier' => l10n.puScoreMultiplier,
      'Slow Motion' => l10n.puSlowMotion,
      _ => raw,
    };

extension PremiumPowerUpTypeL10n on PremiumPowerUpType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        PremiumPowerUpType.megaSpeedBoost => l10n.ppuMegaSpeedBoost,
        PremiumPowerUpType.megaInvincibility => l10n.ppuMegaInvincibility,
        PremiumPowerUpType.megaScoreMultiplier => l10n.ppuMegaScoreMultiplier,
        PremiumPowerUpType.megaSlowMotion => l10n.ppuMegaSlowMotion,
        PremiumPowerUpType.teleport => l10n.ppuTeleport,
        PremiumPowerUpType.sizeReducer => l10n.ppuSizeReducer,
        PremiumPowerUpType.scoreShield => l10n.ppuScoreShield,
        PremiumPowerUpType.comboMultiplier => l10n.ppuComboMultiplier,
        PremiumPowerUpType.timeWarp => l10n.ppuTimeWarp,
        PremiumPowerUpType.magneticFood => l10n.ppuMagneticFood,
        PremiumPowerUpType.ghostMode => l10n.ppuGhostMode,
        PremiumPowerUpType.doubleTrouble => l10n.ppuDoubleTrouble,
        PremiumPowerUpType.luckyCharm => l10n.ppuLuckyCharm,
        PremiumPowerUpType.powerSurge => l10n.ppuPowerSurge,
      };
}

extension PowerUpBundleL10n on PowerUpBundle {
  String localizedName(AppLocalizations l10n) => switch (id) {
        'mega_pack' => l10n.bundleMegaPack,
        'tactical_pack' => l10n.bundleTacticalPack,
        'ultimate_pack' => l10n.bundleUltimatePack,
        _ => name,
      };

  String localizedDescription(AppLocalizations l10n) => switch (id) {
        'mega_pack' => l10n.bundleMegaPackDesc,
        'tactical_pack' => l10n.bundleTacticalPackDesc,
        'ultimate_pack' => l10n.bundleUltimatePackDesc,
        _ => description,
      };
}

extension SnakeSkinTypeL10n on SnakeSkinType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        SnakeSkinType.classic => l10n.skinClassic,
        SnakeSkinType.golden => l10n.skinGolden,
        SnakeSkinType.rainbow => l10n.skinRainbow,
        SnakeSkinType.galaxy => l10n.skinGalaxy,
        SnakeSkinType.dragon => l10n.skinDragon,
        SnakeSkinType.electric => l10n.skinElectric,
        SnakeSkinType.fire => l10n.skinFire,
        SnakeSkinType.ice => l10n.skinIce,
        SnakeSkinType.shadow => l10n.skinShadow,
        SnakeSkinType.neon => l10n.skinNeon,
        SnakeSkinType.crystal => l10n.skinCrystal,
        SnakeSkinType.cosmic => l10n.skinCosmic,
      };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
        SnakeSkinType.classic => l10n.skinClassicDesc,
        SnakeSkinType.golden => l10n.skinGoldenDesc,
        SnakeSkinType.rainbow => l10n.skinRainbowDesc,
        SnakeSkinType.galaxy => l10n.skinGalaxyDesc,
        SnakeSkinType.dragon => l10n.skinDragonDesc,
        SnakeSkinType.electric => l10n.skinElectricDesc,
        SnakeSkinType.fire => l10n.skinFireDesc,
        SnakeSkinType.ice => l10n.skinIceDesc,
        SnakeSkinType.shadow => l10n.skinShadowDesc,
        SnakeSkinType.neon => l10n.skinNeonDesc,
        SnakeSkinType.crystal => l10n.skinCrystalDesc,
        SnakeSkinType.cosmic => l10n.skinCosmicDesc,
      };
}

extension TrailEffectTypeL10n on TrailEffectType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        TrailEffectType.none => l10n.trailNone,
        TrailEffectType.particle => l10n.trailParticle,
        TrailEffectType.glow => l10n.trailGlow,
        TrailEffectType.rainbow => l10n.trailRainbow,
        TrailEffectType.fire => l10n.trailFire,
        TrailEffectType.electric => l10n.trailElectric,
        TrailEffectType.star => l10n.trailStar,
        TrailEffectType.cosmic => l10n.trailCosmic,
        TrailEffectType.neon => l10n.trailNeon,
        TrailEffectType.shadow => l10n.trailShadow,
        TrailEffectType.crystal => l10n.trailCrystal,
        TrailEffectType.dragon => l10n.trailDragon,
      };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
        TrailEffectType.none => l10n.trailNoneDesc,
        TrailEffectType.particle => l10n.trailParticleDesc,
        TrailEffectType.glow => l10n.trailGlowDesc,
        TrailEffectType.rainbow => l10n.trailRainbowDesc,
        TrailEffectType.fire => l10n.trailFireDesc,
        TrailEffectType.electric => l10n.trailElectricDesc,
        TrailEffectType.star => l10n.trailStarDesc,
        TrailEffectType.cosmic => l10n.trailCosmicDesc,
        TrailEffectType.neon => l10n.trailNeonDesc,
        TrailEffectType.shadow => l10n.trailShadowDesc,
        TrailEffectType.crystal => l10n.trailCrystalDesc,
        TrailEffectType.dragon => l10n.trailDragonDesc,
      };
}

extension CoinPurchaseOptionL10n on CoinPurchaseOption {
  String localizedName(AppLocalizations l10n) => switch (id) {
        'coin_pack_small' => l10n.coinPackSmall,
        'coin_pack_medium' => l10n.coinPackMedium,
        'coin_pack_large' => l10n.coinPackLarge,
        'coin_pack_mega' => l10n.coinPackMega,
        _ => name,
      };

  String localizedDisplayCoins(AppLocalizations l10n) => bonusCoins > 0
      ? l10n.coinsAmountBonus(coins, bonusCoins)
      : l10n.coinsAmount(coins);
}

extension BoardSizeL10n on BoardSize {
  String localizedName(AppLocalizations l10n) => switch (name) {
        'Small' => l10n.boardSmall,
        'Classic' => l10n.boardClassic,
        'Large' => l10n.boardLarge,
        'Huge' => l10n.boardHuge,
        'Epic' => l10n.boardEpic,
        'Massive' => l10n.boardMassive,
        'Ultimate' => l10n.boardUltimate,
        'Tall' => l10n.boardTall,
        'Tall Plus' => l10n.boardTallPlus,
        _ => name,
      };

  String localizedDescription(AppLocalizations l10n) => switch (name) {
        'Small' => l10n.boardSmallDesc,
        'Classic' => l10n.boardClassicDesc,
        'Large' => l10n.boardLargeDesc,
        'Huge' => l10n.boardHugeDesc,
        'Epic' => l10n.boardEpicDesc,
        'Massive' => l10n.boardMassiveDesc,
        'Ultimate' => l10n.boardUltimateDesc,
        'Tall' => l10n.boardTallDesc,
        'Tall Plus' => l10n.boardTallPlusDesc,
        _ => description,
      };
}

extension TournamentGameModeL10n on TournamentGameMode {
  String localizedName(AppLocalizations l10n) => switch (this) {
        TournamentGameMode.classic => l10n.tgmClassic,
        TournamentGameMode.speedRun => l10n.tgmSpeedRun,
        TournamentGameMode.survival => l10n.tgmSurvival,
        TournamentGameMode.noWalls => l10n.tgmNoWalls,
        TournamentGameMode.powerUpMadness => l10n.tgmPowerUpMadness,
        TournamentGameMode.perfectGame => l10n.tgmPerfectGame,
      };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
        TournamentGameMode.classic => l10n.tgmClassicDesc,
        TournamentGameMode.speedRun => l10n.tgmSpeedRunDesc,
        TournamentGameMode.survival => l10n.tgmSurvivalDesc,
        TournamentGameMode.noWalls => l10n.tgmNoWallsDesc,
        TournamentGameMode.powerUpMadness => l10n.tgmPowerUpMadnessDesc,
        TournamentGameMode.perfectGame => l10n.tgmPerfectGameDesc,
      };
}

extension TournamentTypeL10n on TournamentType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        TournamentType.daily => l10n.ttDaily,
        TournamentType.weekly => l10n.ttWeekly,
        TournamentType.special => l10n.ttSpecial,
      };
}

extension TournamentStatusL10n on TournamentStatus {
  String localizedName(AppLocalizations l10n) => switch (this) {
        TournamentStatus.upcoming => l10n.tsUpcoming,
        TournamentStatus.active => l10n.tsActive,
        TournamentStatus.ended => l10n.tsEnded,
      };
}

extension ChallengeDifficultyL10n on ChallengeDifficulty {
  String localizedName(AppLocalizations l10n) => switch (this) {
        ChallengeDifficulty.easy => l10n.cdEasy,
        ChallengeDifficulty.medium => l10n.cdMedium,
        ChallengeDifficulty.hard => l10n.cdHard,
      };
}

extension UserStatusL10n on UserStatus {
  String localizedName(AppLocalizations l10n) => switch (this) {
        UserStatus.online => l10n.usOnline,
        UserStatus.offline => l10n.usOffline,
        UserStatus.playing => l10n.usPlaying,
      };
}

extension BattlePassRewardTypeL10n on BattlePassRewardType {
  String localizedName(AppLocalizations l10n) => switch (this) {
        BattlePassRewardType.xp => l10n.bprXpBoost,
        BattlePassRewardType.coins => l10n.bprCoins,
        BattlePassRewardType.theme => l10n.bprTheme,
        BattlePassRewardType.skin => l10n.bprSkin,
        BattlePassRewardType.trail => l10n.bprTrail,
        BattlePassRewardType.powerUp => l10n.bprPowerUp,
        BattlePassRewardType.tournamentEntry => l10n.bprTournamentEntry,
        BattlePassRewardType.title => l10n.bprTitle,
        BattlePassRewardType.avatar => l10n.bprAvatar,
        BattlePassRewardType.special => l10n.bprSpecial,
      };
}

final RegExp _qtyCoinsPattern = RegExp(r'^(\d+) Coins$');
final RegExp _typeQtyPattern = RegExp(r'^(.+) x(\d+)$');

/// Localizes a generated battle-pass reward name (the English `reward.name`
/// strings from the client-side season generator). Falls back to the raw
/// name for anything unrecognized. The English name stays the persisted
/// coin-ledger itemName — this is render-time only.
String localizedBattlePassRewardName(String name, AppLocalizations l10n) {
  switch (name) {
    case 'XP Boost':
      return l10n.bprXpBoost;
    case 'Coins':
      return l10n.bprCoins;
    case 'Theme':
      return l10n.bprTheme;
    case 'Snake Skin':
      return l10n.bprSkin;
    case 'Trail Effect':
      return l10n.bprTrail;
    case 'Power-Up':
      return l10n.bprPowerUp;
    case 'Tournament Entry':
      return l10n.bprTournamentEntry;
    case 'Player Title':
      return l10n.bprTitle;
    case 'Avatar':
      return l10n.bprAvatar;
    case 'Special Reward':
      return l10n.bprSpecial;
    case 'Star Dust':
      return l10n.bprnStarDust;
    case 'Energy Pack':
      return l10n.bprnEnergyPack;
    case 'Bronze Entry':
      return l10n.bprnBronzeEntry;
    case 'Silver Entry':
      return l10n.bprnSilverEntry;
    case 'Stargazer':
      return l10n.bprnStargazer;
    case 'Voyager':
      return l10n.bprnVoyager;
    case 'Nebula Theme':
      return l10n.bprnNebulaTheme;
    case 'Stardust Trail':
      return l10n.bprnStardustTrail;
    case 'Legendary Crate':
      return l10n.bprnLegendaryCrate;
    case 'Mega XP':
      return l10n.bprnMegaXp;
    case 'Cosmic Charge':
      return l10n.bprnCosmicCharge;
    case 'Nova Burst':
      return l10n.bprnNovaBurst;
    case 'Galaxy Skin':
      return l10n.bprnGalaxySkin;
    case 'Crystal Serpent':
      return l10n.bprnCrystalSerpent;
    case 'Neon Trail':
      return l10n.trailNeon;
    case 'Plasma Wake':
      return l10n.bprnPlasmaWake;
    case 'Cosmic Aura':
      return l10n.bprnCosmicAura;
    case 'Cyberpunk Theme':
      return l10n.bprnCyberpunkTheme;
    case 'Crystal Theme':
      return l10n.bprnCrystalTheme;
    case 'Speed Boost':
      return l10n.puSpeedBoost;
    case 'Score Shield':
      return l10n.ppuScoreShield;
    case 'Ghost Mode':
      return l10n.ppuGhostMode;
    case 'Season Trophy':
      return l10n.bprnSeasonTrophy;
    case 'Cosmic Crown':
      return l10n.bprnCosmicCrown;
    case 'Cosmic Legend':
      return l10n.bprnCosmicLegend;
    case 'Star Commander':
      return l10n.bprnStarCommander;
  }
  final coinsMatch = _qtyCoinsPattern.firstMatch(name);
  if (coinsMatch != null) {
    return l10n.bpRewardQtyCoins(coinsMatch.group(1)!);
  }
  final typeQtyMatch = _typeQtyPattern.firstMatch(name);
  if (typeQtyMatch != null) {
    final localizedPrefix =
        localizedBattlePassRewardName(typeQtyMatch.group(1)!, l10n);
    return l10n.bpRewardTypeQty(localizedPrefix, typeQtyMatch.group(2)!);
  }
  return name;
}

/// Localized battle-pass season name, keyed on the English name.
///
/// Seasons come from two places: the bundled launch season in
/// [BattlePassSeason] and, once the backend starts serving them,
/// `BattlePassSeason.fromJson`. Same contract as the reward names above —
/// translate what we ship, pass anything unrecognized through verbatim so a
/// server-added season degrades to English instead of a blank title.
String localizedBattlePassSeasonName(String name, AppLocalizations l10n) =>
    switch (name) {
      'Cosmic Serpent Season' => l10n.bpSeasonCosmicSerpent,
      _ => name,
    };
