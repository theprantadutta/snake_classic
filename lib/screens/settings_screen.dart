import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/l10n/supported_locales.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/display/display_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/legal_document_screen.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/review_service.dart';
import 'package:snake_classic/services/username_service.dart';
import 'package:snake_classic/services/walkthrough_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/account_upgrade_sheet.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/credits_dialog.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_display_panel.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_rows.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_theme_strip.dart';
import 'package:snake_classic/widgets/pause_overlay.dart' show LBControlChoice;

/// Settings (Living Board screen 16).
///
/// The top of the page is the mock: CONTROLS (four layout blocks), GAMEPLAY
/// (mode / board / difficulty open Run setup; crash replay picks in a
/// sheet), THEME (a swatch per theme in its own palette) and SOUND & FEEL.
/// Everything else Settings has always offered follows in the same style —
/// visual, display, language, notifications, account, your game, help,
/// legal and premium — and the footer carries the tutorial, privacy and the
/// version.
///
/// Every value is read straight off its cubit (GameSettingsCubit,
/// DisplayCubit, ThemeCubit, PremiumCubit, AuthCubit). The screen used to
/// keep local mirrors of the settings fields and a listener to keep them in
/// step; the cubits emit synchronously, so reading them is the same value
/// without the drift hazard.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AnalyticsFacade _analytics;

  // Notification preferences. Mirrored from NotificationService at init
  // and on every toggle; service is the source of truth (persists through
  // Drift + sync outbox, and triggers FCM topic (un)subscribe).
  final NotificationService _notificationService = NotificationService();
  bool _notifDailyReminder = true;
  bool _notifTournament = true;
  bool _notifAchievement = true;
  bool _notifSocial = true;
  bool _notifSpecialEvent = true;

  /// For the footer. Null until the platform answers.
  String? _version;

  @override
  void initState() {
    super.initState();
    _analytics = getIt<AnalyticsFacade>();
    _loadNotificationPreferences();
    _loadVersion();
    // Pull fresh user data so the account row shows the live username
    // (handles the case where the local UnifiedUser was cached
    // pre-backfill / pre-rename and is missing the value).
    // Fire-and-forget — the screen renders from current state and updates
    // if anything changed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().refreshUserFromBackend();
      // Re-read the live refresh rate when the screen opens, so the number
      // in DISPLAY is current rather than whatever we last saw at launch
      // (battery saver may have kicked in since).
      context.read<DisplayCubit>().refreshInfo();
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      // No version in the footer is better than a broken footer.
    }
  }

  void _loadNotificationPreferences() {
    final prefs = _notificationService.notificationPreferences;
    _notifDailyReminder = prefs[NotificationType.dailyReminder] ?? true;
    _notifTournament = prefs[NotificationType.tournament] ?? true;
    _notifAchievement = prefs[NotificationType.achievement] ?? true;
    _notifSocial = prefs[NotificationType.social] ?? true;
    _notifSpecialEvent = prefs[NotificationType.specialEvent] ?? true;
  }

  Future<void> _toggleNotification(
    NotificationType type,
    bool value,
    void Function(bool) localSetter,
  ) async {
    setState(() => localSetter(value));
    await _notificationService.setNotificationEnabled(type, value);
    _analytics.trackSettingChanged(
      settingName: 'notification_${type.key}',
      value: '$value',
    );
  }

  void _track(String name, Object value) =>
      _analytics.trackSettingChanged(settingName: name, value: '$value');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<GameSettingsCubit>().state;
    final themeState = context.watch<ThemeCubit>().state;
    final premium = context.watch<PremiumCubit>().state;
    final auth = context.watch<AuthCubit>().state;
    final display = context.watch<DisplayCubit>().state;
    final isPlaying = context.select<GameCubit, bool>((c) => c.state.isPlaying);

    return LBScaffold(
      title: l10n.lbSettingsTitle,
      subtitle: l10n.lbSettingsSubtitle,
      children: [
        _controls(l10n, settings),
        _gameplay(l10n, settings, isPlaying),
        _theme(l10n, themeState, premium),
        _soundAndFeel(l10n, settings, display),
        _visual(l10n, settings, themeState),
        SettingsSection(
          label: l10n.settingsSectionDisplay,
          children: [SettingsDisplayPanel(display: display)],
        ),
        _language(l10n, settings),
        _notifications(l10n),
        // Diagnostic buttons that isolate each layer of the notification
        // pipeline. Gated behind kDebugMode so production builds never see
        // it — developer-facing controls for triage, not user features. See
        // NOTIFICATIONS_TESTING.md for the triage guide.
        if (kDebugMode)
          SettingsSection(
            label: 'TEST NOTIFICATIONS',
            children: [_buildNotificationTestPanel()],
          ),
        _account(l10n, auth),
        _yourGame(l10n),
        _help(l10n, themeState.currentTheme),
        _legal(l10n),
        if (premium.isInitialized) _premium(l10n, premium),
        SettingsFooterLinks(
          links: [
            (l10n.lbReplayTutorial, _showReplayTutorialSheet),
            (l10n.lbPrivacy, _openPrivacyPolicy),
          ],
          version: _version == null ? null : l10n.lbVersionShort(_version!),
        ),
      ],
    );
  }

  // ==================== CONTROLS ====================

  /// SWIPE turns the on-screen control off; D-PAD / TURN / STICK turn it on
  /// with that layout. Same cubit calls and analytics events as the old
  /// switch + layout picker.
  Future<void> _chooseControl({required bool dPad, ControlLayout? layout}) async {
    final cubit = context.read<GameSettingsCubit>();
    final before = cubit.state;
    if (before.dPadEnabled != dPad) {
      await cubit.setDPadEnabled(dPad);
      _track('dpad_enabled', dPad);
    }
    if (layout != null && before.controlLayout != layout) {
      await cubit.setControlLayout(layout);
      _track('control_layout', layout.name);
    }
  }

  Widget _controls(AppLocalizations l10n, GameSettingsState s) {
    bool on(ControlLayout layout) => s.dPadEnabled && s.controlLayout == layout;
    return SettingsSection(
      label: l10n.lbControls,
      // First section: the header subtitle already spaces it.
      topGap: 0,
      children: [
        Row(
          children: [
            Expanded(
              child: LBControlChoice(
                title: l10n.lbCtrlSwipe,
                subtitle: l10n.lbCtrlSwipeSub,
                selected: !s.dPadEnabled,
                onTap: () => _chooseControl(dPad: false),
              ),
            ),
            Expanded(
              child: LBControlChoice(
                title: l10n.lbCtrlDpad,
                subtitle: l10n.lbCtrlDpadSub,
                selected: on(ControlLayout.dPad),
                onTap: () => _chooseControl(dPad: true, layout: ControlLayout.dPad),
              ),
            ),
            Expanded(
              child: LBControlChoice(
                title: l10n.lbCtrlTurn,
                subtitle: l10n.lbCtrlTurnSub,
                selected: on(ControlLayout.turnButtons),
                onTap: () => _chooseControl(dPad: true, layout: ControlLayout.turnButtons),
              ),
            ),
            Expanded(
              child: LBControlChoice(
                title: l10n.lbCtrlStick,
                subtitle: l10n.lbCtrlStickSub,
                selected: on(ControlLayout.joystick),
                onTap: () => _chooseControl(dPad: true, layout: ControlLayout.joystick),
              ),
            ),
          ],
        ),
        // The position selector only applies to the four-way pad; the turn
        // buttons occupy both corners by design and the stick floats.
        if (on(ControlLayout.dPad)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
            child: LBSectionLabel(l10n.settingsDPadPosition),
          ),
          SettingsOptionStrip<DPadPosition>(
            options: DPadPosition.values,
            selected: s.dPadPosition,
            labelOf: (pos) => pos.localizedName(l10n),
            onSelect: (pos) => context.read<GameSettingsCubit>().updateDPadPosition(pos),
          ),
          const SizedBox(height: 4),
        ],
        // Cell-by-cell movement. Device-local, read straight off the cubit.
        SettingsToggleRow(
          title: l10n.settingsSnapMovement,
          subtitle: l10n.settingsSnapMovementSubtitle,
          value: s.snapMovementEnabled,
          onChanged: (value) async {
            await context.read<GameSettingsCubit>().setSnapMovementEnabled(value);
            _track('snap_movement_enabled', value);
          },
        ),
      ],
    );
  }

  // ==================== GAMEPLAY ====================

  /// Render-time localization for the crash-feedback labels. The raw
  /// GameConstants label stays English ('Skip'/'Until Tap' are also used as
  /// wire/persisted values elsewhere); numeric labels like '2s' pass through.
  String _crashLabel(AppLocalizations l10n, Duration duration) {
    final raw = GameConstants.getCrashFeedbackLabel(duration);
    return switch (raw) {
      'Skip' => l10n.crashLabelSkip,
      'Until Tap' => l10n.crashLabelUntilTap,
      _ => raw,
    };
  }

  Widget _gameplay(AppLocalizations l10n, GameSettingsState s, bool isPlaying) {
    // Mode, board and difficulty are picked on Run setup now. While a run
    // is live they stay locked, exactly as the old in-place pickers were.
    void openSetup() => context.push(AppRoutes.runSetup);
    return SettingsSection(
      label: l10n.lbGameplay,
      children: [
        SettingsValueRow(
          title: l10n.lbMode,
          subtitle: isPlaying ? l10n.settingsGameModeLocked : null,
          value: s.gameMode.localizedName(l10n),
          onTap: isPlaying ? null : openSetup,
        ),
        SettingsValueRow(
          title: l10n.lbBoard,
          subtitle: isPlaying ? l10n.settingsBoardSizeLocked : null,
          value: s.boardSize.id.replaceAll('x', '×'),
          onTap: isPlaying ? null : openSetup,
        ),
        SettingsValueRow(
          title: l10n.lbDifficulty,
          // Being explicit up front is kinder than letting an Easy player
          // grind a personal best and only then discover it never counted.
          subtitle: isPlaying
              ? l10n.settingsDifficultyLocked
              : (s.difficulty.postsToLeaderboard ? null : l10n.settingsEasyNote),
          value: s.difficulty.localizedLabel(l10n),
          onTap: isPlaying ? null : openSetup,
        ),
        SettingsValueRow(
          title: l10n.lbCrashReplay,
          subtitle: l10n.lbCrashReplaySub,
          value: _crashLabel(l10n, s.crashFeedbackDuration),
          onTap: _showCrashReplaySheet,
        ),
      ],
    );
  }

  void _showCrashReplaySheet() {
    final l10n = AppLocalizations.of(context)!;
    showLBSheet<void>(
      context: context,
      title: l10n.lbCrashReplay,
      subtitle: l10n.settingsCrashFeedbackSubtitle,
      builder: (sheetContext) => BlocBuilder<GameSettingsCubit, GameSettingsState>(
        buildWhen: (a, b) => a.crashFeedbackDuration != b.crashFeedbackDuration,
        builder: (context, s) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final duration in GameConstants.availableCrashFeedbackDurations)
                SettingsSheetOption(
                  title: _crashLabel(l10n, duration),
                  selected: s.crashFeedbackDuration == duration,
                  onTap: () async {
                    await context.read<GameSettingsCubit>().updateCrashFeedbackDuration(duration);
                    _track('crash_feedback_duration', duration.inSeconds);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== THEME ====================

  Widget _theme(AppLocalizations l10n, ThemeState themeState, PremiumState premium) {
    final premiumCount = PremiumContent.premiumThemes.length;
    final freeCount = GameTheme.values.length - premiumCount;
    return SettingsSection(
      label: l10n.lbTheme,
      aside: l10n.lbThemeAside(
        themeState.currentTheme.localizedName(l10n).toUpperCase(),
        context.formatInt(freeCount),
        context.formatInt(premiumCount),
      ),
      children: [
        SettingsThemeStrip(
          current: themeState.currentTheme,
          isUnlocked: premium.isThemeUnlocked,
          onTap: (t) {
            if (premium.isThemeUnlocked(t)) {
              // Same call the store's theme rows make for an owned theme.
              context.read<ThemeCubit>().setTheme(t);
            } else {
              // Locked: the Themes tab of the unified store (tab index 2:
              // Pro / Coins / Themes / Skins / Trails / Power-Ups), where
              // the unlock and purchase live.
              context.push('${AppRoutes.store}?tab=2');
            }
          },
        ),
      ],
    );
  }

  // ==================== SOUND & FEEL ====================

  Widget _soundAndFeel(AppLocalizations l10n, GameSettingsState s, DisplayState display) {
    final cubit = context.read<GameSettingsCubit>();
    return SettingsSection(
      label: l10n.lbSoundFeel,
      children: [
        // Read straight off the cubit — no local mirror. The pause overlay
        // offers the same toggles, and one value with two copies drifts.
        SettingsToggleRow(
          title: l10n.lbSoundFx,
          subtitle: l10n.lbSoundFxSub,
          value: s.soundEnabled,
          onChanged: (value) async {
            await cubit.setSoundEnabled(value);
            _track('sound_effects', value);
          },
        ),
        SettingsToggleRow(
          title: l10n.lbMusic,
          value: s.musicEnabled,
          onChanged: (value) async {
            await cubit.setMusicEnabled(value);
            _track('background_music', value);
          },
        ),
        SettingsToggleRow(
          title: l10n.lbHaptics,
          subtitle: l10n.lbHapticsSub,
          value: s.hapticsEnabled,
          onChanged: (value) async {
            await cubit.setHapticsEnabled(value);
            _track('haptics_enabled', value);
          },
        ),
        // DisplayCubit owns the device-local high-refresh-rate opt-in; it
        // never syncs. Disabled (not hidden) on a single-rate panel.
        SettingsToggleRow(
          title: l10n.lb120Hz,
          subtitle: l10n.lb120HzSub,
          value: display.highRefreshRateEnabled,
          onChanged: display.deviceSupportsHighRate
              ? (value) async {
                  await context.read<DisplayCubit>().setHighRefreshRateEnabled(value);
                  _track('high_refresh_rate_enabled', value);
                }
              : null,
        ),
        // The platform overrides us in both of these cases whatever the
        // toggle says. Saying so beats looking broken.
        if (display.throttledByBattery) SettingsNote(text: l10n.settingsDisplayBatteryNote, icon: LBIcon.bolt),
        if (display.throttledByHeat) SettingsNote(text: l10n.settingsDisplayThermalNote, icon: LBIcon.flame),
        // Only once we have actually read the panel — before that we would be
        // telling a 120 Hz phone it is single-rate.
        if (display.loaded && display.info != null && !display.deviceSupportsHighRate)
          SettingsNote(text: l10n.settingsDisplaySingleRateNote),
      ],
    );
  }

  // ==================== VISUAL ====================

  Widget _visual(AppLocalizations l10n, GameSettingsState s, ThemeState themeState) {
    return SettingsSection(
      label: l10n.settingsSectionVisual,
      children: [
        SettingsToggleRow(
          title: l10n.settingsScreenShake,
          subtitle: l10n.settingsScreenShakeSubtitle,
          value: s.screenShakeEnabled,
          onChanged: (value) async {
            await context.read<GameSettingsCubit>().setScreenShakeEnabled(value);
            _track('screen_shake', value);
          },
        ),
        SettingsToggleRow(
          title: l10n.settingsSnakeTrail,
          subtitle: l10n.settingsSnakeTrailSubtitle,
          value: themeState.isTrailSystemEnabled,
          onChanged: (value) => context.read<ThemeCubit>().setTrailSystemEnabled(value),
        ),
        SettingsValueRow(
          title: l10n.settingsBrowseThemes,
          leading: const LBPixelIcon(LBIcon.grid, cell: 3.4),
          onTap: () => context.push('${AppRoutes.store}?tab=2'),
        ),
      ],
    );
  }

  // ==================== LANGUAGE ====================

  /// App-language picker: system default + one option per supported locale.
  /// Selection applies instantly (MaterialApp rebuilds off the settings
  /// cubit) — no restart needed.
  Widget _language(AppLocalizations l10n, GameSettingsState s) {
    final code = s.localeCode;
    final current = code == null
        ? l10n.languageSystemDefault
        : (SupportedLocales.endonyms[code] ?? code);
    return SettingsSection(
      label: l10n.settingsSectionLanguage,
      children: [
        SettingsValueRow(
          title: l10n.lbLanguageRow,
          value: current,
          onTap: _showLanguageSheet,
        ),
      ],
    );
  }

  void _showLanguageSheet() {
    final l10n = AppLocalizations.of(context)!;
    showLBSheet<void>(
      context: context,
      title: l10n.settingsSectionLanguage,
      builder: (sheetContext) => BlocBuilder<GameSettingsCubit, GameSettingsState>(
        buildWhen: (prev, curr) => prev.localeCode != curr.localeCode,
        builder: (context, settingsState) {
          // Re-read: the sheet itself switches language when you pick one.
          final l = AppLocalizations.of(context)!;
          final current = settingsState.localeCode;
          void pick(String? code) {
            context.read<GameSettingsCubit>().setLocaleCode(code);
            _analytics.trackSettingChanged(
              settingName: 'app_language',
              value: code ?? 'system',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsSheetOption(
                  title: l.languageSystemDefault,
                  subtitle: l.languageSystemDefaultSubtitle,
                  selected: current == null,
                  onTap: () => pick(null),
                ),
                for (final locale in SupportedLocales.locales)
                  SettingsSheetOption(
                    title: SupportedLocales.endonyms[locale.languageCode] ?? locale.languageCode,
                    selected: current == locale.languageCode,
                    onTap: () => pick(locale.languageCode),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== NOTIFICATIONS ====================

  Widget _notifications(AppLocalizations l10n) {
    return SettingsSection(
      label: l10n.settingsSectionNotifications,
      children: [
        SettingsToggleRow(
          title: l10n.settingsNotifDailyReminder,
          value: _notifDailyReminder,
          onChanged: (v) => _toggleNotification(
            NotificationType.dailyReminder,
            v,
            (val) => _notifDailyReminder = val,
          ),
        ),
        SettingsToggleRow(
          title: l10n.settingsNotifTournament,
          value: _notifTournament,
          onChanged: (v) => _toggleNotification(
            NotificationType.tournament,
            v,
            (val) => _notifTournament = val,
          ),
        ),
        SettingsToggleRow(
          title: l10n.settingsNotifAchievement,
          value: _notifAchievement,
          onChanged: (v) => _toggleNotification(
            NotificationType.achievement,
            v,
            (val) => _notifAchievement = val,
          ),
        ),
        SettingsToggleRow(
          title: l10n.settingsNotifSocial,
          value: _notifSocial,
          onChanged: (v) => _toggleNotification(
            NotificationType.social,
            v,
            (val) => _notifSocial = val,
          ),
        ),
        SettingsToggleRow(
          title: l10n.settingsNotifSpecialEvents,
          value: _notifSpecialEvent,
          onChanged: (v) => _toggleNotification(
            NotificationType.specialEvent,
            v,
            (val) => _notifSpecialEvent = val,
          ),
        ),
      ],
    );
  }

  // ==================== ACCOUNT ====================

  Widget _account(AppLocalizations l10n, AuthState authState) {
    final p = context.lb;
    // Resolve the username explicitly so the row labels it as "Username"
    // and shows the same value the change-username dialog pre-fills.
    // Falls back to displayName / 'Not set' so the row never goes blank.
    final username = authState.user?.username;
    final hasRealUsername = username != null && username.isNotEmpty;
    final usernameLabel = hasRealUsername
        ? username
        : (authState.user?.displayName.isNotEmpty == true
            ? authState.user!.displayName
            : l10n.settingsNotSet);
    // hasNoCredential, not isGuestUser: a silently-created Firebase
    // anonymous account is still an account nobody chose and nobody can
    // recover. Calling it "signed in" is the lie that made this confusing.
    final guest = authState.hasNoCredential;

    return SettingsSection(
      label: l10n.settingsSectionUserProfile,
      children: [
        LBBlock(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              LBPixelIcon(guest ? LBIcon.user : LBIcon.shield, cell: 4, color: guest ? p.inkMuted : p.lime),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsUsername.toUpperCase(), style: LBText.label(p)),
                    const SizedBox(height: 4),
                    Text(
                      '@$usernameLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LBText.value(p, color: p.head, size: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guest ? l10n.settingsGuestAccount : l10n.settingsAuthenticatedAccount,
                      style: LBText.body(p, size: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (guest) ...[
          // States the consequence; tapping it is the fix (shared upgrade
          // sheet), same as the standalone notice it replaces here.
          LBBlock(
            kind: LBBlockKind.danger,
            onTap: () => showAccountUpgradeSheet(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: LBPixelIcon(LBIcon.x, cell: 3, color: LB.bonk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountNotBackedUpTitle.toUpperCase(),
                        style: LBText.button(p, color: LB.bonk, size: 12.5),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.accountNotBackedUpBody, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const LBPixelIcon(LBIcon.next, cell: 2.4, color: LB.bonk),
              ],
            ),
          ),
          // A real, tappable way to sign in. Routes through the shared
          // upgrade sheet rather than a bare Google button so Settings
          // offers the same Google / Apple / email choices as every other
          // surface — and links rather than re-signs-in when there is an
          // anonymous UID worth preserving.
          SettingsValueRow(
            title: l10n.eaSignIn,
            leading: const LBPixelIcon(LBIcon.user, cell: 3.4),
            onTap: () => showAccountUpgradeSheet(context),
          ),
          SettingsValueRow(
            title: l10n.settingsChangeUsername,
            onTap: () => _showUsernameDialog(authState),
          ),
          SettingsCaption(l10n.settingsGuestSignInHint),
        ] else ...[
          SettingsValueRow(
            title: l10n.settingsChangeUsername,
            onTap: () => _showUsernameDialog(authState),
          ),
          SettingsCaption(l10n.settingsUsernameVisibleHint),
        ],
      ],
    );
  }

  // ==================== YOUR GAME ====================

  /// Statistics and replays — "about your game".
  Widget _yourGame(AppLocalizations l10n) {
    return SettingsSection(
      label: l10n.settingsSectionYourGame,
      children: [
        SettingsValueRow(
          title: l10n.pfStatistics,
          subtitle: l10n.settingsStatisticsSubtitle,
          leading: const LBPixelIcon(LBIcon.chart, cell: 3.4),
          onTap: () => context.push(AppRoutes.statistics),
        ),
        SettingsValueRow(
          title: l10n.pfReplays,
          subtitle: l10n.settingsReplaysSubtitle,
          leading: const LBPixelIcon(LBIcon.film, cell: 3.4),
          onTap: () => context.push(AppRoutes.replays),
        ),
      ],
    );
  }

  // ==================== HELP ====================

  Widget _help(AppLocalizations l10n, GameTheme theme) {
    final ads = getIt.isRegistered<AdService>() ? getIt<AdService>() : null;
    // Only when ads are enabled AND a consent form is actually available.
    // Without the form check this opened nothing (and logged a "no form(s)
    // configured" UMP error) when no consent form exists for the app ID or
    // consent isn't required in the user's region.
    final showAdPrivacy = ads != null && ads.adsEnabled && ads.privacyOptionsRequired;
    return SettingsSection(
      label: l10n.settingsSectionHelp,
      children: [
        SettingsValueRow(
          title: l10n.settingsReplayTutorial,
          subtitle: l10n.settingsReplayTutorialSubtitle,
          leading: const LBPixelIcon(LBIcon.play, cell: 3.4),
          onTap: _showReplayTutorialSheet,
        ),
        SettingsValueRow(
          title: l10n.lbCtrlReference,
          subtitle: l10n.lbCtrlReferenceSub,
          leading: const LBPixelIcon(LBIcon.target, cell: 3.4),
          onTap: _showControlReferenceSheet,
        ),
        SettingsValueRow(
          title: l10n.settingsAboutCredits,
          subtitle: l10n.settingsAboutCreditsSubtitle,
          leading: const LBPixelIcon(LBIcon.heart, cell: 3.4),
          onTap: () => showCreditsDialog(context, theme),
        ),
        // Explicit "Rate us" — opens the store listing directly (not the
        // quota-limited in-app review sheet, which the platform may silently
        // skip on a deliberate tap). The in-app sheet still fires at
        // positive moments via ReviewService.maybeRequestReview.
        SettingsValueRow(
          title: l10n.settingsRateApp,
          subtitle: defaultTargetPlatform == TargetPlatform.iOS
              ? l10n.settingsRateAppSubtitleIos
              : l10n.settingsRateAppSubtitle,
          leading: const LBPixelIcon(LBIcon.star, cell: 3.4),
          onTap: () => getIt<ReviewService>().openStoreListing(),
        ),
        // Re-opens Google's UMP privacy options form so users can change
        // their personalized-ad consent. Free users with ads only.
        if (showAdPrivacy)
          SettingsValueRow(
            title: l10n.settingsAdPrivacy,
            subtitle: l10n.settingsAdPrivacySubtitle,
            leading: const LBPixelIcon(LBIcon.eye, cell: 3.4),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final snackTheme = context.read<ThemeCubit>().state.currentTheme;
              final shown = await ads.showPrivacyOptions();
              if (!shown) {
                messenger.showSnackBar(
                  arcadeSnackBarFor(snackTheme, message: l10n.settingsAdPrivacyUnavailable),
                );
              }
            },
          ),
      ],
    );
  }

  void _showReplayTutorialSheet() {
    final l10n = AppLocalizations.of(context)!;
    showLBSheet<void>(
      context: context,
      title: l10n.settingsReplayDialogTitle,
      subtitle: l10n.settingsReplayDialogBody,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsValueRow(
            title: l10n.settingsHomeTour,
            leading: const LBPixelIcon(LBIcon.grid, cell: 3.4),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final walkthroughService = WalkthroughService();
              await walkthroughService.initialize();
              await walkthroughService.reset(WalkthroughService.homeWalkthroughId);
              if (mounted) {
                context.go(AppRoutes.home);
              }
            },
          ),
          SettingsValueRow(
            title: l10n.settingsGameTutorial,
            leading: const LBPixelIcon(LBIcon.play, cell: 3.4),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final walkthroughService = WalkthroughService();
              await walkthroughService.initialize();
              await walkthroughService.reset(WalkthroughService.gameTutorialId);
              if (mounted) {
                // The request travels with the navigation. Resetting the
                // stored flag and going to /game used to be the whole
                // implementation, and nothing on the game screen read that
                // flag — so the tutorial never appeared.
                context.go(AppRoutes.gameWithTutorial);
              }
            },
          ),
          LBBlock(
            kind: LBBlockKind.muted,
            height: 46,
            alignment: Alignment.center,
            onTap: () => Navigator.of(sheetContext).pop(),
            child: Text(
              l10n.commonCancel.toUpperCase(),
              style: LBText.button(sheetContext.lb, color: sheetContext.lb.inkMuted, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// The controls reference: the gesture, and what it does. Documentation,
  /// not a menu — two columns, no chevrons.
  void _showControlReferenceSheet() {
    final l10n = AppLocalizations.of(context)!;
    final desktop = kIsWeb ||
        (!defaultTargetPlatform.toString().contains('android') &&
            !defaultTargetPlatform.toString().contains('ios'));
    final rows = <Widget>[
      if (desktop) ...[
        // Desktop/Web controls
        _refLabel(l10n.settingsDesktopControls),
        _refRow(l10n.settingsArrowKeys, l10n.settingsChangeDirection),
        _refRow(l10n.settingsWasdKeys, l10n.settingsChangeDirection),
        _refRow(l10n.settingsSpacebar, l10n.settingsPauseResume),
        _refRow(l10n.settingsMouseClick, l10n.settingsPauseResume),
        if (!kIsWeb) ...[
          const SizedBox(height: 12),
          _refLabel(l10n.settingsTouchControlsIfAvailable),
          _refRow(l10n.settingsSwipeGestures, l10n.settingsChangeDirection),
          _refRow(l10n.settingsTapScreen, l10n.settingsPauseResume),
        ],
      ] else ...[
        // Mobile controls
        _refLabel(l10n.settingsTouchControls),
        _refRow(l10n.settingsSwipeUp, l10n.settingsMoveSnakeUp),
        _refRow(l10n.settingsSwipeDown, l10n.settingsMoveSnakeDown),
        _refRow(l10n.settingsSwipeLeft, l10n.settingsMoveSnakeLeft),
        _refRow(l10n.settingsSwipeRight, l10n.settingsMoveSnakeRight),
        _refRow(l10n.settingsOnScreenControls, l10n.settingsOnScreenControlsDesc),
        _refRow(l10n.settingsTapScreen, l10n.settingsPauseResume),
      ],
    ];
    showLBSheet<void>(
      context: context,
      title: l10n.lbCtrlReference,
      builder: (_) => SingleChildScrollView(
        child: LBBlock(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
      ),
    );
  }

  Widget _refLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text.toUpperCase(), style: LBText.label(context.lb)),
      );

  Widget _refRow(String control, String action) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(control, style: LBText.body(p, color: p.ink, size: 12.5).copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(action, textAlign: TextAlign.end, style: LBText.body(p, size: 11.5)),
          ),
        ],
      ),
    );
  }

  // ==================== LEGAL ====================

  void _openLegalDoc(
    String title,
    String assetPath,
    IconData icon,
    String fallbackUrl,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: title,
          assetPath: assetPath,
          icon: icon,
          fallbackUrl: fallbackUrl,
        ),
      ),
    );
  }

  void _openPrivacyPolicy() {
    final l10n = AppLocalizations.of(context)!;
    _openLegalDoc(
      l10n.settingsPrivacyPolicyTitle,
      'assets/legal/PRIVACY.md',
      Icons.privacy_tip_outlined,
      'https://legal.pranta.dev/privacy?projectName=snake_classic',
    );
  }

  Widget _legal(AppLocalizations l10n) {
    return SettingsSection(
      label: l10n.settingsSectionLegal,
      children: [
        SettingsValueRow(
          title: l10n.settingsPrivacyPolicyButton,
          leading: const LBPixelIcon(LBIcon.shield, cell: 3.4),
          onTap: _openPrivacyPolicy,
        ),
        SettingsValueRow(
          title: l10n.settingsTermsButton,
          leading: const LBPixelIcon(LBIcon.copy, cell: 3.4),
          onTap: () => _openLegalDoc(
            l10n.settingsTermsTitle,
            'assets/legal/TERMS.md',
            Icons.description_outlined,
            'https://legal.pranta.dev/terms?projectName=snake_classic',
          ),
        ),
      ],
    );
  }

  // ==================== PREMIUM ====================

  Widget _premium(AppLocalizations l10n, PremiumState premiumState) {
    final p = context.lb;
    final pro = premiumState.hasPremium;
    return SettingsSection(
      label: l10n.settingsSectionPremium,
      children: [
        LBBlock(
          kind: pro ? LBBlockKind.gold : LBBlockKind.outline,
          selected: pro,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              LBPixelIcon(pro ? LBIcon.crown : LBIcon.lock, cell: 4, color: pro ? LB.gold : p.lime),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (pro ? l10n.settingsProTitle : l10n.settingsPremiumStatus).toUpperCase(),
                      style: LBText.button(p, color: pro ? LB.gold : p.head, size: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pro ? l10n.settingsActiveSubscription : l10n.settingsUnlockPremium,
                      style: LBText.body(p, size: 11),
                    ),
                    if (pro && premiumState.subscriptionExpiry != null)
                      Text(
                        l10n.settingsRenews(context.formatMonthDay(premiumState.subscriptionExpiry!)),
                        style: LBText.body(p, color: p.inkDim, size: 11),
                      ),
                  ],
                ),
              ),
              if (pro) LBChip(label: l10n.settingsProBadge, kind: LBChipKind.gold),
            ],
          ),
        ),
        // The Pro CTA routes to the dedicated subscription screen
        // (PremiumBenefitsScreen) — the same destination the pause overlay
        // uses.
        if (!pro)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: settingsRowHeight(context)),
            child: LBBlock(
              kind: LBBlockKind.goldFill,
              alignment: Alignment.center,
              onTap: () => context.push(AppRoutes.premiumBenefits),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LBPixelIcon(LBIcon.crown, cell: 3, color: LBBlock.foregroundOf(LBBlockKind.goldFill, p)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      l10n.settingsUpgradeToPro.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: LBText.button(p, color: LBBlock.foregroundOf(LBBlockKind.goldFill, p), size: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SettingsValueRow(
          title: l10n.settingsRestorePurchases,
          leading: const LBPixelIcon(LBIcon.next, cell: 3.4),
          onTap: _restorePurchases,
        ),
        SettingsValueRow(
          title: l10n.settingsPurchaseHistory,
          leading: const LBPixelIcon(LBIcon.hourglass, cell: 3.4),
          onTap: _showPurchaseHistory,
        ),
        if (pro || premiumState.ownedSkins.isNotEmpty)
          SettingsValueRow(
            title: l10n.settingsSnakeCosmetics,
            leading: const LBPixelIcon(LBIcon.star, cell: 3.4),
            value: premiumState.ownedSkins.isNotEmpty ? context.formatInt(premiumState.ownedSkins.length) : null,
            onTap: () => context.push(AppRoutes.cosmetics),
          ),
        if (premiumState.hasBattlePass)
          SettingsValueRow(
            title: l10n.settingsBattlePass,
            leading: const LBPixelIcon(LBIcon.trophy, cell: 3.4),
            value: l10n.settingsTier(premiumState.battlePassTier),
            onTap: () => context.push(AppRoutes.battlePass),
          ),
      ],
    );
  }

  void _restorePurchases() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.settingsRestoring));

      final purchaseService = PurchaseService();
      await purchaseService.restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.settingsRestored,
            tone: ArcadeSnackTone.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.settingsRestoreFailed,
            tone: ArcadeSnackTone.error,
          ),
        );
      }
    }
  }

  void _showPurchaseHistory() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final premiumCubit = context.read<PremiumCubit>();
      final history = await premiumCubit.getPurchaseHistory();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .65),
        builder: (dialogContext) {
          final p = dialogContext.lb;
          return _LBDialogFrame(
            title: l10n.settingsPurchaseHistory,
            actions: [
              LBBlock(
                kind: LBBlockKind.muted,
                height: 46,
                alignment: Alignment.center,
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.settingsClose.toUpperCase(), style: LBText.button(p, color: p.inkMuted, size: 12)),
              ),
            ],
            child: SizedBox(
              height: 300,
              child: history.isEmpty
                  ? Center(child: Text(l10n.settingsNoPurchases, style: LBText.body(p, size: 12)))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final purchase = history[index];
                        // Purchase is already a Map<String, dynamic>
                        try {
                          final productId = purchase['productId']?.toString() ?? l10n.settingsUnknown;
                          final transactionDate = purchase['transactionDate']?.toString() ?? '';
                          final status = purchase['status']?.toString() ?? l10n.settingsUnknown;

                          return LBBlock(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: LBPixelIcon(_getPurchaseIcon(_getTypeFromProductId(productId)), cell: 3),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatProductName(productId),
                                        style: LBText.button(p, size: 12).copyWith(letterSpacing: .6),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(l10n.settingsStatusLine(status), style: LBText.body(p, size: 11)),
                                      Text(
                                        l10n.settingsDateLine(_formatDate(transactionDate)),
                                        style: LBText.body(p, size: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          return LBBlock(
                            kind: LBBlockKind.muted,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.settingsPurchaseNumber(index + 1), style: LBText.button(p, size: 12)),
                                Text(l10n.settingsDataParseError, style: LBText.body(p, size: 11)),
                              ],
                            ),
                          );
                        }
                      },
                    ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.settingsHistoryLoadFailed,
            tone: ArcadeSnackTone.error,
          ),
        );
      }
    }
  }

  LBIcon _getPurchaseIcon(String type) {
    switch (type) {
      case 'subscription':
        return LBIcon.crown;
      case 'theme':
        return LBIcon.grid;
      case 'skin':
        return LBIcon.user;
      case 'trail':
        return LBIcon.flame;
      case 'bundle':
        return LBIcon.gift;
      case 'battlepass':
        return LBIcon.trophy;
      case 'tournament':
        return LBIcon.swords;
      default:
        return LBIcon.coin;
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return context.formatDate(date);
    } catch (e) {
      return AppLocalizations.of(context)!.settingsUnknownDate;
    }
  }

  String _getTypeFromProductId(String productId) {
    // Strip store prefix before checking
    final bare = ProductIds.stripPrefix(productId);
    if (bare.contains('pro_monthly') || bare.contains('pro_yearly')) {
      return 'subscription';
    } else if (bare.contains('theme')) {
      return 'theme';
    } else if (bare.contains('skin')) {
      return 'skin';
    } else if (bare.contains('trail')) {
      return 'trail';
    } else if (bare.contains('bundle') || bare.contains('pack') || bare.contains('collection')) {
      return 'bundle';
    } else if (bare.contains('battle_pass')) {
      return 'battlepass';
    } else if (bare.contains('tournament')) {
      return 'tournament';
    }
    return 'unknown';
  }

  String _formatProductName(String productId) {
    // Strip store prefix before formatting
    final bare = ProductIds.stripPrefix(productId);
    return bare
        .replaceAll('skin_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  // ==================== USERNAME ====================

  /// Maps a stable [UsernameError] code from UsernameService to the
  /// localized message shown in the username dialog.
  String _usernameErrorText(UsernameError code, AppLocalizations l10n) {
    switch (code) {
      case UsernameError.empty:
        return l10n.unEmpty;
      case UsernameError.tooShort:
        return l10n.unMinLength(UsernameService.minLength);
      case UsernameError.tooLong:
        return l10n.unMaxLength(UsernameService.maxLength);
      case UsernameError.invalidFormat:
        return l10n.unPattern;
      case UsernameError.reserved:
        return l10n.unReserved;
      case UsernameError.taken:
        return l10n.unTaken;
      case UsernameError.updateFailed:
        return l10n.unUpdateFailed;
    }
  }

  void _showUsernameDialog(AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    // Pre-fill with the current username so the user can see what it is
    // before editing, rather than retyping it for a small tweak.
    final currentUsername = authState.user?.username ?? '';
    final TextEditingController usernameController = TextEditingController(text: currentUsername);
    final UsernameService usernameService = UsernameService();
    String? errorMessage;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .65),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final p = dialogContext.lb;
            Future<void> submit() async {
              final newUsername = usernameController.text.trim();
              if (newUsername.isEmpty) return;

              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              bool success = false;
              final authCubit = context.read<AuthCubit>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final snackTheme = context.read<ThemeCubit>().state.currentTheme;

              if (authState.isGuestUser) {
                success = await authCubit.updateGuestUsername(newUsername);
                if (!success) {
                  final validation = usernameService.validateUsername(newUsername);
                  setState(() {
                    errorMessage = validation.errorCode != null
                        ? _usernameErrorText(validation.errorCode!, l10n)
                        : l10n.settingsUsernameUpdateFailed;
                  });
                }
              } else {
                // For authenticated users
                success = await authCubit.updateAuthenticatedUsername(newUsername);
                if (!success) {
                  final validation = await UsernameService().validateUsernameComplete(newUsername);
                  setState(() {
                    errorMessage = validation.errorCode != null
                        ? _usernameErrorText(validation.errorCode!, l10n)
                        : l10n.settingsUsernameUpdateFailed;
                  });
                }
              }

              if (success && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                scaffoldMessenger.showSnackBar(
                  arcadeSnackBarFor(
                    snackTheme,
                    message: l10n.settingsUsernameUpdated(newUsername),
                    tone: ArcadeSnackTone.success,
                  ),
                );
              }

              setState(() {
                isLoading = false;
              });
            }

            OutlineInputBorder border(Color c) => OutlineInputBorder(
                  borderRadius: BorderRadius.circular(LB.blockRadius),
                  borderSide: BorderSide(color: c),
                );

            return _LBDialogFrame(
              title: l10n.settingsChangeUsernameTitle,
              actions: [
                LBBlock(
                  kind: isLoading ? LBBlockKind.muted : LBBlockKind.fill,
                  height: 50,
                  alignment: Alignment.center,
                  onTap: isLoading ? null : submit,
                  child: isLoading
                      ? SizedBox(
                          width: 42,
                          child: LBCellsBar(count: 3, value: 1, cell: 14, semanticsLabel: l10n.settingsUpdate),
                        )
                      : Text(
                          l10n.settingsUpdate.toUpperCase(),
                          style: LBText.button(p, color: p.onLime, size: 13),
                        ),
                ),
                LBBlock(
                  kind: LBBlockKind.muted,
                  height: 46,
                  alignment: Alignment.center,
                  onTap: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancel.toUpperCase(), style: LBText.button(p, color: p.inkMuted, size: 12)),
                ),
              ],
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (currentUsername.isNotEmpty) ...[
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: LBChip(
                          label: '${l10n.settingsCurrentLabel} $currentUsername',
                          icon: LBIcon.user,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(l10n.settingsUsernameDialogBody, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: usernameController,
                      cursorColor: p.lime,
                      decoration: InputDecoration(
                        labelText: l10n.settingsUsername,
                        labelStyle: LBText.body(p, size: 12),
                        hintText: l10n.settingsEnterNewUsername,
                        hintStyle: LBText.body(p, color: p.inkDim, size: 12),
                        filled: true,
                        fillColor: p.blockFill,
                        border: border(p.blockStroke),
                        enabledBorder: border(p.blockStroke),
                        focusedBorder: border(p.lime),
                        errorBorder: border(LB.bonkStroke),
                        focusedErrorBorder: border(LB.bonk),
                        errorText: errorMessage,
                        errorStyle: LBText.body(p, color: LB.bonk, size: 11),
                        counterStyle: LBText.body(p, color: p.inkDim, size: 10),
                      ),
                      style: LBText.body(p, color: p.ink, size: 14).copyWith(fontWeight: FontWeight.w700),
                      maxLength: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.settingsUsernameRules, style: LBText.body(p, color: p.inkDim, size: 11)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== DEBUG: TEST NOTIFICATIONS ====================

  /// Diagnostic surface for the notification pipeline. Each button isolates
  /// one layer:
  ///   • Send Local Test   → permission + channel + display path
  ///   • Send Push via Backend → FCM token + backend send + delivery
  ///   • Copy FCM Token    → manual Firebase Console testing
  /// If "local" works but "backend" doesn't, the break is in token
  /// registration or backend send. If neither works, the OS-level
  /// permission is denied. Debug builds only, so its copy is not localized.
  Widget _buildNotificationTestPanel() {
    final fcmToken = _notificationService.fcmToken;
    final hasFcmToken = fcmToken != null && fcmToken.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsValueRow(
          title: 'SEND LOCAL TEST',
          subtitle: 'Fires immediately. If you don\'t see it, OS permission is denied '
              'or the channel is blocked in system settings.',
          onTap: _sendTestLocalNotification,
        ),
        SettingsValueRow(
          title: hasFcmToken ? 'SEND PUSH VIA BACKEND' : 'NO FCM TOKEN',
          subtitle: hasFcmToken
              ? 'Backend sends a push to your device via FCM. Should arrive '
                  'within ~5 seconds if token + backend + delivery all work.'
              : 'FCM token not yet registered. Sign in or restart the app, '
                  'then return to retry.',
          onTap: hasFcmToken ? _sendTestPushViaBackend : null,
        ),
        SettingsValueRow(
          title: 'COPY FCM TOKEN',
          subtitle: 'Debug only. Paste into Firebase Console → Cloud Messaging → '
              'Send test message to bypass the backend entirely.',
          onTap: hasFcmToken ? _copyFcmTokenToClipboard : null,
        ),
        SettingsValueRow(
          title: 'SCHEDULE TEST AT TIME',
          subtitle: 'Pick date + time. Backend schedules a one-off Hangfire job to '
              'fire an FCM push at that instant — fires even if the app is '
              'killed and even if the device clock drifts. Cancel via the '
              'next button.',
          onTap: _scheduleTestAtTime,
        ),
        SettingsValueRow(
          title: 'CANCEL SCHEDULED TEST',
          onTap: _cancelScheduledTest,
        ),
        SettingsValueRow(
          title: 'PREVIEW DAILY REMINDER',
          subtitle: 'Backend fires the exact daily reminder variant this user '
              'would receive at the next 20:00-local tick — streak / '
              'challenge / high-score branches all evaluated server-side '
              'from your real DB state. Bypasses the timing gate for '
              'instant verification.',
          onTap: _previewDailyReminder,
        ),
      ],
    );
  }

  Future<void> _sendTestLocalNotification() async {
    await _notificationService.sendTestLocalNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: 'Local test fired — check your notification tray.',
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _sendTestPushViaBackend() async {
    final ok = await _notificationService.sendTestNotificationViaBackend();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: ok
            ? 'Backend accepted the push. Should arrive within ~5s.'
            : 'Backend rejected. Check API logs (FCM token registered?).',
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _copyFcmTokenToClipboard() async {
    final token = _notificationService.fcmToken;
    if (token == null) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: 'FCM token copied. Paste into Firebase Console.',
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Two-step picker: date → time. Defaults bias toward "now + 2 min" so
  /// the common dev workflow (tap-tap-OK to verify scheduling works) is
  /// fast.
  Future<void> _scheduleTestAtTime() async {
    final now = DateTime.now();
    final preset = now.add(const Duration(minutes: 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: preset,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(preset),
    );
    if (pickedTime == null || !mounted) return;

    final fireAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!fireAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        arcadeSnackBar(
          context,
          message: 'Pick a future date + time',
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final ok = await _notificationService.scheduleTestNotificationAt(fireAt);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: ok
            ? 'Scheduled via backend for ${_formatScheduledTime(fireAt)}'
            : 'Backend rejected the schedule. Check the API logs.',
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _cancelScheduledTest() async {
    final ok = await _notificationService.cancelScheduledTestNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: ok
            ? 'Scheduled test cancelled (backend job deleted)'
            : 'Cancel returned non-200 — local handle cleared anyway',
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _previewDailyReminder() async {
    // Backend reads streak / challenge / high-score state from the DB
    // directly. Variant matches exactly what the wild user would see at the
    // next 20:00-local tick.
    final variant = await _notificationService.previewDailyReminder();

    if (!mounted) return;
    final message = variant == null
        ? 'No variant applied (no streak / no challenge / no high score yet, or no FCM token registered).'
        : 'Preview fired via backend (variant: $variant). Check your tray.';
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: message,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatScheduledTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.month}/${dt.day} $hh:$mm';
  }
}

/// A centred Living Board dialog frame with a free-form body and a stack of
/// actions — for the dialogs [showLBDialog] cannot express (a text field
/// with live validation, a scrolling list).
class _LBDialogFrame extends StatelessWidget {
  const _LBDialogFrame({required this.title, required this.child, required this.actions});

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: LBBlock(
          kind: LBBlockKind.sheet,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title.toUpperCase(), style: LBText.button(p, color: p.head, size: 14)),
              const SizedBox(height: 12),
              Flexible(child: child),
              const SizedBox(height: 16),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
