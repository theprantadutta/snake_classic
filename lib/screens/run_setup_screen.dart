import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/home_screen.dart' show loadoutLabelFor;
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Run setup (Living Board screen 03): mode, board, difficulty and loadout
/// on one page, then PLAY. Opened from Home (PLAY long-press, the mode row)
/// and from Settings. Every choice writes straight through
/// [GameSettingsCubit] / [PowerUpCubit], so backing out keeps them.
class RunSetupScreen extends StatelessWidget {
  const RunSetupScreen({super.key});

  static const _loadoutKeys = ['speed_boost', 'invincibility', 'score_multiplier', 'slow_motion'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final settings = context.watch<GameSettingsCubit>().state;
    final cubit = context.read<GameSettingsCubit>();
    final g = context.lbGutter;

    return LBScaffold(
      title: l10n.lbSetupTitle,
      subtitle: l10n.lbSetupSubtitle,
      banner: false,
      body: ListView(
        padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell),
        children: [
          LBSectionLabel(
            l10n.lbSetupMode,
            trailing: l10n.lbSetupModesAside('${GameMode.values.length}'),
          ),
          _TwoColumn(
            children: [
              for (final mode in GameMode.values)
                LBChoiceBlock(
                  title: mode.localizedName(l10n),
                  line: modeLine(l10n, mode),
                  selected: settings.gameMode == mode,
                  onTap: () {
                    cubit.setGameMode(mode);
                    // Choosing here IS the first-run mode choice.
                    cubit.markGameModePrompted();
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          LBSectionLabel(
            l10n.lbSetupBoard,
            trailing:
                '${settings.boardSize.id.replaceAll('x', '×')} · ${settings.boardSize.localizedName(l10n)}',
          ),
          Row(
            children: [
              for (final size in GameConstants.availableBoardSizes)
                Expanded(
                  child: LBBlock(
                    kind: settings.boardSize == size ? LBBlockKind.fill : LBBlockKind.outline,
                    height: 46,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    semanticLabel: '${size.localizedName(l10n)}, ${size.id}',
                    onTap: () => cubit.setBoardSize(size),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          _boardLabel(l10n, size),
                          style: LBText.button(
                            p,
                            color: LBBlock.foregroundOf(
                              settings.boardSize == size ? LBBlockKind.fill : LBBlockKind.outline,
                              p,
                            ),
                            size: size.isTall ? 10 : 13,
                          ).copyWith(letterSpacing: .4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          LBSectionLabel(l10n.lbSetupDifficulty),
          Row(
            children: [
              for (final d in Difficulty.values)
                Expanded(
                  child: LBChoiceBlock(
                    title: d.localizedLabel(l10n),
                    line: switch (d) {
                      Difficulty.easy => l10n.lbDiffEasyLine,
                      Difficulty.normal => l10n.lbDiffNormalLine,
                      Difficulty.hard => l10n.lbDiffHardLine,
                    },
                    selected: settings.difficulty == d,
                    centered: true,
                    onTap: () => cubit.setDifficulty(d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<PowerUpCubit, PowerUpState>(
            builder: (context, state) {
              final armed = state.armed;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LBSectionLabel(
                    l10n.lbSetupLoadout,
                    trailing: armed == null
                        ? l10n.lbSetupLoadoutNone
                        : l10n.lbSetupLoadoutArmedOne(loadoutLabelFor(l10n, armed).toUpperCase()),
                  ),
                  Row(
                    children: [
                      for (final key in _loadoutKeys)
                        Expanded(
                          child: _LoadoutSlot(
                            label: loadoutLabelFor(l10n, key),
                            icon: _loadoutIcon(key),
                            count: state.countFor(key),
                            armed: armed == key,
                            onTap: () {
                              if (state.countFor(key) == 0) {
                                context.push('${AppRoutes.store}?tab=5');
                              } else if (armed == key) {
                                context.read<PowerUpCubit>().unarm();
                              } else {
                                context.read<PowerUpCubit>().arm(key);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(g, 4, g, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LBBlock(
              kind: LBBlockKind.fill,
              height: context.lbCell * 4,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              semanticLabel: l10n.lbPlay,
              onTap: () => _play(context),
              child: Row(
                children: [
                  LBPixelIcon(LBIcon.play, cell: 4.2, color: p.onLime),
                  const SizedBox(width: 14),
                  LBCellText(l10n.lbPlay, cell: 7 * context.uiScale, color: p.onLime),
                  const Spacer(),
                  Flexible(
                    flex: 3,
                    child: Text(
                      l10n.lbModeBoard(
                        settings.gameMode.localizedName(l10n).toUpperCase(),
                        settings.boardSize.id.replaceAll('x', '×'),
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      style: LBText.label(p, color: p.onLime.withValues(alpha: .7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.lbTip4,
              textAlign: TextAlign.center,
              style: LBText.body(p, color: p.inkDim, size: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _play(BuildContext context) {
    unawaited(LegalAcceptance.recordAccepted());
    HapticService().mediumImpact();
    context.read<GameSettingsCubit>().markGameModePrompted();
    context.push(AppRoutes.playLoading);
  }

  /// The Living Board one-liner for a mode (COPY.md "Mode one-liners").
  static String modeLine(AppLocalizations l10n, GameMode mode) => switch (mode) {
        GameMode.classic => l10n.lbModeLineClassic,
        GameMode.zen => l10n.lbModeLineZen,
        GameMode.speedChallenge => l10n.lbModeLineSpeed,
        GameMode.multiFood => l10n.lbModeLineMultiFood,
        GameMode.survival => l10n.lbModeLineSurvival,
        GameMode.timeAttack => l10n.lbModeLineTimeAttack,
        GameMode.powerUpMadness => l10n.lbModeLinePowerUp,
        GameMode.perfectGame => l10n.lbModeLinePerfect,
      };

  static String _boardLabel(AppLocalizations l10n, BoardSize size) {
    if (!size.isTall) return '${size.width}';
    final tallest = GameConstants.availableBoardSizes.where((s) => s.isTall).last;
    return size == tallest ? '${l10n.lbBoardTall}+' : l10n.lbBoardTall;
  }

  static LBIcon _loadoutIcon(String key) => switch (key) {
        'speed_boost' => LBIcon.bolt,
        'invincibility' => LBIcon.shield,
        'score_multiplier' => LBIcon.star,
        _ => LBIcon.hourglass,
      };
}

class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: children[i]),
          Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
        ],
      ));
    }
    return Column(children: rows);
  }
}

class _LoadoutSlot extends StatelessWidget {
  const _LoadoutSlot({
    required this.label,
    required this.icon,
    required this.count,
    required this.armed,
    required this.onTap,
  });

  final String label;
  final LBIcon icon;
  final int count;
  final bool armed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final owned = count > 0;
    final kind = !owned ? LBBlockKind.dashed : (armed ? LBBlockKind.gold : LBBlockKind.outline);
    final fg = !owned ? p.inkDim : (armed ? LB.gold : p.head);
    return Semantics(
      selected: armed,
      child: LBBlock(
        kind: kind,
        selected: armed,
        height: context.lbCell * 4,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LBPixelIcon(icon, cell: 3.6, color: owned ? (armed ? LB.gold : p.lime) : p.inkDim),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: LBText.button(p, color: fg, size: 10).copyWith(letterSpacing: .6),
              ),
            ),
            Text(
              owned ? l10n.lbOwnedCount('$count') : l10n.lbSetupGet,
              style: LBText.button(p, color: owned ? LB.gold : p.inkDim, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}
