import 'package:flutter/material.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final String? gameId;

  const MultiplayerLobbyScreen({super.key, this.gameId});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Lifetime W/L record from GET /multiplayer/record — display only,
  /// loaded non-blocking; the lobby renders fine without it.
  Map<String, dynamic>? _record;

  /// Whether the lifetime record is still being fetched. The strip renders
  /// from the first frame either way — this only decides whether the numbers
  /// or their placeholders are showing.
  bool _recordLoading = true;

  @override
  void initState() {
    super.initState();
    _connectivityService.addListener(_onConnectivityChanged);

    // The JOIN ROOM button enables on non-empty input — without this
    // listener typing never triggered a rebuild and the button stayed
    // disabled until an unrelated bloc update.
    _roomCodeController.addListener(_onRoomCodeChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If a room code was deep-linked (friend match ping), join it.
      if (widget.gameId != null) {
        if (_connectivityService.isOnline) {
          context.read<MultiplayerCubit>().joinGame(widget.gameId!);
        } else {
          _showOfflineMessage();
        }
      }

      // Attempted regardless: offline the request fails fast and the strip
      // settles on dashes rather than sitting in a loading state forever.
      _loadRecord();
    });
  }

  Future<void> _loadRecord() async {
    Map<String, dynamic>? record;
    try {
      record = await ApiService().getMultiplayerRecord();
    } catch (_) {
      record = null;
    }
    if (!mounted) return;
    setState(() {
      _record = record;
      _recordLoading = false;
    });
  }

  void _onRoomCodeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _roomCodeController.removeListener(_onRoomCodeChanged);
    _roomCodeController.dispose();
    super.dispose();
  }

  /// Friend picker → match-ping carrying this room's code, so the
  /// friend's notification tap deep-links them straight into the room.
  /// Friends come from the Drift cache (instant, works offline-read);
  /// the ping itself is a live call with a server-side 10-min cooldown
  /// per friend — refusals (cooldown) surface verbatim.
  Future<void> _showInviteFriendSheet(GameTheme theme, String roomCode) async {
    final friends = await SocialService().getFriends();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (friends.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mpLobbyNoFriends)));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.backgroundColor,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.mpLobbyInviteFriendTo(roomCode),
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (_, i) => _inviteFriendTile(
                  sheetContext,
                  theme,
                  friends[i],
                  roomCode,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _inviteFriendTile(
    BuildContext sheetContext,
    GameTheme theme,
    UserProfile friend,
    String roomCode,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.accentColor.withValues(alpha: 0.15),
        child: Text(
          friend.displayName.isNotEmpty
              ? friend.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(color: theme.accentColor),
        ),
      ),
      title: Text(
        friend.displayName,
        style: TextStyle(color: theme.accentColor),
      ),
      trailing: Icon(Icons.send, size: 18, color: theme.foodColor),
      onTap: () async {
        Navigator.of(sheetContext).pop();
        final (sent, message) = await SocialService().pingFriendForMatch(
          friend.uid,
          roomCode: roomCode,
        );
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sent
                  ? l10n.mpLobbyInviteSent(friend.displayName)
                  : (message ?? l10n.mpLobbyInviteFailed),
            ),
            backgroundColor: sent ? Colors.green.shade700 : Colors.red.shade700,
          ),
        );
      },
    );
  }

  void _onConnectivityChanged() {
    // Trigger rebuild when connectivity changes
    if (mounted) setState(() {});
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.mpLobbyOffline,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocListener<MultiplayerCubit, MultiplayerState>(
          listenWhen: (prev, curr) =>
              prev.errorCode != curr.errorCode && curr.errorCode != null,
          listener: (context, state) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorCode!.localizedMessage(
                          AppLocalizations.of(context)!,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.mpLobbyDismiss,
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            context.read<MultiplayerCubit>().clearError();
          },
          child: BlocBuilder<MultiplayerCubit, MultiplayerState>(
            builder: (context, multiplayerState) {
              return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  // Navigate to game screen when game starts
                  if (multiplayerState.isGameActive) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.pushReplacement(AppRoutes.multiplayerGame);
                    });
                  }

                  return Scaffold(
                    bottomNavigationBar: const SnakeBannerAd(),
                    body: AppBackground(
                      theme: theme,
                      child: SafeArea(
                        child: multiplayerState.matchmakingUnreachable
                            ? _buildMatchmakingUnreachableUI(
                                context,
                                multiplayerState,
                                theme,
                              )
                            : multiplayerState.status ==
                                  MultiplayerStatus.inMatchmaking
                            ? _buildMatchmakingUI(
                                context,
                                multiplayerState,
                                theme,
                              )
                            : multiplayerState.isInGame
                            ? _buildGameLobby(
                                context,
                                multiplayerState,
                                theme,
                                authState,
                              )
                            : _buildMainLobby(
                                context,
                                multiplayerState,
                                theme,
                                authState,
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMainLobby(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
    AuthState authState,
  ) {
    return Column(
      children: [
        // Header
        _buildHeader(theme),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20 + context.sideInset(),
              vertical: 20,
            ),
            child: Column(
              children: [
                // Lifetime VS record. Always in the tree — it used to be
                // gated on the fetch having returned, so the whole screen
                // jumped down a strip's height when the network answered, and
                // offline it never appeared at all.
                _buildRecordStrip(theme),
                const SizedBox(height: 20),

                // Quick Match Section
                _buildQuickMatchSection(context, multiplayerState, theme),

                const SizedBox(height: 24),

                // Join Game Section
                _buildJoinGameSection(context, multiplayerState, theme),

                const SizedBox(height: 24),

                // Create Game Section
                _buildCreateGameSection(context, multiplayerState, theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameLobby(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
    AuthState authState,
  ) {
    final game = multiplayerState.currentGame!;
    final isStarting = game.status == MultiplayerGameStatus.starting;

    return Stack(
      children: [
        Column(
          children: [
            // Header with room info
            _buildGameHeader(theme, game),

            // Game info and players
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 + context.sideInset(),
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Game mode info
                    _buildGameModeCard(theme, game),

                    const SizedBox(height: 24),

                    // Players list
                    _buildPlayersSection(theme, game, authState),

                    const Spacer(),

                    // Ready/Leave buttons
                    _buildLobbyActions(
                      context,
                      multiplayerState,
                      theme,
                      game,
                      authState,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Countdown overlay
        if (isStarting)
          _buildCountdownOverlay(theme, multiplayerState.countdownSeconds),
      ],
    );
  }

  Widget _buildCountdownOverlay(GameTheme theme, int countdownSeconds) {
    // Seconds come from the GameStarting payload so a server-side tuning
    // change can't drift from this animation.
    final l10n = AppLocalizations.of(context)!;
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: countdownSeconds, end: 0),
      duration: Duration(seconds: countdownSeconds),
      builder: (context, value, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: Text(
                    value > 0 ? '$value' : l10n.mpLobbyGo,
                    key: ValueKey<int>(value),
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: value > 0 ? Colors.white : theme.foodColor,
                      shadows: [
                        Shadow(
                          color: value > 0
                              ? theme.accentColor
                              : theme.foodColor,
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  value > 0 ? l10n.mpLobbyGetReady : '',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Matches the SettingsScreen / ProfileScreen header: back button in a
  /// bordered box, tracked accent title. This screen built its own bare
  /// IconButton next to a two-line block, so the back affordance sat at a
  /// different size and position from every other screen in the app.
  Widget _buildHeader(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 + context.sideInset(),
        12,
        16 + context.sideInset(),
        8,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded, color: theme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.mpLobbyTitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                    letterSpacing: context.letterSpacing(2),
                  ),
                ),
                Text(
                  l10n.mpLobbySubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Eyebrow + hairline card, identical to SettingsScreen and ProfileScreen.
  Widget _mpSection({
    required GameTheme theme,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: arcadeSurface(
            theme,
            borderRadius: BorderRadius.circular(16),
            borderColor: theme.accentColor.withValues(alpha: 0.32),
          ),
          child: HudCorners(
            color: theme.accentColor,
            inset: 10,
            child: child,
          ),
        ),
      ],
    );
  }

  /// The primary action of a section. Full width, theme accent, 48dp — sized
  /// like an action rather than the 56dp slab-with-glow this screen used, in
  /// three different off-theme colours.
  Widget _mpPrimaryButton({
    required GameTheme theme,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return GradientButton(
      onPressed: onPressed,
      text: label,
      primaryColor: theme.accentColor,
      secondaryColor: theme.foodColor,
      icon: icon,
      width: double.infinity,
      height: 48,
    );
  }

  Widget _mpSectionBlurb(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 13.5,
        height: 1.35,
      ),
    );
  }

  /// Room header. Same shape as [_buildHeader] — bordered back box, tracked
  /// accent title — so leaving a room feels like leaving any other screen.
  /// The title is the room, not the mode: the mode card right below it already
  /// names the mode, and printing it twice told the player nothing new.
  Widget _buildGameHeader(GameTheme theme, MultiplayerGame game) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 + context.sideInset(),
        12,
        16 + context.sideInset(),
        8,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              onPressed: () {
                context.read<MultiplayerCubit>().leaveGame();
                context.pop();
              },
              icon: Icon(Icons.arrow_back_rounded, color: theme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.mpLobbyTitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                    letterSpacing: context.letterSpacing(2),
                  ),
                ),
                if (game.roomCode != null)
                  Text(
                    l10n.mpLobbyRoomCode(game.roomCode!),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: context.letterSpacing(1),
                    ),
                  ),
              ],
            ),
          ),
          if (game.roomCode != null) ...[
            _headerAction(
              theme: theme,
              icon: Icons.copy_rounded,
              tooltip: l10n.mpLobbyRoomCodeCopied,
              onTap: () {
                Clipboard.setData(ClipboardData(text: game.roomCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.mpLobbyRoomCodeCopied),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            // Ping a friend with this room code — their push deep-links
            // straight into the room.
            _headerAction(
              theme: theme,
              icon: Icons.person_add_alt_1_rounded,
              tooltip: l10n.mpLobbyInviteFriendTo(game.roomCode!),
              onTap: () => _showInviteFriendSheet(theme, game.roomCode!),
            ),
          ],
        ],
      ),
    );
  }

  /// Trailing header icon in the same bordered box as the back button, so the
  /// row reads as one control strip rather than a title with loose icons
  /// hanging off a pill.
  Widget _headerAction({
    required GameTheme theme,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        icon: Icon(icon, color: theme.accentColor),
      ),
    );
  }

  Widget _buildQuickMatchSection(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _mpSection(
      theme: theme,
      title: l10n.mpLobbyQuickMatch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1v1 classic only in this release — the server match engine
          // enforces exactly two players, so no mode/count selectors.
          _mpSectionBlurb(l10n.mpLobbyQuickMatchSubtitle),
          const SizedBox(height: 16),
          _mpPrimaryButton(
            theme: theme,
            icon: Icons.search_rounded,
            label: multiplayerState.isLoading
                ? l10n.mpLobbyFinding
                : l10n.mpLobbyFindMatch,
            onPressed: multiplayerState.isLoading
                ? null
                : () {
                    context.read<MultiplayerCubit>().quickMatch(
                      MultiplayerGameMode.classic,
                      playerCount: 2,
                    );
                  },
          ),
        ],
      ),
    ).gameEntrance(delay: 100.ms);
  }

  Widget _buildMatchmakingUI(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final elapsed = multiplayerState.matchmakingElapsedSeconds;
    // The number COUNTS UP, and the ring fills toward the deadline the server
    // promised rather than a number the client invented.
    //
    // It used to count down, which meant that whenever anything ran past the
    // deadline the screen sat on a motionless "0 SEC" inside an empty ring —
    // indistinguishable from a hung app, and reported as one. A rising count
    // cannot freeze, and it never promises an ending the client is not the
    // one to decide.
    final deadline = multiplayerState.matchmakingDeadlineSeconds;
    final progress = deadline <= 0 ? 1.0 : (elapsed / deadline).clamp(0.0, 1.0);
    // Countdown runs down to zero in the theme accent throughout. It used to
    // switch green → orange under ten seconds, which reads as "something is
    // wrong" when in fact the search is simply nearly over.
    return Column(
      children: [
        _buildHeader(theme),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 + context.sideInset(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: HudCorners(
                    color: theme.accentColor,
                    inset: 8,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 108,
                            height: 108,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              backgroundColor: theme.accentColor.withValues(
                                alpha: 0.15,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.accentColor,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$elapsed',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                l10n.mpLobbySeconds.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  letterSpacing: context.letterSpacing(1.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        l10n.mpLobbySearching,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                          letterSpacing: context.letterSpacing(1.5),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        l10n.mpLobbyModePlayers(
                          multiplayerState.matchmakingPlayerCount ?? 2,
                          multiplayerState.matchmakingMode?.localizedName(
                                l10n,
                              ) ??
                              l10n.mpModeClassicBattle,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),

                      if (multiplayerState.matchmakingQueuePosition > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.mpLobbyQueuePosition(
                            multiplayerState.matchmakingQueuePosition,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      GradientButton(
                        onPressed: () {
                          context.read<MultiplayerCubit>().cancelMatchmaking();
                        },
                        text: l10n.mpLobbyCancelUpper,
                        primaryColor: theme.accentColor,
                        secondaryColor: theme.foodColor,
                        icon: Icons.close_rounded,
                        width: double.infinity,
                        height: 48,
                        outlined: true,
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchmakingUnreachableUI(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildHeader(theme),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 + context.sideInset(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: HudCorners(
                    color: theme.accentColor,
                    inset: 8,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Empty queue is an outcome, not a failure — so no
                      // orange alarm disc, just the same quiet hairline
                      // treatment the rest of the screen uses.
                      Icon(
                        Icons.hourglass_empty_rounded,
                        size: 36,
                        color: theme.accentColor.withValues(alpha: 0.8),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        l10n.mpLobbyUnreachableTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                          letterSpacing: context.letterSpacing(1.5),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        l10n.mpLobbyUnreachableBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 24),

                      GradientButton(
                        onPressed: () {
                          context
                              .read<MultiplayerCubit>()
                              .clearMatchmakingTimeout();
                          context.read<MultiplayerCubit>().quickMatch(
                            multiplayerState.matchmakingMode ??
                                MultiplayerGameMode.classic,
                            playerCount:
                                multiplayerState.matchmakingPlayerCount ?? 2,
                          );
                        },
                        text: l10n.mpLobbyTryAgain,
                        primaryColor: theme.accentColor,
                        secondaryColor: theme.foodColor,
                        icon: Icons.refresh_rounded,
                        width: double.infinity,
                        height: 48,
                      ),

                      const SizedBox(height: 10),

                      GradientButton(
                        onPressed: () {
                          context
                              .read<MultiplayerCubit>()
                              .clearMatchmakingTimeout();
                        },
                        text: l10n.mpLobbyGoBack,
                        primaryColor: theme.accentColor,
                        secondaryColor: theme.foodColor,
                        icon: Icons.arrow_back_rounded,
                        width: double.infinity,
                        height: 48,
                        outlined: true,
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Lifetime record: wins, losses, draws, rating.
  ///
  /// Present from the first frame, whatever the network is doing. It used to
  /// be gated on the fetch having returned, so the strip materialised a
  /// second after the screen did and shoved Quick Match, Join and Create down
  /// the page — the reader's eye was already on a button that moved out from
  /// under it. Offline it never arrived at all, which left the screen looking
  /// like it had forgotten the mode exists.
  ///
  /// So the shape is fixed and only the contents change: four cells, always,
  /// with placeholders where the numbers will be. Nothing below it can move,
  /// because nothing about it moves.
  Widget _buildRecordStrip(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;

    String? valueOf(String key, {int? fallback}) {
      if (_recordLoading) return null;
      final raw = (_record?[key] as num?)?.toInt();
      if (raw != null) return '$raw';
      // Fetched and unavailable — offline, or the call failed. A dash says
      // "not known" honestly; a zero would be a claim about your record.
      return fallback == null ? '—' : '$fallback';
    }

    // Label above value, same cell as the profile statistics grid. An earlier
    // strip gave each figure its own tinted pill in its own colour — green
    // wins, red losses, orange draws — so a record of 0–0 lit up like a
    // warning panel. A record is a set of numbers, not a set of alerts.
    Widget cell(String label, String? value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: context.letterSpacing(0.8),
              ),
            ),
            const SizedBox(height: 4),
            // Same height whether it holds a number or a placeholder, so the
            // swap when the fetch lands is a cross-fade and not a reflow.
            SizedBox(
              height: 26,
              child: value == null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Container(
                                width: 34,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .fade(begin: 0.45, end: 1.0, duration: 700.ms),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ).animate().fadeIn(duration: 220.ms),
                    ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: HudCorners(
        color: theme.accentColor,
        inset: 7,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(l10n.mpLobbyWinsLabel, valueOf('wins')),
          cell(l10n.mpLobbyLossesLabel, valueOf('losses')),
          // Draws used to appear only when there were any, which moved the
          // other three columns sideways the moment a draw was recorded.
          // Four columns, always.
          cell(l10n.mpLobbyDrawsLabel, valueOf('draws')),
          cell(l10n.mpLobbyRatingLabel, valueOf('rating', fallback: 1000)),
        ],
      )),
    ).gameEntrance(delay: 50.ms);
  }

  Widget _buildJoinGameSection(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _mpSection(
      theme: theme,
      title: l10n.mpLobbyJoinRoom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // No blurb here: the field's own placeholder already says to enter
          // a room code, and printing it twice above the box that asks for it
          // is the kind of padding that made this screen scroll.
          TextField(
            controller: _roomCodeController,
            decoration: InputDecoration(
              hintText: l10n.mpLobbyEnterRoomCode,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: context.letterSpacing(1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.accentColor.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.accentColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.accentColor, width: 2),
              ),
              filled: true,
              fillColor: theme.backgroundColor.withValues(alpha: 0.5),
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              // Codes are read and typed character by character, so give them
              // room to breathe rather than setting them as prose.
              letterSpacing: context.letterSpacing(4),
            ),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          // Secondary to quick match, like Create Room — you only reach for it
          // once you already have a code in hand.
          GradientButton(
            onPressed:
                multiplayerState.isLoading || _roomCodeController.text.isEmpty
                ? null
                : () {
                    context.read<MultiplayerCubit>().joinGame(
                      _roomCodeController.text.trim(),
                    );
                  },
            text: l10n.mpLobbyJoinRoom,
            primaryColor: theme.accentColor,
            secondaryColor: theme.foodColor,
            icon: Icons.login_rounded,
            width: double.infinity,
            height: 48,
            outlined: true,
          ),
        ],
      ),
    ).gameEntrance(delay: 150.ms);
  }

  Widget _buildCreateGameSection(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _mpSection(
      theme: theme,
      title: l10n.mpLobbyCreateRoom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Classic 1v1 room — share the code (or ping a friend from the
          // room header) to fill the second slot. No mode picker: the
          // server engine only runs classic 1v1 in this release.
          _mpSectionBlurb(l10n.mpLobbyCreateSubtitle),
          const SizedBox(height: 16),
          // Outlined, not filled: quick match is what most players want, and
          // three equally-weighted buttons gave no clue which to press.
          GradientButton(
            onPressed: multiplayerState.isLoading
                ? null
                : () {
                    context.read<MultiplayerCubit>().createGame(
                      mode: MultiplayerGameMode.classic,
                      maxPlayers: 2,
                    );
                  },
            text: l10n.mpLobbyCreateRoom,
            primaryColor: theme.accentColor,
            secondaryColor: theme.foodColor,
            icon: Icons.add_circle_outline_rounded,
            width: double.infinity,
            height: 48,
            outlined: true,
          ),
        ],
      ),
    ).gameEntrance(delay: 200.ms);
  }

  Widget _buildGameModeCard(GameTheme theme, MultiplayerGame game) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
      ),
      child: HudCorners(
        color: theme.accentColor,
        inset: 7,
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(game.modeEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.mode.localizedName(l10n),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getGameModeDescription(game.mode),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildPlayersSection(
    GameTheme theme,
    MultiplayerGame game,
    AuthState authState,
  ) {
    final players = game.players.toList();
    return _mpSection(
      theme: theme,
      title: AppLocalizations.of(
        context,
      )!.mpLobbyPlayersHeader(players.length, game.maxPlayers),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < players.length; i++) ...[
            if (i > 0) _mpHairline(theme),
            _buildPlayerItem(theme, players[i], authState),
          ],
          if (!game.isFull) ...[
            if (players.isNotEmpty) _mpHairline(theme),
            _buildWaitingSlot(theme),
          ],
        ],
      ),
    );
  }

  /// Divider between rows inside a section card — the same 1px rule the
  /// settings and profile screens use, instead of stacked mini-cards.
  Widget _mpHairline(GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 1,
        color: theme.accentColor.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _buildPlayerItem(
    GameTheme theme,
    MultiplayerPlayer player,
    AuthState authState,
  ) {
    final currentUserId = authState.userId;
    final isCurrentUser = currentUserId == player.userId;

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: player.photoUrl != null
              ? NetworkImage(player.photoUrl!)
              : null,
          onBackgroundImageError: player.photoUrl != null ? (e, s) {} : null,
          backgroundColor: theme.accentColor.withValues(alpha: 0.15),
          child: player.photoUrl == null
              ? Icon(Icons.person, color: theme.accentColor, size: 20)
              : null,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      player.publicLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.mpLobbyYouBadge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                        letterSpacing: context.letterSpacing(1),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getStatusColor(theme, player.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusText(player.status),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingSlot(GameTheme theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          child: Icon(
            Icons.person_add_alt_rounded,
            color: Colors.white.withValues(alpha: 0.35),
            size: 18,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            AppLocalizations.of(context)!.mpLobbyWaitingForPlayer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyActions(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
    MultiplayerGame game,
    AuthState authState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = authState.userId;
    final currentPlayer = game.getPlayer(currentUserId ?? '');
    final isReady = currentPlayer?.status == PlayerStatus.ready;
    final isHost = currentPlayer?.rank == 0; // PlayerIndex 0 is host
    final allPlayersReady =
        game.players.isNotEmpty &&
        game.players.every((p) => p.status == PlayerStatus.ready);
    final canStartGame = isHost && allPlayersReady && game.players.length >= 2;

    // Only a matchmade lobby expires — see MultiplayerState.readyDeadlineSeconds.
    final readyDeadline = multiplayerState.isMatchmadeLobby
        ? multiplayerState.readyDeadlineSeconds
        : null;
    // The state worth calling out: you have confirmed, they have not. Without
    // it a matchmade lobby just sits there and reads as broken.
    final waitingOnOpponent =
        isReady && !allPlayersReady && game.players.length >= 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ready-check deadline. Present only while the check is genuinely
        // outstanding: once everyone is ready the room is committed and a
        // ticking clock would read as a threat to a match that is about to
        // start anyway.
        if (readyDeadline != null && !allPlayersReady) ...[
          // Turns amber for the last ten seconds. Colour is not the only
          // signal — the number itself is right there.
          _statusNote(
            theme: theme,
            color: readyDeadline <= 10 ? Colors.amber : theme.accentColor,
            text: l10n.mpLobbyReadyDeadline(readyDeadline),
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 10),
        ],

        // You are ready, they are not.
        if (waitingOnOpponent) ...[
          _statusNote(
            theme: theme,
            color: theme.accentColor,
            text: l10n.mpLobbyWaitingOpponentReady,
            busy: true,
          ),
          const SizedBox(height: 10),
        ],

        // Show waiting message for non-host when all ready
        if (!isHost && allPlayersReady && game.players.length >= 2) ...[
          _statusNote(
            theme: theme,
            color: theme.accentColor,
            text: l10n.mpLobbyWaitingForHost,
            busy: true,
          ),
          const SizedBox(height: 10),
        ],

        // Show Start Game button for host when all players are ready
        if (canStartGame) ...[
          GradientButton(
            onPressed: multiplayerState.isLoading
                ? null
                : () {
                    context.read<MultiplayerCubit>().startGame();
                  },
            text: l10n.mpLobbyStartGame,
            primaryColor: theme.accentColor,
            secondaryColor: theme.foodColor,
            icon: Icons.play_arrow_rounded,
            width: double.infinity,
            height: 48,
          ),
          const SizedBox(height: 10),
        ],

        // Ready is the action to take; leaving is the way out. Giving both the
        // same weight in a split row (and painting Leave red, as if quitting a
        // lobby were dangerous) made the choice harder than it is.
        GradientButton(
          // Toggle: tapping while ready un-readies (SetReady carries the
          // bool; the button used to lock once pressed).
          onPressed: multiplayerState.isLoading
              ? null
              : () {
                  context.read<MultiplayerCubit>().markPlayerReady(
                    isReady: !isReady,
                  );
                },
          text: isReady ? l10n.mpLobbyReadyDone : l10n.mpLobbyReady,
          primaryColor: theme.accentColor,
          secondaryColor: theme.foodColor,
          icon: isReady
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
          width: double.infinity,
          height: 48,
          // Confirmed state goes quiet: the filled button is the thing still
          // asking to be pressed.
          outlined: isReady,
        ),

        const SizedBox(height: 10),

        TextButton.icon(
          onPressed: () {
            context.read<MultiplayerCubit>().leaveGame();
            context.pop();
          },
          icon: Icon(
            Icons.exit_to_app_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          label: Text(
            l10n.mpLobbyLeave,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: context.letterSpacing(1),
            ),
          ),
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        ),
      ],
    );
  }

  /// One-line status note under the room. Full-width hairline strip rather
  /// than a centred tinted pill, so consecutive notes stack into a column
  /// instead of a ragged pile of differently-sized lozenges.
  Widget _statusNote({
    required GameTheme theme,
    required Color color,
    required String text,
    IconData? icon,
    bool busy = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (busy)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else if (icon != null)
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGameModeDescription(MultiplayerGameMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case MultiplayerGameMode.classic:
        return l10n.mpModeClassicDesc;
      case MultiplayerGameMode.speedRun:
        return l10n.mpModeSpeedDesc;
      case MultiplayerGameMode.survival:
        return l10n.mpModeSurvivalDesc;
      case MultiplayerGameMode.powerUpMadness:
        return l10n.mpModePowerUpDesc;
    }
  }

  /// Status dot colour. Waiting is the normal state of a fresh room, so it
  /// stays neutral instead of the amber it used to get — only a crash or a
  /// dropped connection is worth flagging.
  Color _getStatusColor(GameTheme theme, PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return Colors.white.withValues(alpha: 0.45);
      case PlayerStatus.ready:
        return theme.foodColor;
      case PlayerStatus.playing:
        return theme.accentColor;
      case PlayerStatus.crashed:
        return Colors.redAccent;
      case PlayerStatus.disconnected:
        return Colors.white.withValues(alpha: 0.25);
    }
  }

  String _getStatusText(PlayerStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case PlayerStatus.waiting:
        return l10n.mpStatusWaiting;
      case PlayerStatus.ready:
        return l10n.mpStatusReady;
      case PlayerStatus.playing:
        return l10n.mpStatusPlaying;
      case PlayerStatus.crashed:
        return l10n.mpStatusCrashed;
      case PlayerStatus.disconnected:
        return l10n.mpStatusDisconnected;
    }
  }
}
