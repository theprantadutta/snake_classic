import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/providers/friends_provider.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/services/sync/sync_engine.dart';
import 'package:snake_classic/services/sync/sync_status.dart';
import 'package:snake_classic/widgets/account_switch_confirmation.dart';
import 'package:snake_classic/widgets/account_upgrade_sheet.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/profile/lb_profile_parts.dart';

/// Profile (Living Board screen 13): who you are, your numbers, a fun fact,
/// links to the deeper screens, and where your progress lives. Every account
/// action the screen had (sign in / link, sign out, delete) is still here,
/// below the sync block.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final AppDataCache _appCache;
  final AchievementService _achievements = AchievementService();
  late final ProgressionService _progression;
  SyncEngine? _sync;

  /// Which fun fact is showing. Seeded per visit; a tap moves to the next.
  late int _factIndex;

  @override
  void initState() {
    super.initState();
    _appCache = getIt<AppDataCache>();
    _progression = getIt<ProgressionService>();
    if (getIt.isRegistered<SyncEngine>()) _sync = getIt<SyncEngine>();
    _factIndex = math.Random().nextInt(3);
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

  Map<String, dynamic> get _displayStats => _appCache.statistics ?? {};

  // Gated on the LOCAL group only — this panel renders statistics that come
  // straight from Drift. isFullyLoaded also requires the network group, which
  // is skipped on a first-run preload, so using it here left the spinner up
  // for the entire first session on data that was already in hand.
  bool get _isLoading => !_appCache.isLocalDataLoaded;

  int _stat(String key) => (_displayStats[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Watched here, in the consumer's own build, so the subscription is
    // tracked per build. Only when the provider is already alive: creating
    // it from the profile would start its network refresh timer.
    final liveFriends = ref.exists(friendsProvider) ? ref.watch(friendsProvider).friends : null;

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
      // rebuilds the stat tiles with the updated high score / totals.
      // Progression and achievements notify on their own schedules.
      child: ListenableBuilder(
        listenable: Listenable.merge([_appCache, _progression, _achievements]),
        builder: (context, _) => BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            // Loading takes priority over content so we never render a
            // half-rendered profile while sign-out is in flight.
            if (authState.isLoading || !authState.isSignedIn) {
              return LBScaffold(
                title: l10n.lbProfileTitle,
                body: LBLoadingCells(
                  label: authState.isLoading ? l10n.pfSigningOut : null,
                ),
              );
            }
            return LBScaffold(
              title: l10n.lbProfileTitle,
              subtitle: l10n.lbProfileSubtitle,
              children: _content(context, authState, liveFriends),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AuthState authState, List<UserProfile>? liveFriends) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final isGuest = authState.hasNoCredential;

    return [
      _Identity(
        name: authState.publicLabel,
        chip: isGuest ? l10n.lbGuest : _providerChip(l10n),
        isGuest: isGuest,
        level: _progression.level,
        into: _progression.xpIntoLevel,
        needed: _progression.xpForNextLevel,
      ),
      SizedBox(height: cell * .9),

      if (_isLoading)
        LBBlock(
          height: cell * 6,
          child: LBLoadingCells(label: l10n.pfLoadingStats),
        )
      else ...[
        LBTwoColumns(
          children: [
            LBStatTile(
              label: l10n.lbStatBest,
              value: context.formatInt(_stat('highScore')),
              valueColor: LB.gold,
            ),
            LBStatTile(label: l10n.lbStatGames, value: context.formatInt(_stat('totalGames'))),
            LBStatTile(label: l10n.lbStatPlayTime, value: lbDuration(l10n, _stat('totalPlayTime'))),
            LBStatTile(
              label: l10n.lbStatAverage,
              value: context.formatInt((_displayStats['averageScore'] as num?) ?? 0),
            ),
            LBStatTile(label: l10n.lbStatFood, value: context.formatInt(_stat('totalFood'))),
            LBStatTile(label: l10n.lbStatPowerups, value: context.formatInt(_stat('totalPowerUps'))),
          ],
        ),
        _funFact(context, l10n),
      ],

      LBTwoColumns(
        children: [
          LBLinkBlock(
            icon: LBIcon.chart,
            label: l10n.lbStats,
            onTap: _isLoading ? null : () => context.push(AppRoutes.statistics),
          ),
          LBLinkBlock(
            icon: LBIcon.film,
            label: l10n.lbReplays,
            onTap: () => context.push(AppRoutes.replays),
          ),
          LBLinkBlock(
            icon: LBIcon.friends,
            label: l10n.lbFriends,
            trailing: _friendsOnline(context, l10n, liveFriends),
            onTap: () => context.push(AppRoutes.friends),
          ),
          LBLinkBlock(
            icon: LBIcon.trophy,
            label: l10n.lbTrophies,
            trailing: context.formatInt(_achievements.getUnlockedAchievements().length),
            onTap: () => context.push(AppRoutes.achievements),
          ),
        ],
      ),

      if (isGuest) _guestBlock(context, l10n, p) else _syncBlock(context, l10n, p),

      if (isGuest) ...[
        SizedBox(height: cell),
        // "Sign in" rather than pfUpgradeTitle ("Upgrade to Google
        // Account"): it is wrong on iOS, where Apple is offered alongside
        // Google.
        LBSectionLabel(l10n.eaSignIn),
        _signInBlock(context, l10n, p),
      ],

      SizedBox(height: cell),
      LBSectionLabel(l10n.pfAccountManagement),
      LBRow(
        title: l10n.pfSignOut,
        leading: LBPixelIcon(LBIcon.back, cell: 3, color: p.lime),
        onTap: () => _showSignOutDialog(context),
      ),
      // App Store Guideline 5.1.1(v): deletion must be initiable in-app
      // wherever accounts can be created.
      LBRow(
        title: l10n.pfDeleteAccount,
        kind: LBBlockKind.danger,
        leading: const LBPixelIcon(LBIcon.skull, cell: 3, color: LB.bonk),
        onTap: () => _showDeleteAccountDialog(context),
      ),
    ];
  }

  /// "SIGNED IN · GOOGLE" — the provider comes from the live Firebase
  /// session (read-only). Unknown or unavailable → plain "SIGNED IN".
  String _providerChip(AppLocalizations l10n) {
    try {
      final ids = {
        for (final info in FirebaseAuth.instance.currentUser?.providerData ?? const <UserInfo>[])
          info.providerId,
      };
      if (ids.contains('google.com')) return l10n.lbSignedInWith(l10n.lbProviderGoogle);
      if (ids.contains('apple.com')) return l10n.lbSignedInWith(l10n.lbProviderApple);
      if (ids.contains('password')) return l10n.lbSignedInWith(l10n.lbProviderEmail);
    } catch (_) {
      // Firebase not initialised (offline cold start): fall through.
    }
    return l10n.lbSignedIn;
  }

  /// "{n} ON" from the friends provider when it is already alive (the
  /// Friends screen created it), else from the AppDataCache snapshot.
  /// Null (arrow instead) when nobody is on or nothing is known.
  String? _friendsOnline(BuildContext context, AppLocalizations l10n, List<UserProfile>? liveFriends) {
    final friends = liveFriends ?? _appCache.friendsList;
    if (friends == null) return null;
    final on = friends.where((f) => f.status != UserStatus.offline).length;
    return on > 0 ? l10n.lbFriendsOn(context.formatInt(on)) : null;
  }

  Widget _funFact(BuildContext context, AppLocalizations l10n) {
    final p = context.lb;
    final apples = _stat('totalFood');
    final minutes = _stat('totalPlayTime') ~/ 60;
    final powerUps = _stat('totalPowerUps');
    final facts = <String>[
      if (apples >= 10) l10n.lbFunApples(context.formatInt(apples), apples ~/ 10),
      if (minutes > 0) l10n.lbFunMinutes(minutes),
      if (powerUps > 0) l10n.lbFunPowerups(powerUps),
    ];
    // Nothing to brag about yet: a tip instead of "0 apples, 0 pies".
    if (facts.isEmpty) facts.add(l10n.lbTip6);
    final fact = facts[_factIndex % facts.length];
    return LBBlock(
      kind: LBBlockKind.gold,
      onTap: facts.length > 1 ? () => setState(() => _factIndex++) : null,
      semanticLabel: '${l10n.lbFunFact}. $fact',
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: ExcludeSemantics(
        child: Row(
          children: [
            LBPixelIcon(LBIcon.apple, cell: 4.4, color: LB.apple, accent: p.lime),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.lbFunFact, style: LBText.label(p, color: LB.gold)),
                  const SizedBox(height: 5),
                  AnimatedSwitcher(
                    duration: LB.reveal,
                    child: Text(
                      fact,
                      key: ValueKey(fact),
                      style: LBText.body(p, color: p.ink, size: 12).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Where the player's progress lives, from the canonical sync engine.
  Widget _syncBlock(BuildContext context, AppLocalizations l10n, LBPalette p) {
    Widget block(SyncStatusSnapshot s) {
      final synced = s.isFullySynced;
      return LBBlock(
        kind: LBBlockKind.dashed,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      synced ? l10n.lbSynced : l10n.lbSyncPending,
                      style: LBText.button(p, color: synced ? p.lime : p.head, size: 12.5),
                    ),
                    const SizedBox(height: 5),
                    Text(l10n.lbSyncedLine, style: LBText.body(p, size: 11.5)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              LBPixelIcon(
                synced ? LBIcon.check : LBIcon.hourglass,
                cell: 3.2,
                color: synced ? p.lime : p.inkMuted,
              ),
            ],
          ),
        ),
      );
    }

    final engine = _sync;
    if (engine == null) return block(const SyncStatusSnapshot());
    return StreamBuilder<SyncStatusSnapshot>(
      initialData: engine.status,
      stream: engine.statusStream,
      builder: (context, snap) => block(snap.data ?? const SyncStatusSnapshot()),
    );
  }

  /// Guests: their progress is tied to this install. Plain account copy.
  /// Tapping opens the same upgrade sheet the old "not backed up" notice did.
  Widget _guestBlock(BuildContext context, AppLocalizations l10n, LBPalette p) {
    return LBBlock(
      kind: LBBlockKind.dashed,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      semanticLabel: '${l10n.lbGuest}. ${l10n.lbGuestLine}',
      onTap: () => showAccountUpgradeSheet(context),
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.lbGuest, style: LBText.button(p, color: p.head, size: 12.5)),
                  const SizedBox(height: 5),
                  Text(l10n.lbGuestLine, style: LBText.body(p, size: 11.5)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            LBPixelIcon(LBIcon.next, cell: 2.4, color: p.lime),
          ],
        ),
      ),
    );
  }

  /// What signing in buys, then the ways to do it.
  Widget _signInBlock(BuildContext context, AppLocalizations l10n, LBPalette p) {
    Widget benefit(LBIcon icon, String title, String sub) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              LBPixelIcon(icon, cell: 2.6, color: p.lime),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: LBText.body(p, color: p.ink, size: 11.5).copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: '  $sub', style: LBText.body(p, size: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    Widget signInButton(Widget icon, String label, VoidCallback onTap) => LBBlock(
          height: context.lbCell * 2.5 - LB.inset * 2,
          alignment: Alignment.center,
          semanticLabel: label,
          onTap: onTap,
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.button(p, size: 12.5),
                  ),
                ),
              ],
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LBBlock(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.pfUpgradeSubtitle, style: LBText.body(p, color: p.ink, size: 12)),
              const SizedBox(height: 4),
              benefit(LBIcon.check, l10n.pfBenefitSync, l10n.pfBenefitSyncSub),
              benefit(LBIcon.trophy, l10n.pfBenefitLeaderboards, l10n.pfBenefitLeaderboardsSub),
              benefit(LBIcon.friends, l10n.pfBenefitSocial, l10n.pfBenefitSocialSub),
            ],
          ),
        ),
        signInButton(
          FaIcon(FontAwesomeIcons.google, color: p.head, size: 15),
          l10n.pfSignInGoogle,
          () => _handleGoogleUpgrade(context),
        ),
        // Guideline 4.8: wherever Google is offered on an Apple platform,
        // Sign in with Apple rides along, at the same size.
        if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)
          signInButton(
            FaIcon(FontAwesomeIcons.apple, color: p.head, size: 17),
            l10n.pfSignInApple,
            () => _handleAppleUpgrade(context),
          ),
      ],
    );
  }

  void _snack(BuildContext context, String message, ArcadeSnackTone tone) {
    final theme = context.read<ThemeCubit>().state.currentTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBarFor(theme, message: message, tone: tone),
    );
  }

  Future<void> _handleAppleUpgrade(BuildContext context) async {
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
        _snack(context, l10n.pfAppleUpgradeSuccess, ArcadeSnackTone.success);
      } else if (context.mounted) {
        final isInUse =
            authCubit.state.errorMessage == 'credential-already-in-use';
        _snack(
          context,
          isInUse ? l10n.pfAppleIdInUse : l10n.pfUpgradeFailed,
          ArcadeSnackTone.error,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, l10n.pfUpgradeError, ArcadeSnackTone.error);
      }
    }
  }

  Future<void> _handleGoogleUpgrade(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final authCubit = context.read<AuthCubit>();
      // connectAccountWithGoogle, NOT signInWithGoogle: for a Firebase
      // anonymous user this LINKS the credential, preserving the UID and
      // with it the backend account holding their coins and progress. A
      // plain sign-in mints a different UID and strands all of it.
      final success = await authCubit.connectAccountWithGoogle(
        confirmAccountSwitch: () => confirmAccountSwitch(context),
      );

      if (success && context.mounted) {
        _snack(context, l10n.pfGoogleUpgradeSuccess, ArcadeSnackTone.success);
      } else if (context.mounted) {
        _snack(context, l10n.pfUpgradeFailed, ArcadeSnackTone.error);
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, l10n.pfUpgradeError, ArcadeSnackTone.error);
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.pfDeleteAccountTitle,
      titleColor: LB.bonk,
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .45),
        child: SingleChildScrollView(
          child: Text(
            l10n.pfDeleteAccountBody(
              defaultTargetPlatform == TargetPlatform.iOS
                  ? l10n.pfAppStore
                  : l10n.pfDeviceAppStore,
            ),
            style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
          ),
        ),
      ),
      primaryLabel: l10n.pfDeleteForever,
      primaryKind: LBBlockKind.danger,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed != true || !context.mounted) return;

    final authCubit = context.read<AuthCubit>();
    final deleted = await authCubit.deleteAccount();
    if (context.mounted) {
      _snack(
        context,
        deleted ? l10n.pfAccountDeleted : l10n.pfDeleteFailed,
        deleted ? ArcadeSnackTone.info : ArcadeSnackTone.error,
      );
    }
    // Navigation back to the sign-in screen is handled by the BlocListener
    // watching for AuthStatus.unauthenticated, same as sign-out.
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.pfSignOut,
      body: l10n.pfSignOutBody,
      primaryLabel: l10n.pfSignOut,
      primaryKind: LBBlockKind.danger,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed != true || !context.mounted) return;

    final authCubit = context.read<AuthCubit>();
    await authCubit.signOut();
    if (context.mounted) {
      _snack(context, l10n.pfSignedOut, ArcadeSnackTone.info);
    }
  }
}

/// Avatar (initial in the cell font), name, account chip and level bar.
class _Identity extends StatelessWidget {
  const _Identity({
    required this.name,
    required this.chip,
    required this.isGuest,
    required this.level,
    required this.into,
    required this.needed,
  });

  final String name;
  final String chip;
  final bool isGuest;
  final int level;
  final int into;
  final int needed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final fraction = needed <= 0 ? 0.0 : (into / needed).clamp(0.0, 1.0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LBInitialAvatar(name: name, size: cell * 5),
        SizedBox(width: cell * .5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LBText.value(p, size: 16),
              ),
              const SizedBox(height: 8),
              LBChip(
                label: chip,
                icon: isGuest ? LBIcon.user : LBIcon.check,
                height: 24,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    l10n.lbLevelShort(context.formatInt(level)),
                    style: LBText.button(p, size: 12.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cell * 6),
                        child: LBCellsBar(
                          count: 10,
                          value: fraction,
                          semanticsLabel: l10n.lbLevelShort(context.formatInt(level)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${context.formatInt(into)}/${context.formatInt(needed)}',
                    style: LBText.body(p, size: 10.5).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
