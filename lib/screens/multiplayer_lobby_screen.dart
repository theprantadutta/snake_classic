import 'package:flutter/material.dart';
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

      if (_connectivityService.isOnline) {
        _loadRecord();
      }
    });
  }

  Future<void> _loadRecord() async {
    final record = await ApiService().getMultiplayerRecord();
    if (mounted && record != null) {
      setState(() => _record = record);
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mpLobbyNoFriends),
        ),
      );
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
        final (sent, message) = await SocialService()
            .pingFriendForMatch(friend.uid, roomCode: roomCode);
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sent
                  ? l10n.mpLobbyInviteSent(friend.displayName)
                  : (message ?? l10n.mpLobbyInviteFailed),
            ),
            backgroundColor:
                sent ? Colors.green.shade700 : Colors.red.shade700,
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
              prev.errorMessage != curr.errorMessage &&
              curr.errorMessage != null,
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
                        state.errorMessage!,
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
                        child: multiplayerState.matchmakingTimedOut
                            ? _buildMatchmakingTimeoutUI(
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
                // Lifetime VS record (renders only once loaded)
                if (_record != null) ...[
                  _buildRecordStrip(theme),
                  const SizedBox(height: 20),
                ],

                // Quick Match Section
                _buildQuickMatchSection(context, multiplayerState, theme),

                const SizedBox(height: 32),

                // Join Game Section
                _buildJoinGameSection(context, multiplayerState, theme),

                const SizedBox(height: 32),

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
                      color: value > 0 ? Colors.white : Colors.green,
                      shadows: [
                        Shadow(
                          color: value > 0 ? theme.accentColor : Colors.green,
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

  Widget _buildHeader(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20 + context.sideInset(),
        20,
        20 + context.sideInset(),
        20,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: 24),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.mpLobbyTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.accentColor,
                  letterSpacing: 2,
                ),
              ).gameEntrance(),

              Text(
                l10n.mpLobbySubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.accentColor.withValues(alpha: 0.7),
                ),
              ).gameEntrance(delay: 100.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader(GameTheme theme, MultiplayerGame game) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20 + context.sideInset(),
        20,
        20 + context.sideInset(),
        20,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<MultiplayerCubit>().leaveGame();
              context.pop();
            },
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.mode.localizedName(l10n),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.accentColor,
                  ),
                ),

                if (game.roomCode != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.foodColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.foodColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.key, size: 16, color: theme.foodColor),
                        const SizedBox(width: 6),
                        Text(
                          l10n.mpLobbyRoomCode(game.roomCode ?? ''),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.foodColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: game.roomCode!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.mpLobbyRoomCodeCopied),
                                backgroundColor: theme.foodColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: theme.foodColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Ping a friend with this room code — their push
                        // deep-links straight into the room.
                        GestureDetector(
                          onTap: () =>
                              _showInviteFriendSheet(theme, game.roomCode!),
                          child: Icon(
                            Icons.person_add_alt_1,
                            size: 15,
                            color: theme.foodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMatchSection(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.flash_on, size: 40, color: Colors.green),

          const SizedBox(height: 16),

          Text(
            l10n.mpLobbyQuickMatch,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          // 1v1 classic only in this release — the server match engine
          // enforces exactly two players, so no mode/count selectors.
          Text(
            l10n.mpLobbyQuickMatchSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 20),

          GradientButton(
            onPressed: multiplayerState.isLoading
                ? null
                : () {
                    context.read<MultiplayerCubit>().quickMatch(
                      MultiplayerGameMode.classic,
                      playerCount: 2,
                    );
                  },
            text: multiplayerState.isLoading
                ? l10n.mpLobbyFinding
                : l10n.mpLobbyFindMatch,
            primaryColor: Colors.green,
            secondaryColor: Colors.green.withValues(alpha: 0.8),
            icon: Icons.search,
          ),
        ],
      ),
    ).gameZoomIn(delay: 100.ms);
  }

  Widget _buildMatchmakingUI(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final elapsed = multiplayerState.matchmakingElapsedSeconds;
    final remaining = 60 - elapsed;
    final progress = elapsed / 60.0;

    return Column(
      children: [
        _buildHeader(theme),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.15),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated search indicator with timer
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 1 - progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            remaining <= 10 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$remaining',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: remaining <= 10
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          Text(
                            l10n.mpLobbySeconds,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.accentColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    l10n.mpLobbySearching,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.mpLobbyModePlayers(
                      multiplayerState.matchmakingPlayerCount ?? 2,
                      multiplayerState.matchmakingMode?.localizedName(l10n) ??
                          l10n.mpModeClassicBattle,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.accentColor.withValues(alpha: 0.7),
                    ),
                  ),

                  if (multiplayerState.matchmakingQueuePosition > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.mpLobbyQueuePosition(
                        multiplayerState.matchmakingQueuePosition,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  GradientButton(
                    onPressed: () {
                      context.read<MultiplayerCubit>().cancelMatchmaking();
                    },
                    text: l10n.mpLobbyCancelUpper,
                    primaryColor: Colors.red,
                    secondaryColor: Colors.red.withValues(alpha: 0.8),
                    icon: Icons.close,
                    outlined: true,
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchmakingTimeoutUI(
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
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.15),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timeout icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    l10n.mpLobbyNoPlayersFound,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.mpLobbyNoPlayersBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.accentColor.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          onPressed: () {
                            context
                                .read<MultiplayerCubit>()
                                .clearMatchmakingTimeout();
                          },
                          text: l10n.mpLobbyGoBack,
                          primaryColor: Colors.grey,
                          secondaryColor: Colors.grey.withValues(alpha: 0.8),
                          icon: Icons.arrow_back,
                          outlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
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
                          primaryColor: Colors.green,
                          secondaryColor: Colors.green.withValues(alpha: 0.8),
                          icon: Icons.refresh,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ],
    );
  }

  /// Compact lifetime record chip row: "W · L · D" plus rating.
  Widget _buildRecordStrip(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final wins = (_record?['wins'] as num?)?.toInt() ?? 0;
    final losses = (_record?['losses'] as num?)?.toInt() ?? 0;
    final draws = (_record?['draws'] as num?)?.toInt() ?? 0;
    final rating = (_record?['rating'] as num?)?.toInt() ?? 1000;

    Widget chip(IconData icon, Color color, String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chip(
          Icons.emoji_events,
          Colors.green,
          l10n.mpLobbyWinsChip(wins),
        ),
        const SizedBox(width: 10),
        chip(
          Icons.close,
          Colors.red.shade400,
          l10n.mpLobbyLossesChip(losses),
        ),
        if (draws > 0) ...[
          const SizedBox(width: 10),
          chip(Icons.handshake, Colors.orange, l10n.mpLobbyDrawsChip(draws)),
        ],
        const SizedBox(width: 10),
        chip(Icons.military_tech, theme.accentColor, '$rating'),
      ],
    ).gameZoomIn(delay: 100.ms);
  }

  Widget _buildJoinGameSection(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.15),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.meeting_room, size: 40, color: Colors.blue),

          const SizedBox(height: 16),

          Text(
            l10n.mpLobbyJoinRoom,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.mpLobbyJoinSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _roomCodeController,
            decoration: InputDecoration(
              hintText: l10n.mpLobbyEnterRoomCode,
              hintStyle: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: theme.backgroundColor.withValues(alpha: 0.5),
            ),
            style: TextStyle(color: theme.accentColor),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 16),

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
            primaryColor: Colors.blue,
            secondaryColor: Colors.blue.withValues(alpha: 0.8),
            icon: Icons.login,
          ),
        ],
      ),
    ).gameZoomIn(delay: 200.ms);
  }

  Widget _buildCreateGameSection(
    BuildContext context,
    MultiplayerState multiplayerState,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle, size: 40, color: Colors.purple),

          const SizedBox(height: 16),

          Text(
            l10n.mpLobbyCreateRoom,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          // Classic 1v1 room — share the code (or ping a friend from the
          // room header) to fill the second slot. No mode picker: the
          // server engine only runs classic 1v1 in this release.
          Text(
            l10n.mpLobbyCreateSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 20),

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
            primaryColor: Colors.purple,
            secondaryColor: Colors.purple.withValues(alpha: 0.8),
            icon: Icons.add_circle_outline,
          ),
        ],
      ),
    ).gameZoomIn(delay: 300.ms);
  }

  Widget _buildGameModeCard(GameTheme theme, MultiplayerGame game) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(game.modeEmoji, style: const TextStyle(fontSize: 32)),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.mode.localizedName(l10n),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getGameModeDescription(game.mode),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.accentColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection(
    GameTheme theme,
    MultiplayerGame game,
    AuthState authState,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(
              context,
            )!.mpLobbyPlayersHeader(game.players.length, game.maxPlayers),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.accentColor.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 16),

          ...game.players.map(
            (player) => _buildPlayerItem(theme, player, authState),
          ),

          if (!game.isFull) _buildWaitingSlot(theme),
        ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.accentColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: theme.accentColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: player.photoUrl != null
                ? NetworkImage(player.photoUrl!)
                : null,
            onBackgroundImageError: player.photoUrl != null ? (e, s) {} : null,
            backgroundColor: theme.accentColor.withValues(alpha: 0.2),
            child: player.photoUrl == null
                ? Icon(Icons.person, color: theme.accentColor, size: 24)
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.publicLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.mpLobbyYouBadge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(player.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(player.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.accentColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingSlot(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            child: Icon(Icons.person_add, color: Colors.grey, size: 24),
          ),

          const SizedBox(width: 12),

          Text(
            AppLocalizations.of(context)!.mpLobbyWaitingForPlayer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show Start Game button for host when all players are ready
        if (canStartGame) ...[
          GradientButton(
            onPressed: multiplayerState.isLoading
                ? null
                : () {
                    context.read<MultiplayerCubit>().startGame();
                  },
            text: l10n.mpLobbyStartGame,
            primaryColor: Colors.green,
            secondaryColor: Colors.green.shade700,
            icon: Icons.play_arrow,
          ),
          const SizedBox(height: 12),
        ],

        // Show waiting message for non-host when all ready
        if (!isHost && allPlayersReady && game.players.length >= 2) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.mpLobbyWaitingForHost,
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            Expanded(
              child: GradientButton(
                onPressed: () {
                  context.read<MultiplayerCubit>().leaveGame();
                  context.pop();
                },
                text: l10n.mpLobbyLeave,
                primaryColor: Colors.red,
                secondaryColor: Colors.red.withValues(alpha: 0.8),
                icon: Icons.exit_to_app,
                outlined: true,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: GradientButton(
                // Toggle: tapping while ready un-readies (SetReady carries
                // the bool; the button used to lock once pressed).
                onPressed: multiplayerState.isLoading
                    ? null
                    : () {
                        context.read<MultiplayerCubit>().markPlayerReady(
                          isReady: !isReady,
                        );
                      },
                text: isReady ? l10n.mpLobbyReadyDone : l10n.mpLobbyReady,
                primaryColor: isReady ? Colors.green : theme.accentColor,
                secondaryColor: isReady
                    ? Colors.green.withValues(alpha: 0.8)
                    : theme.foodColor,
                icon: isReady ? Icons.check : Icons.check_circle,
              ),
            ),
          ],
        ),
      ],
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

  Color _getStatusColor(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return Colors.orange;
      case PlayerStatus.ready:
        return Colors.green;
      case PlayerStatus.playing:
        return Colors.blue;
      case PlayerStatus.crashed:
        return Colors.red;
      case PlayerStatus.disconnected:
        return Colors.grey;
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
