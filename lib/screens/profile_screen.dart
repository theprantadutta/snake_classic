import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/achievement_l10n.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/account_switch_confirmation.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/not_backed_up_notice.dart';
import 'package:snake_classic/widgets/themed_loading.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppDataCache _appCache;

  @override
  void initState() {
    super.initState();
    _appCache = getIt<AppDataCache>();
    // Trigger background refresh for fresh data (non-blocking)
    _appCache.refreshInBackground();

    // Edge case: if the screen is opened while already unauthenticated
    // (token expired, race during nav), the BlocListener won't fire because
    // there's no state transition. Schedule a redirect for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      if (authState.status == AuthStatus.unauthenticated) {
        context.go(AppRoutes.firstTimeAuth);
      }
    });
  }

  // Convenience getters using cached data
  Map<String, dynamic> get _displayStats => _appCache.statistics ?? {};
  List<Achievement> get _recentAchievements => _appCache.recentAchievements ?? [];
  // Gated on the LOCAL group only — this panel renders statistics that come
  // straight from Drift. isFullyLoaded also requires the network group, which
  // is skipped on a first-run preload, so using it here left the spinner up
  // for the entire first session on data that was already in hand.
  bool get _isLoading => !_appCache.isLocalDataLoaded;

  /// Localized duration for the play-time stat. getDisplayStatistics()
  /// returns RAW seconds; the stDur* ARB keys carry per-locale unit letters.
  String _formatDuration(AppLocalizations l10n, int seconds) {
    if (seconds < 60) {
      return l10n.stDurSeconds(seconds);
    } else if (seconds < 3600) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return s == 0 ? l10n.stDurMinutes(m) : l10n.stDurMinSec(m, s);
    } else {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      return m == 0 ? l10n.stDurHours(h) : l10n.stDurHourMin(h, m);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final theme = themeState.currentTheme;

    // BlocListener routes the user to the sign-in screen as soon as they
    // become unauthenticated (i.e. after a successful sign-out). This is the
    // sole place the redirect happens — the build path below is responsible
    // for the loader UI during the transition itself.
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.unauthenticated &&
          previous.status != AuthStatus.unauthenticated,
      listener: (context, state) {
        if (mounted) {
          // .go (not .push) so the back stack doesn't preserve the stale
          // profile screen behind the auth screen.
          context.go(AppRoutes.firstTimeAuth);
        }
      },
      // Subscribe to AppDataCache so a post-game refreshStatistics() call
      // rebuilds the stat row with the updated high score / totals. Without
      // this, the cached snapshot from app startup stays visible.
      child: ListenableBuilder(
        listenable: _appCache,
        builder: (context, _) => BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return Scaffold(
            bottomNavigationBar: const SnakeBannerAd(),
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              // Matches SettingsScreen exactly — accent, tracked, uppercase.
              // Every other top-level screen wears this; Profile was the one
              // still in title case and primaryColor, which is a small part of
              // why it read as belonging to a different app.
              title: Text(
                AppLocalizations.of(context)!.pfTitle.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                  letterSpacing: context.letterSpacing(2),
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.backgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            body: AnimatedAppBackground(
              theme: theme,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0 + context.sideInset(),
                  ),
                  child: _buildBody(context, authState, themeState),
                ),
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  /// Pick the right body view for the current auth state. Loading takes
  /// priority over content so we never render a half-rendered profile
  /// (with stale name/badge/sections) while sign-out is in flight.
  Widget _buildBody(
    BuildContext context,
    AuthState authState,
    ThemeState themeState,
  ) {
    if (authState.isLoading) {
      return _buildFullScreenLoader(
        themeState,
        message: AppLocalizations.of(context)!.pfSigningOut,
      );
    }
    if (authState.isSignedIn) {
      return _buildProfileContent(context, authState, themeState);
    }
    // Unauthenticated and not loading — the BlocListener will navigate us
    // away on the next frame, but show a clean spinner so we don't flash
    // the inline sign-in content during the redirect.
    return _buildFullScreenLoader(themeState);
  }

  Widget _buildFullScreenLoader(ThemeState themeState, {String? message}) {
    final theme = themeState.currentTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.accentColor, strokeWidth: 3),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE CONTENT
  //
  // Rebuilt to the language the rest of the app settled on (see SettingsScreen):
  // an uppercase accent eyebrow over a hairline-bordered translucent card, one
  // column, everything monochrome against the active theme. The screen it
  // replaced predated that language — multicolour gradient tiles, per-section
  // borders in blue / amber / purple / red, and a drop shadow on every block —
  // which is why it read as a different app.
  //
  // Two structural changes beyond restyling:
  //
  //  * The identity block absorbs the old level card. Avatar, name, account
  //    state and level progress are one fact about the player, so they are one
  //    element: the XP ring IS the avatar's border.
  //  * The three quick-action tiles are gone. Each one duplicated a "View all"
  //    link already sitting in that section's header, and they were the
  //    loudest thing on the screen.
  // ===========================================================================

  Widget _buildProfileContent(
    BuildContext context,
    AuthState authState,
    ThemeState themeState,
  ) {
    final theme = themeState.currentTheme;
    final l10n = AppLocalizations.of(context)!;
    final replayKeys = _appCache.replayKeys ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // Qualifies everything below it — the high score, the achievements
          // and the replays are all device-local until this is resolved.
          if (authState.hasNoCredential) ...[
            NotBackedUpNotice(theme: theme),
            const SizedBox(height: 24),
          ],

          _buildIdentity(context, authState, theme),
          const SizedBox(height: 28),

          _buildSection(
            theme: theme,
            title: l10n.pfStatistics,
            onViewAll: _isLoading ? null : () => _navigateToStatistics(context),
            child: _isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ThemedLoading(theme: theme, label: l10n.pfLoadingStats),
                  )
                : _buildStatGrid(l10n, theme),
          ),

          if (_recentAchievements.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSection(
              theme: theme,
              title: l10n.pfAchievements,
              onViewAll: () => _navigateToAchievements(context),
              child: Column(
                children: [
                  for (var i = 0; i < _recentAchievements.length; i++) ...[
                    if (i > 0) _hairline(theme),
                    _buildAchievementRow(_recentAchievements[i], theme),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          _buildSection(
            theme: theme,
            title: l10n.pfReplays,
            onViewAll:
                replayKeys.isEmpty ? null : () => _navigateToReplays(context),
            child: replayKeys.isEmpty
                ? _buildEmptyLine(l10n.pfNoReplays)
                : Row(
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        color: theme.accentColor,
                        size: context.scaled(20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.pfReplaysSaved(replayKeys.length),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),

          if (authState.hasNoCredential) ...[
            const SizedBox(height: 24),
            _buildSection(
              theme: theme,
              // "Sign in" rather than pfUpgradeTitle ("Upgrade to Google
              // Account"): as a section eyebrow that was both shouty and
              // wrong on iOS, where Apple is offered alongside Google. The
              // card's first line already explains what signing in buys.
              title: l10n.eaSignIn,
              child: _buildSignInBlock(context, l10n, theme),
            ),
          ],

          if (!authState.isLoading) ...[
            const SizedBox(height: 24),
            _buildSection(
              theme: theme,
              title: l10n.pfAccountManagement,
              child: Column(
                children: [
                  _buildAccountAction(
                    icon: Icons.logout_rounded,
                    label: l10n.pfSignOut,
                    color: Colors.white.withValues(alpha: 0.85),
                    onTap: () => _showSignOutDialog(context, theme),
                  ),
                  _hairline(theme),
                  // App Store Guideline 5.1.1(v): deletion must be initiable
                  // in-app wherever accounts can be created.
                  _buildAccountAction(
                    icon: Icons.delete_forever_rounded,
                    label: l10n.pfDeleteAccount,
                    color: Colors.redAccent,
                    onTap: () => _showDeleteAccountDialog(context, theme),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Eyebrow + hairline card. Mirrors `SettingsScreen._buildSection` so the two
  /// screens read as the same product; [onViewAll] renders as a quiet text
  /// affordance rather than the filled gradient pill this screen used to have,
  /// which competed with the content it was pointing at.
  Widget _buildSection({
    required GameTheme theme,
    required String title,
    required Widget child,
    VoidCallback? onViewAll,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: context.letterSpacing(1.5),
                  ),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          l10n.commonViewAll,
                          style: TextStyle(
                            color: theme.accentColor.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: context.scaled(18),
                          color: theme.accentColor.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ],
    );
  }

  /// Avatar, name, account state and level in one block.
  ///
  /// The XP ring doubles as the avatar's border — the signature element of the
  /// screen, and the reason the old standalone level card is gone. Progress
  /// belongs to the player, so it is drawn on the player.
  Widget _buildIdentity(
    BuildContext context,
    AuthState authState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final progression = getIt<ProgressionService>();
    final isGuest = authState.hasNoCredential;
    final stateColor = isGuest ? Colors.orange : theme.accentColor;

    return ListenableBuilder(
      listenable: progression,
      builder: (context, _) {
        final level = progression.level;
        final into = progression.xpIntoLevel;
        final needed = progression.xpForNextLevel;
        final fraction = needed <= 0 ? 0.0 : (into / needed).clamp(0.0, 1.0);
        final ring = context.scaled(128);

        return Column(
          children: [
            SizedBox(
              width: ring,
              height: ring,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: fraction,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor:
                          theme.accentColor.withValues(alpha: 0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.accentColor),
                    ),
                  ),
                  CircleAvatar(
                    radius: ring / 2 - 10,
                    backgroundColor: theme.backgroundColor.withValues(alpha: 0.6),
                    backgroundImage: authState.photoURL != null
                        ? NetworkImage(authState.photoURL!)
                        : null,
                    // Avatars fail to load on flaky connections constantly;
                    // swallow it and keep the fallback icon.
                    onBackgroundImageError:
                        authState.photoURL != null ? (e, s) {} : null,
                    child: authState.photoURL == null
                        ? Icon(
                            Icons.person_rounded,
                            size: context.scaled(52),
                            color: theme.accentColor,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authState.publicLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Outlined, not filled: the account state is information, not a
            // call to action. The action lives in the sign-in section below.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: stateColor.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGuest ? Icons.person_outline_rounded : Icons.verified_rounded,
                    size: context.scaled(14),
                    color: stateColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isGuest ? l10n.pfGuestPlayer : l10n.pfVerifiedAccount,
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: context.letterSpacing(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${l10n.ppgLevel(level)}  ·  $into / $needed XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                letterSpacing: context.letterSpacing(0.3),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Six stats, label above value, two per row.
  ///
  /// Icons were dropped: six of them competing at the same weight made the
  /// block read as a toolbar rather than a set of numbers, and the label
  /// already says what each one is.
  Widget _buildStatGrid(AppLocalizations l10n, GameTheme theme) {
    final cells = <_Stat>[
      _Stat(l10n.pfHighScore, _displayStats['highScore']?.toString() ?? '0'),
      _Stat(l10n.pfGamesPlayed, _displayStats['totalGames']?.toString() ?? '0'),
      _Stat(
        l10n.pfPlayTime,
        _formatDuration(
          l10n,
          (_displayStats['totalPlayTime'] as num?)?.toInt() ?? 0,
        ),
      ),
      _Stat(l10n.pfAverageScore, _displayStats['averageScore']?.toString() ?? '0'),
      _Stat(l10n.pfFoodConsumed, _displayStats['totalFood']?.toString() ?? '0'),
      _Stat(l10n.pfPowerUps, _displayStats['totalPowerUps']?.toString() ?? '0'),
    ];

    return Column(
      children: [
        for (var row = 0; row < cells.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatCell(cells[row])),
              const SizedBox(width: 16),
              Expanded(
                child: row + 1 < cells.length
                    ? _buildStatCell(cells[row + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatCell(_Stat stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: context.letterSpacing(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementRow(Achievement achievement, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: theme.accentColor,
            size: context.scaled(22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.localizedTitle(l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.localizedDescription(l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// What signing in buys, then the ways to do it.
  Widget _buildSignInBlock(
    BuildContext context,
    AppLocalizations l10n,
    GameTheme theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pfUpgradeSubtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        _buildBenefitRow(theme, Icons.cloud_done_rounded, l10n.pfBenefitSync,
            l10n.pfBenefitSyncSub),
        const SizedBox(height: 12),
        _buildBenefitRow(theme, Icons.leaderboard_rounded,
            l10n.pfBenefitLeaderboards, l10n.pfBenefitLeaderboardsSub),
        const SizedBox(height: 12),
        _buildBenefitRow(theme, Icons.people_alt_rounded, l10n.pfBenefitSocial,
            l10n.pfBenefitSocialSub),
        const SizedBox(height: 20),
        _buildSignInButton(
          theme: theme,
          icon: FaIcon(
            FontAwesomeIcons.google,
            color: Colors.white,
            size: context.scaled(17),
          ),
          label: l10n.pfSignInGoogle,
          onTap: () => _handleGoogleUpgrade(context, theme),
        ),
        // Guideline 4.8: wherever Google is offered on an Apple platform,
        // Sign in with Apple rides along.
        if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) ...[
          const SizedBox(height: 10),
          _buildSignInButton(
            theme: theme,
            icon: FaIcon(
              FontAwesomeIcons.apple,
              color: Colors.white,
              size: context.scaled(19),
            ),
            label: l10n.pfSignInApple,
            onTap: () => _handleAppleUpgrade(context, theme),
          ),
        ],
      ],
    );
  }

  Widget _buildBenefitRow(
    GameTheme theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: context.scaled(18),
          color: theme.accentColor.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '  $subtitle',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Filled with the theme accent rather than a brand colour: a blue Google
  /// slab and a black Apple slab were the two loudest blocks on the screen and
  /// belonged to neither the theme nor each other.
  Widget _buildSignInButton({
    required GameTheme theme,
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: theme.accentColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sign out and delete are rows, not filled red slabs. Destructive actions
  /// should be findable and unmistakable, not the brightest thing on screen —
  /// the confirmation dialog is where the weight belongs.
  Widget _buildAccountAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.scaled(20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
              size: context.scaled(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hairline(GameTheme theme) => Divider(
        height: 1,
        thickness: 1,
        color: theme.accentColor.withValues(alpha: 0.15),
      );

  Widget _buildEmptyLine(String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 14,
          ),
        ),
      );

  void _navigateToStatistics(BuildContext context) {
    context.push(AppRoutes.statistics);
  }

  void _navigateToAchievements(BuildContext context) {
    context.push(AppRoutes.achievements);
  }

  void _navigateToReplays(BuildContext context) {
    context.push(AppRoutes.replays);
  }

  void _showStyledSnackBar(
    BuildContext context,
    String message,
    Color color,
    GameTheme theme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleAppleUpgrade(
    BuildContext context,
    GameTheme theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final authCubit = context.read<AuthCubit>();
      // Links when there is a Firebase anonymous UID to preserve, and falls
      // back to a plain sign-in for offline guests (who have no Firebase user
      // at all). Either way the player's progress survives the upgrade.
      final success = await authCubit.connectAccountWithApple(
        confirmAccountSwitch: () => confirmAccountSwitch(context),
      );

      if (success && context.mounted) {
        _showStyledSnackBar(
          context,
          l10n.pfAppleUpgradeSuccess,
          Colors.green,
          theme,
        );
      } else if (context.mounted) {
        final isInUse = authCubit.state.errorMessage ==
            'credential-already-in-use';
        _showStyledSnackBar(
          context,
          isInUse ? l10n.pfAppleIdInUse : l10n.pfUpgradeFailed,
          Colors.red,
          theme,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showStyledSnackBar(
          context,
          l10n.pfUpgradeError,
          Colors.red,
          theme,
        );
      }
    }
  }

  Future<void> _handleGoogleUpgrade(
    BuildContext context,
    GameTheme theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final authCubit = context.read<AuthCubit>();
      // connectAccountWithGoogle, NOT signInWithGoogle: for a Firebase
      // anonymous user this LINKS the credential, preserving the UID and
      // with it the backend account holding their coins and progress. A
      // plain sign-in mints a different UID and strands all of it. The
      // store sheet has always used the connect path; this screen didn't,
      // so the same button meant two different things depending on where
      // you tapped it.
      final success = await authCubit.connectAccountWithGoogle(
        confirmAccountSwitch: () => confirmAccountSwitch(context),
      );

      if (success && context.mounted) {
        _showStyledSnackBar(
          context,
          l10n.pfGoogleUpgradeSuccess,
          Colors.green,
          theme,
        );
      } else if (context.mounted) {
        _showStyledSnackBar(
          context,
          l10n.pfUpgradeFailed,
          Colors.red,
          theme,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showStyledSnackBar(
          context,
          l10n.pfUpgradeError,
          Colors.red,
          theme,
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        title: Text(
          l10n.pfDeleteAccountTitle,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.pfDeleteAccountBody(
            defaultTargetPlatform == TargetPlatform.iOS
                ? l10n.pfAppStore
                : l10n.pfDeviceAppStore,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final authCubit = context.read<AuthCubit>();
              final deleted = await authCubit.deleteAccount();
              if (context.mounted) {
                _showStyledSnackBar(
                  context,
                  deleted ? l10n.pfAccountDeleted : l10n.pfDeleteFailed,
                  deleted ? Colors.blue : Colors.red,
                  theme,
                );
              }
              // Navigation back to the sign-in screen is handled by the
              // BlocListener watching for AuthStatus.unauthenticated, same
              // as sign-out.
            },
            child: Text(
              l10n.pfDeleteForever,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
        ),
        title: Text(
          l10n.pfSignOut,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.pfSignOutBody,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final authCubit = context.read<AuthCubit>();
              await authCubit.signOut();
              if (context.mounted) {
                _showStyledSnackBar(
                  context,
                  l10n.pfSignedOut,
                  Colors.blue,
                  theme,
                );
              }
            },
            child: Text(
              l10n.pfSignOut,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One label/value pair in the statistics grid. A record would do, but a named
/// type keeps the grid builder readable at the call site.
class _Stat {
  const _Stat(this.label, this.value);

  final String label;
  final String value;
}
