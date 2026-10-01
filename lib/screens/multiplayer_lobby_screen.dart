import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/versus/versus_widgets.dart';
import 'package:snake_classic/services/multiplayer/matchmaking_watch.dart';

/// Versus lobby (Living Board renders 17 and 18): the record strip, quick
/// match, join-by-code, create room and the room itself with its ready
/// check. Presentation only — every action goes through [MultiplayerCubit].
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

  /// Longest ready-check deadline seen in this room — the full width of the
  /// READY CHECK cell bar. The cubit counts down from its own constant; the
  /// bar measures against the first value it reports rather than a copy of
  /// that constant.
  int _readyCheckTotal = 0;

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
  Future<void> _showInviteFriendSheet(String roomCode) async {
    final friends = await SocialService().getFriends();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (friends.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(arcadeSnackBar(context, message: l10n.mpLobbyNoFriends));
      return;
    }
    showLBSheet<void>(
      context: context,
      subtitle: l10n.mpLobbyInviteFriendTo(roomCode),
      builder: (sheetContext) => ListView.builder(
        shrinkWrap: true,
        itemCount: friends.length,
        itemBuilder: (_, i) => _inviteFriendTile(sheetContext, friends[i], roomCode),
      ),
    );
  }

  Widget _inviteFriendTile(
    BuildContext sheetContext,
    UserProfile friend,
    String roomCode,
  ) {
    final p = context.lb;
    return LBBlock(
      semanticLabel: friend.displayName,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () async {
        Navigator.of(sheetContext).pop();
        final (sent, message) = await SocialService().pingFriendForMatch(
          friend.uid,
          roomCode: roomCode,
        );
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: sent
                ? l10n.mpLobbyInviteSent(friend.displayName)
                : (message ?? l10n.mpLobbyInviteFailed),
            tone: sent ? ArcadeSnackTone.success : ArcadeSnackTone.error,
          ),
        );
      },
      child: Row(
        children: [
          LBPixelIcon(LBIcon.user, cell: 3, color: p.lime),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              friend.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.button(p, color: p.ink, size: 13.5).copyWith(letterSpacing: .4),
            ),
          ),
          const SizedBox(width: 10),
          const LBPixelIcon(LBIcon.invite, cell: 3, color: LB.gold),
        ],
      ),
    );
  }

  void _onConnectivityChanged() {
    // Trigger rebuild when connectivity changes
    if (mounted) setState(() {});
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: AppLocalizations.of(context)!.mpLobbyOffline,
        icon: Icons.cloud_off,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerCubit, MultiplayerState>(
      listenWhen: (prev, curr) =>
          prev.errorCode != curr.errorCode && curr.errorCode != null,
      listener: (context, state) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: state.errorCode!.localizedMessage(
              AppLocalizations.of(context)!,
            ),
            tone: ArcadeSnackTone.error,
            // No dismiss button any more. It existed only to close the
            // snack bar, which swiping and the timeout already do, and it
            // was the source of a crash: the callback reached through the
            // lobby's context, and an app-level snack bar outlives the
            // screen that showed it — this one replaces itself with the
            // game screen the moment a match starts. 40 crashes, 27 users.
            //
            // arcadeSnackBar's own action resolves the messenger from a
            // context inside the snack bar, so an action here would be
            // safe. There just is not one worth showing.
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

              final Widget content = multiplayerState.matchmakingUnreachable
                  ? _buildMatchmakingUnreachableUI(context, multiplayerState)
                  : multiplayerState.status == MultiplayerStatus.inMatchmaking
                  ? _buildMatchmakingUI(context, multiplayerState)
                  : multiplayerState.isInGame
                  ? _buildGameLobby(context, multiplayerState, authState)
                  : _buildMainLobby(context, multiplayerState);

              return Scaffold(
                backgroundColor: context.lb.board,
                bottomNavigationBar: const LBBannerSlot(),
                body: LBGridBackground(
                  child: Stack(
                    children: [
                      SafeArea(bottom: false, child: content),

                      // The start countdown scrim sits OUTSIDE the
                      // SafeArea so it covers the status-bar and
                      // nav-bar strips too. Inside, those strips
                      // showed the lobby through an un-dimmed band.
                      if (multiplayerState.currentGame?.status ==
                          MultiplayerGameStatus.starting)
                        Positioned.fill(
                          child: VersusCountdownOverlay(
                            seconds: multiplayerState.countdownSeconds,
                            goLabel: AppLocalizations.of(context)!.mpLobbyGo,
                            getReadyLabel: AppLocalizations.of(context)!.mpLobbyGetReady,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// The lobby header (render 17): back block, VERSUS in cells, subtitle.
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return LBHeader(
      title: l10n.lbVersusTitle,
      subtitle: l10n.lbVersusSubtitle,
      onBack: () => context.pop(),
    );
  }

  /// A column of blocks under the header, on the content gutter. It fills
  /// the screen and scrolls only when it must: [Spacer]s between groups take
  /// up whatever height a taller phone has, so the blocks spread out instead
  /// of leaving an empty band under the last one; on a short phone they
  /// collapse to nothing and the column scrolls.
  Widget _blockList(List<Widget> children) {
    final g = context.lbGutter;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  /// A gap between block groups: [min] always, plus a share of any spare
  /// height.
  List<Widget> _flexGap({double min = 0}) => [
    if (min > 0) SizedBox(height: min),
    const Spacer(),
  ];

  Widget _buildMainLobby(
    BuildContext context,
    MultiplayerState multiplayerState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: _blockList([
            // Lifetime VS record. Always in the tree — it used to be
            // gated on the fetch having returned, so the whole screen
            // jumped down a strip's height when the network answered, and
            // offline it never appeared at all.
            _buildRecordStrip(),
            ..._flexGap(min: context.lbCell * .9),
            _buildQuickMatchSection(context, multiplayerState),
            ..._flexGap(min: 2),
            _buildJoinGameSection(context, multiplayerState),
            _buildCreateGameSection(context, multiplayerState),
            ..._flexGap(min: 2),
            _buildHouseSnakeNote().gameEntrance(delay: 250.ms),
            _buildTournamentsLink().gameEntrance(delay: 300.ms),
          ]),
        ),
      ],
    );
  }

  Widget _buildGameLobby(
    BuildContext context,
    MultiplayerState multiplayerState,
    AuthState authState,
  ) {
    final game = multiplayerState.currentGame!;
    final g = context.lbGutter;
    final cell = context.lbCell;

    // The start countdown scrim is mounted by build(), above the
    // SafeArea, so it can cover the inset strips.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with room info
        _buildGameHeader(game),

        // Game info and players, actions pinned to the bottom when there
        // is room and scrolled to when there is not.
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(g, cell * .9, g, cell * .6),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (game.roomCode != null) ...[
                        VersusCodeCells(code: game.roomCode!),
                        SizedBox(height: cell * .9),
                        const Spacer(),
                      ],

                      // Game mode info
                      _buildGameModeCard(game),

                      SizedBox(height: cell * .9),

                      // Players list
                      _buildPlayersSection(game, authState),

                      SizedBox(height: cell),
                      const Spacer(flex: 2),

                      // Ready/Leave buttons
                      _buildLobbyActions(
                        context,
                        multiplayerState,
                        game,
                        authState,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Room header (render 18): back block (leaves the room), ROOM in cells,
  /// copy-code and invite-a-friend actions. The title is the room, not the
  /// mode: the mode card right below it already names the mode.
  Widget _buildGameHeader(MultiplayerGame game) {
    final l10n = AppLocalizations.of(context)!;
    return LBHeader(
      title: l10n.lbRoomTitle,
      subtitle: l10n.lbRoomSubtitle,
      onBack: () {
        context.read<MultiplayerCubit>().leaveGame();
        context.pop();
      },
      trailing: game.roomCode == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LBIconBlock(
                  icon: LBIcon.copy,
                  semanticLabel: l10n.mpLobbyRoomCodeCopied,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: game.roomCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      arcadeSnackBar(
                        context,
                        message: l10n.mpLobbyRoomCodeCopied,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                // Ping a friend with this room code — their push deep-links
                // straight into the room.
                LBIconBlock(
                  icon: LBIcon.invite,
                  semanticLabel: l10n.mpLobbyInviteFriendTo(game.roomCode!),
                  onTap: () => _showInviteFriendSheet(game.roomCode!),
                ),
              ],
            ),
    );
  }

  /// The loud block of a section: lime, one per screen (DESIGN_SPEC §1.3).
  Widget _fillAction({
    required String label,
    required LBIcon icon,
    required VoidCallback? onTap,
    double? height,
  }) {
    final p = context.lb;
    final block = LBBlock(
      kind: LBBlockKind.fill,
      height: height ?? context.lbCell * 2.6,
      alignment: Alignment.center,
      semanticLabel: label,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 3.4, color: p.onLime),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: LBText.button(p, color: p.onLime, size: 15).copyWith(letterSpacing: 3),
              ),
            ),
          ),
        ],
      ),
    );
    // Disabled while a request is in flight: same shape, visibly quiet.
    return onTap == null ? Opacity(opacity: .55, child: block) : block;
  }

  /// A quiet outline action with an icon (cancel, go back).
  Widget _outlineAction({
    required String label,
    required LBIcon icon,
    required VoidCallback? onTap,
  }) {
    final p = context.lb;
    return LBBlock(
      height: context.lbCell * 2.4,
      alignment: Alignment.center,
      semanticLabel: label,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 2.8, color: p.head),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.button(p, size: 12.5).copyWith(letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMatchSection(
    BuildContext context,
    MultiplayerState multiplayerState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.lbQuickMatch, style: LBText.label(p)),
          const SizedBox(height: 8),
          // 1v1 classic only in this release — the server match engine
          // enforces exactly two players, so no mode/count selectors.
          Text(l10n.lbQuickMatchLine, style: LBText.body(p, color: p.ink, size: 12)),
          const SizedBox(height: 14),
          _fillAction(
            icon: LBIcon.swords,
            label: multiplayerState.isLoading
                ? l10n.mpLobbyFinding
                : l10n.lbFindMatch,
            onTap: multiplayerState.isLoading
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
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final elapsed = multiplayerState.matchmakingElapsedSeconds;
    // The number COUNTS UP, and the cells fill toward the deadline the server
    // promised rather than a number the client invented.
    //
    // It used to count down, which meant that whenever anything ran past the
    // deadline the screen sat on a motionless "0 SEC" — indistinguishable
    // from a hung app, and reported as one. A rising count cannot freeze,
    // and it never promises an ending the client is not the one to decide.
    final deadline = multiplayerState.matchmakingDeadlineSeconds;
    final progress = deadline <= 0 ? 1.0 : (elapsed / deadline).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: _blockList([
            _buildRecordStrip(),
            ..._flexGap(min: context.lbCell * .9),
            LBBlock(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.lbQuickMatch, style: LBText.label(p)),
                  const SizedBox(height: 10),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.lbSearching('$elapsed'),
                      style: LBText.button(p, color: p.lime, size: 14).copyWith(
                        letterSpacing: 1.6,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.mpLobbyModePlayers(
                      multiplayerState.matchmakingPlayerCount ?? 2,
                      multiplayerState.matchmakingMode?.localizedName(l10n) ??
                          l10n.mpModeClassicBattle,
                    ),
                    style: LBText.body(p, size: 11.5),
                  ),
                  if (multiplayerState.matchmakingQueuePosition > 0)
                    Text(
                      l10n.mpLobbyQueuePosition(
                        multiplayerState.matchmakingQueuePosition,
                      ),
                      style: LBText.body(p, color: p.inkDim, size: 11),
                    ),
                  const SizedBox(height: 14),
                  LBCellsBar(
                    count: 16,
                    value: progress,
                    semanticsLabel: l10n.mpLobbySearching,
                  ),

                  // Mid-search with no link. The search is still alive
                  // inside the grace window; say why the numbers stopped
                  // instead of looking hung.
                  if (multiplayerState.matchmakingOffline) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const LBPixelIcon(LBIcon.hourglass, cell: 2.6, color: LB.gold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.mpLobbyWaitingForConnection,
                            style: LBText.body(p, color: LB.gold, size: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  _outlineAction(
                    label: l10n.lbCancel,
                    icon: LBIcon.x,
                    onTap: () {
                      context.read<MultiplayerCubit>().cancelMatchmaking();
                    },
                  ),
                ],
              ),
            ),
            ..._flexGap(min: 2),
            // The house snake is exactly what the wait is for.
            _buildHouseSnakeNote(),
            ..._flexGap(),
          ]),
        ),
      ],
    );
  }

  Widget _buildMatchmakingUnreachableUI(
    BuildContext context,
    MultiplayerState multiplayerState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    // One card, three reasons. The kind picks the icon and the words; the
    // actions are the same because the answer is the same: try again.
    final (LBIcon icon, String title, String body) = switch (
      multiplayerState.matchmakingFailure) {
      MatchmakingFailure.connectionLost => (
        LBIcon.x,
        l10n.mpLobbyConnectionLostTitle,
        l10n.mpLobbyConnectionLostBody,
      ),
      MatchmakingFailure.timedOut => (
        LBIcon.hourglass,
        l10n.mpLobbyTimedOutTitle,
        l10n.mpLobbyTimedOutBody,
      ),
      MatchmakingFailure.unreachable || null => (
        LBIcon.hourglass,
        l10n.mpLobbyUnreachableTitle,
        l10n.mpLobbyUnreachableBody,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.lbGutter, vertical: context.lbCell),
              child: LBBlock(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Empty queue is an outcome, not a failure — so no red
                    // alarm, just the quiet outline the rest of the screen
                    // uses.
                    Center(child: LBPixelIcon(icon, cell: 5, color: p.lime.withValues(alpha: .8))),
                    const SizedBox(height: 18),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: LBText.button(p, color: p.lime, size: 14).copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: LBText.body(p, color: p.ink.withValues(alpha: .75), size: 12),
                    ),
                    const SizedBox(height: 20),
                    _fillAction(
                      label: l10n.mpLobbyTryAgain,
                      icon: LBIcon.play,
                      onTap: () {
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
                    ),
                    _outlineAction(
                      label: l10n.mpLobbyGoBack,
                      icon: LBIcon.back,
                      onTap: () {
                        context
                            .read<MultiplayerCubit>()
                            .clearMatchmakingTimeout();
                      },
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

  /// Lifetime record: wins, losses, draws, rating.
  ///
  /// Present from the first frame, whatever the network is doing. It used to
  /// be gated on the fetch having returned, so the strip materialised a
  /// second after the screen did and shoved Quick Match, Join and Create down
  /// the page — the reader's eye was already on a button that moved out from
  /// under it. Offline it never arrived at all, which left the screen looking
  /// like it had forgotten the mode exists.
  ///
  /// So the shape is fixed and only the contents change: four tiles, always,
  /// with placeholders where the numbers will be. Nothing below it can move,
  /// because nothing about it moves.
  Widget _buildRecordStrip() {
    final l10n = AppLocalizations.of(context)!;

    String? valueOf(String key, {int? fallback}) {
      if (_recordLoading) return null;
      final raw = (_record?[key] as num?)?.toInt();
      if (raw != null) return context.formatInt(raw);
      // Fetched and unavailable — offline, or the call failed. A dash says
      // "not known" honestly; a zero would be a claim about your record.
      return fallback == null ? '—' : context.formatInt(fallback);
    }

    // Wins, losses and draws are plain ink: a record is a set of numbers,
    // not a set of alerts. Rating is gold — it is the reward number.
    return Row(
      children: [
        Expanded(child: VersusRecordTile(label: l10n.lbWins, value: valueOf('wins'))),
        Expanded(child: VersusRecordTile(label: l10n.lbLosses, value: valueOf('losses'))),
        // Draws used to appear only when there were any, which moved the
        // other three columns sideways the moment a draw was recorded.
        // Four columns, always.
        Expanded(child: VersusRecordTile(label: l10n.lbDraws, value: valueOf('draws'))),
        Expanded(
          child: VersusRecordTile(
            label: l10n.lbRating,
            value: valueOf('rating', fallback: 1000),
            color: LB.gold,
          ),
        ),
      ],
    ).gameEntrance(delay: 50.ms);
  }

  Widget _buildJoinGameSection(
    BuildContext context,
    MultiplayerState multiplayerState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.lbGotCode, style: LBText.label(p)),
          const SizedBox(height: 12),
          // Secondary to quick match, like Create Room — you only reach for it
          // once you already have a code in hand.
          VersusCodeInput(
            controller: _roomCodeController,
            hint: l10n.mpLobbyEnterRoomCode,
            goLabel: l10n.mpLobbyJoinRoom,
            onGo: multiplayerState.isLoading || _roomCodeController.text.isEmpty
                ? null
                : () {
                    context.read<MultiplayerCubit>().joinGame(
                      _roomCodeController.text.trim(),
                    );
                  },
          ),
          const SizedBox(height: 12),
          Text(l10n.lbGotCodeLine, style: LBText.body(p, color: p.inkDim, size: 11)),
        ],
      ),
    ).gameEntrance(delay: 150.ms);
  }

  Widget _buildCreateGameSection(
    BuildContext context,
    MultiplayerState multiplayerState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    // Classic 1v1 room — share the code (or ping a friend from the room
    // header) to fill the second slot. No mode picker: the server engine
    // only runs classic 1v1 in this release. Outline, not fill: quick match
    // is what most players want.
    return LBRow(
      title: l10n.lbCreateRoom,
      subtitle: l10n.lbCreateRoomLine,
      titleColor: p.lime,
      semanticLabel: l10n.lbCreateRoom,
      trailing: LBPixelIcon(LBIcon.plus, cell: 3.4, color: p.lime),
      onTap: multiplayerState.isLoading
          ? null
          : () {
              context.read<MultiplayerCubit>().createGame(
                mode: MultiplayerGameMode.classic,
                maxPlayers: 2,
              );
            },
    ).gameEntrance(delay: 200.ms);
  }

  /// Quick match always resolves: after the server's fallback deadline a
  /// house account takes the seat (MatchmakingService / BotPolicy).
  Widget _buildHouseSnakeNote() {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.dashed,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          LBPixelIcon(LBIcon.user, cell: 3, color: p.inkMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.lbHouseSnake,
              style: LBText.body(p, color: p.ink.withValues(alpha: .7), size: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsLink() {
    final l10n = AppLocalizations.of(context)!;
    return LBRow(
      kind: LBBlockKind.gold,
      title: l10n.lbTournamentsLive,
      subtitle: l10n.lbTournamentsLine,
      semanticLabel: l10n.lbTournamentsLive,
      leading: const LBPixelIcon(LBIcon.trophy, cell: 3.4, color: LB.gold),
      trailing: const LBPixelIcon(LBIcon.next, cell: 2.6, color: LB.gold),
      onTap: () => context.push(AppRoutes.tournaments),
    );
  }

  Widget _buildGameModeCard(MultiplayerGame game) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBRow(
      title: game.mode.localizedName(l10n),
      subtitle: _getGameModeDescription(game.mode),
      titleColor: p.lime,
      leading: LBPixelIcon(LBIcon.swords, cell: 3.4, color: p.lime, accent: LB.bonk),
    );
  }

  Widget _buildPlayersSection(
    MultiplayerGame game,
    AuthState authState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = authState.userId;
    // You first, then your rival — the room reads top-down as "you vs them".
    final players = game.players.toList()
      ..sort((a, b) {
        final ay = a.userId == currentUserId ? 0 : 1;
        final by = b.userId == currentUserId ? 0 : 1;
        return ay.compareTo(by);
      });
    final rowH = context.lbCell * 4;

    final rows = <Widget>[
      for (final player in players) _buildPlayerItem(player, authState, rowH),
      if (!game.isFull)
        VersusEmptySlot(
          label: l10n.mpLobbyWaitingForPlayer,
          height: rowH - LB.inset * 2,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LBSectionLabel(
          l10n.lbPlayersCount('${players.length}', '${game.maxPlayers}'),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
            if (rows.length >= 2)
              Positioned(
                top: rowH - 14,
                left: 0,
                right: 0,
                child: Center(child: VersusVsChip(label: l10n.lbVs)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerItem(
    MultiplayerPlayer player,
    AuthState authState,
    double rowH,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrentUser = authState.userId == player.userId;
    final status = switch (player.status) {
      PlayerStatus.waiting => isCurrentUser ? l10n.lbWaitingYou : l10n.lbWaiting,
      PlayerStatus.ready => isCurrentUser ? l10n.lbReadyYou : l10n.lbReadyThem,
      _ => _getStatusText(player.status),
    };
    return VersusPlayerRow(
      name: player.publicLabel,
      status: status,
      isYou: isCurrentUser,
      youLabel: l10n.lbYou,
      ready: player.status == PlayerStatus.ready,
      dim: player.status == PlayerStatus.crashed ||
          player.status == PlayerStatus.disconnected,
      height: rowH - LB.inset * 2,
    );
  }

  Widget _buildLobbyActions(
    BuildContext context,
    MultiplayerState multiplayerState,
    MultiplayerGame game,
    AuthState authState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
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
    if (readyDeadline != null) {
      _readyCheckTotal = math.max(_readyCheckTotal, readyDeadline);
    }
    // The state worth calling out: you have confirmed, they have not. Without
    // it a matchmade lobby just sits there and reads as broken.
    final waitingOnOpponent =
        isReady && !allPlayersReady && game.players.length >= 2;

    // Toggle: tapping while ready un-readies (SetReady carries the bool; the
    // button used to lock once pressed).
    final VoidCallback? toggleReady = multiplayerState.isLoading
        ? null
        : () {
            context.read<MultiplayerCubit>().markPlayerReady(
              isReady: !isReady,
            );
          };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ready-check deadline. Present only while the check is genuinely
        // outstanding: once everyone is ready the room is committed and a
        // ticking clock would read as a threat to a match that is about to
        // start anyway.
        if (readyDeadline != null && !allPlayersReady)
          VersusReadyCheck(
            label: l10n.lbReadyCheck,
            seconds: readyDeadline,
            total: _readyCheckTotal,
            secondsLabel: l10n.lbSeconds('$readyDeadline'),
            semanticLabel: l10n.mpLobbyReadyDeadline(readyDeadline),
          ),

        // You are ready, they are not.
        if (waitingOnOpponent)
          VersusStatusNote(text: l10n.mpLobbyWaitingOpponentReady),

        // Show waiting message for non-host when all ready
        if (!isHost && allPlayersReady && game.players.length >= 2)
          VersusStatusNote(text: l10n.mpLobbyWaitingForHost),

        SizedBox(height: cell * .6),

        // Show Start Game button for host when all players are ready
        if (canStartGame)
          _fillAction(
            label: l10n.mpLobbyStartGame,
            icon: LBIcon.play,
            height: cell * 3,
            onTap: multiplayerState.isLoading
                ? null
                : () {
                    context.read<MultiplayerCubit>().startGame();
                  },
          ),

        // Ready is the action to take; leaving is the way out. Confirmed
        // state goes quiet: the lime block is the thing still asking to be
        // pressed.
        if (!isReady)
          Opacity(
            opacity: toggleReady == null ? .55 : 1,
            child: LBBlock(
              kind: LBBlockKind.fill,
              height: cell * 5,
              alignment: Alignment.center,
              semanticLabel: l10n.lbReady,
              onTap: toggleReady,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LBPixelIcon(LBIcon.check, cell: 4.6 * context.uiScale, color: p.onLime),
                  SizedBox(width: cell * .8),
                  Flexible(
                    child: LBCellText(
                      l10n.lbReady,
                      cell: 7 * context.uiScale,
                      color: p.onLime,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          LBBlock(
            selected: true,
            height: cell * 3,
            alignment: Alignment.center,
            semanticLabel: l10n.mpLobbyReadyDone,
            onTap: toggleReady,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LBPixelIcon(LBIcon.check, cell: 3.4, color: p.lime),
                const SizedBox(width: 12),
                Text(
                  l10n.mpLobbyReadyDone.toUpperCase(),
                  style: LBText.button(p, color: p.lime, size: 15).copyWith(letterSpacing: 3),
                ),
              ],
            ),
          ),

        SizedBox(height: cell * .3),

        VersusTextLink(
          label: l10n.lbLeaveRoom,
          onTap: () {
            context.read<MultiplayerCubit>().leaveGame();
            context.pop();
          },
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
