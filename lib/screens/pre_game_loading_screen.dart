import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/run_setup_screen.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/first_run_service.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// The beat between PLAY and the board: what you are about to play, your
/// numbers, a tip, and a cell bar filling up.
///
/// It does no real work — audio is preloaded in main() and only touched here
/// — so it is skippable: a tap anywhere fills the bar and starts the run. A
/// player's very first game skips it outright (their numbers are all zero
/// and the tips reference things they have not met yet). On finishing it
/// `pushReplacement`s the game, so back from the game returns to Home.
class PreGameLoadingScreen extends StatefulWidget {
  const PreGameLoadingScreen({super.key});

  @override
  State<PreGameLoadingScreen> createState() => _PreGameLoadingScreenState();
}

class _PreGameLoadingScreenState extends State<PreGameLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _loadDuration = Duration(milliseconds: 3000);
  static const Duration _tipRotation = Duration(milliseconds: 2200);
  static const int _barCells = 16;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _loadDuration,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _goToGame();
    });

  Timer? _tipTimer;
  int _tipIndex = Random().nextInt(_tipCount);
  bool _navigated = false;

  static const int _tipCount = 8;

  List<String> _tips(AppLocalizations l10n) => [
        l10n.lbTip1,
        l10n.lbTip2,
        l10n.lbTip3,
        l10n.lbTip4,
        l10n.lbTip5,
        l10n.lbTip6,
        l10n.lbTip7,
        l10n.lbTip8,
      ];

  @override
  void initState() {
    super.initState();
    // Audio is preloaded in main(); this just guarantees the instance is
    // alive before gameplay.
    AudioService();
    _tipTimer = Timer.periodic(_tipRotation, (_) {
      if (mounted && !_navigated) {
        setState(() => _tipIndex = (_tipIndex + 1) % _tipCount);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (FirstRunService().isFirstGame) {
        _goToGame();
        return;
      }
      _progress.forward();
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  void _goToGame() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.pushReplacement(AppRoutes.game);
  }

  /// Tap-to-skip: sprint the bar to full; the completed listener navigates,
  /// so skipping and waiting share one path.
  void _skip() {
    if (_navigated || _progress.isCompleted) return;
    LBFeedback.tap();
    _progress.animateTo(1, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild on theme changes (the palette re-skins through context.lb).
    context.watch<ThemeCubit>();
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final g = context.lbGutter;
    final cell = context.lbCell;

    // The player's mode unless a tournament staged its own before PLAY.
    final tournamentMode = context.select<GameCubit, TournamentGameMode?>((c) => c.state.tournamentMode);
    final settings = context.watch<GameSettingsCubit>().state;
    final mode = tournamentMode?.toGameMode() ?? settings.gameMode;
    final isTournament = tournamentMode != null && mode != settings.gameMode;
    final board = settings.boardSize;

    final level = ProgressionService().level;
    final runs = StatisticsService().statistics.totalGamesPlayed;

    return PopScope(
      // Nothing to protect yet: back goes home. _navigated guards doubles.
      canPop: true,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _skip,
          child: LBGridBackground(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(g, cell * .5, g, cell),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: the mark and what is happening.
                    SizedBox(
                      height: cell * 2,
                      child: Row(
                        children: [
                          LBCellSMark(size: cell * 2 - 2),
                          SizedBox(width: cell * .6),
                          Expanded(
                            child: Text(
                              l10n.pgPreparing,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LBText.button(p, color: p.lime, size: 13).copyWith(letterSpacing: 3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),

                    // The run: mode in cells, its one-liner, the setup.
                    if (isTournament) ...[
                      Center(child: LBChip(label: l10n.pgTournamentMode, kind: LBChipKind.gold, icon: LBIcon.trophy)),
                      SizedBox(height: cell * .8),
                    ],
                    SizedBox(
                      height: cell * 4,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: LBCellText(
                          mode.localizedName(l10n).toUpperCase(),
                          cell: cell * .55,
                          glow: true,
                        ),
                      ),
                    ),
                    SizedBox(height: cell * .8),
                    Text(
                      RunSetupScreen.modeLine(l10n, mode),
                      textAlign: TextAlign.center,
                      style: LBText.body(p, size: 13, color: p.ink.withValues(alpha: .85)),
                    ),
                    SizedBox(height: cell),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        LBChip(label: '${board.width}×${board.height}', icon: LBIcon.grid),
                        LBChip(label: settings.difficulty.localizedLabel(l10n).toUpperCase(), icon: LBIcon.bolt),
                        LBChip(
                          label: (settings.dPadEnabled ? l10n.pgDPadControls : l10n.pgSwipeControls).toUpperCase(),
                          icon: LBIcon.target,
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),

                    // Your numbers.
                    Row(
                      children: [
                        Expanded(child: _Stat(label: l10n.pgLevel, value: '$level')),
                        Expanded(child: _Stat(label: l10n.pgBest, value: context.formatCompact(settings.highScore))),
                        Expanded(child: _Stat(label: l10n.pgGames, value: context.formatCompact(runs))),
                      ],
                    ),
                    SizedBox(height: cell * .4),

                    // One tip, rotating.
                    LBBlock(
                      kind: LBBlockKind.sheet,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const LBPixelIcon(LBIcon.star, cell: 3.4, color: LB.gold),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text.rich(
                                key: ValueKey(_tipIndex),
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${l10n.lbTipLabel} · ',
                                      style: LBText.button(p, color: p.lime, size: 12),
                                    ),
                                    TextSpan(text: _tips(l10n)[_tipIndex]),
                                  ],
                                ),
                                style: LBText.body(p, size: 12.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),

                    // The bar, and how to skip it.
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) => LBCellsBar(
                        count: _barCells,
                        value: _progress.value,
                        semanticsLabel: l10n.pgPreparing,
                      ),
                    ),
                    SizedBox(height: cell * .7),
                    Text(
                      l10n.pgTapToStart,
                      textAlign: TextAlign.center,
                      style: LBText.label(p, color: p.inkMuted).copyWith(letterSpacing: 2.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final cell = context.lbCell;
    return LBBlock(
      height: cell * 4,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: LBText.label(p, color: p.inkMuted).copyWith(letterSpacing: 2)),
          SizedBox(height: cell * .35),
          SizedBox(
            height: cell * 1.3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LBCellText(value, cell: cell * .26, color: p.head),
            ),
          ),
        ],
      ),
    );
  }
}
