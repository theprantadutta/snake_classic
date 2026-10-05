import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/in_app_update_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Pause (Living Board screen 06): PAUSED in snake cells over the dimmed
/// board, RESUME (a 3·2·1 countdown, then go), RESTART, SETTINGS (an
/// in-run sheet: controls, snap movement, sound, music, how to play) and
/// QUIT TO MENU, with the run so far underneath.
class PauseOverlay extends StatefulWidget {
  final GameTheme theme;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  /// Re-launches the gameplay tutorial. Optional so callers that don't wire
  /// it up still build.
  final VoidCallback? onShowTutorial;

  /// The paused run, for the "so far" footer.
  final GameState? gameState;

  const PauseOverlay({
    super.key,
    required this.theme,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    this.onShowTutorial,
    this.gameState,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  /// 3, 2, 1 while the resume countdown runs; null otherwise.
  int? _count;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResume() {
    if (_count != null) return;
    setState(() => _count = 3);
    _tick();
    _timer = Timer.periodic(const Duration(milliseconds: 650), (t) {
      if (!mounted) return;
      final next = (_count ?? 1) - 1;
      if (next <= 0) {
        t.cancel();
        AudioService().playSound('countdown_go', volume: .7);
        HapticService().lightImpact();
        widget.onResume();
        return;
      }
      setState(() => _count = next);
      _tick();
    });
  }

  void _tick() {
    AudioService().playSound('countdown_tick', volume: .6);
    HapticService().lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final gs = widget.gameState;

    Widget content;
    if (_count != null) {
      content = Center(
        child: Semantics(
          liveRegion: true,
          label: '$_count',
          child: LBAnimatedCellText(
            '$_count',
            cell: cell * 1.2,
            glow: true,
            duration: const Duration(milliseconds: 160),
          ),
        ),
      );
    } else {
      content = Center(
        child: SingleChildScrollView(
          // Two extra cells each side cost a 360 dp phone ~72 dp and cut
          // "QUIT TO MENU" to "QUIT TO M…" (Realme RMX3771). One extra on
          // narrow phones; wider phones and tablets keep two.
          padding: EdgeInsets.symmetric(
            horizontal: context.lbGutter + cell * (MediaQuery.sizeOf(context).width < 380 ? 1 : 2),
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Semantics(
                    header: true,
                    child: LBCellText(l10n.lbPauseTitle, cell: 11 * context.uiScale, glow: true),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.lbPauseLine,
                  textAlign: TextAlign.center,
                  style: LBText.body(p, color: p.ink.withValues(alpha: .7), size: 13),
                ),
                SizedBox(height: cell * 1.6),
                LBBlock(
                  kind: LBBlockKind.fill,
                  height: cell * 3.6,
                  alignment: Alignment.center,
                  semanticLabel: l10n.lbResume,
                  onTap: _startResume,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.lbResume, style: LBText.button(p, color: p.onLime, size: 17).copyWith(letterSpacing: 4)),
                      const SizedBox(height: 6),
                      Text(l10n.lbResumeSub, style: LBText.label(p, color: p.onLime.withValues(alpha: .65))),
                    ],
                  ),
                ),
                _PauseRow(
                  title: l10n.lbRestart,
                  aside: l10n.lbRestartSub,
                  onTap: widget.onRestart,
                ),
                _PauseRow(
                  title: l10n.lbPauseSettings,
                  aside: l10n.lbPauseSettingsSub,
                  onTap: () => _openSettings(context),
                ),
                _PauseRow(
                  title: l10n.lbQuit,
                  aside: l10n.lbQuitSub,
                  kind: LBBlockKind.danger,
                  onTap: widget.onHome,
                ),
                // A downloaded Play update waiting for a restart. Only ever
                // visible once the download has landed.
                ValueListenableBuilder<bool>(
                  valueListenable: InAppUpdateService().updateReadyToInstall,
                  builder: (context, ready, _) => ready
                      ? _PauseRow(
                          title: l10n.poUpdateReady,
                          kind: LBBlockKind.gold,
                          onTap: () => InAppUpdateService().completeUpdate(),
                        )
                      : const SizedBox.shrink(),
                ),
                if (gs != null) ...[
                  SizedBox(height: cell),
                  // One line: wrapped, it split "· 0:57" off on its own.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.lbPauseSoFar(
                        context.formatInt(gs.score),
                        '${gs.snake.length}',
                        _elapsed(gs),
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: LBText.label(p, color: p.inkDim).copyWith(fontSize: 10),
                    ),
                  ),
                ],
                SizedBox(height: cell * .8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TextLink(label: l10n.poStore, onTap: () => context.push(AppRoutes.store)),
                    Text('  ·  ', style: LBText.label(p, color: p.inkDim)),
                    _TextLink(
                      label: l10n.lbGoPro,
                      color: LB.gold,
                      onTap: () => context.push(AppRoutes.premiumBenefits),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Blur the board behind the overlay so the pause visibly disengages the
    // world while it stays faintly readable underneath.
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: ColoredBox(
        color: p.board.withValues(alpha: .78),
        child: SafeArea(child: content),
      ),
    );
  }

  static String _elapsed(GameState gs) {
    final start = gs.gameStartTime;
    if (start == null) return '0:00';
    final d = (gs.pausedAt ?? DateTime.now()).difference(start);
    final s = d.inSeconds < 0 ? 0 : d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void _openSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showLBSheet<void>(
      context: context,
      title: l10n.lbPauseSettings,
      builder: (sheetContext) => BlocBuilder<GameSettingsCubit, GameSettingsState>(
        builder: (context, settings) {
          final cubit = context.read<GameSettingsCubit>();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LBSectionLabel(l10n.lbControls),
                Row(
                  children: [
                    for (final (label, sub, on, apply) in [
                      (l10n.lbCtrlSwipe, l10n.lbCtrlSwipeSub, !settings.dPadEnabled, () => cubit.setDPadEnabled(false)),
                      (
                        l10n.lbCtrlDpad,
                        l10n.lbCtrlDpadSub,
                        settings.dPadEnabled && settings.controlLayout == ControlLayout.dPad,
                        () {
                          cubit.setDPadEnabled(true);
                          cubit.setControlLayout(ControlLayout.dPad);
                        },
                      ),
                      (
                        l10n.lbCtrlTurn,
                        l10n.lbCtrlTurnSub,
                        settings.dPadEnabled && settings.controlLayout == ControlLayout.turnButtons,
                        () {
                          cubit.setDPadEnabled(true);
                          cubit.setControlLayout(ControlLayout.turnButtons);
                        },
                      ),
                      (
                        l10n.lbCtrlStick,
                        l10n.lbCtrlStickSub,
                        settings.dPadEnabled && settings.controlLayout == ControlLayout.joystick,
                        () {
                          cubit.setDPadEnabled(true);
                          cubit.setControlLayout(ControlLayout.joystick);
                        },
                      ),
                    ])
                      Expanded(
                        child: LBControlChoice(title: label, subtitle: sub, selected: on, onTap: apply),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LBRow(
                  title: settings.snapMovementEnabled ? l10n.poSnapOn : l10n.poSnapOff,
                  trailing: LBToggle(
                    value: settings.snapMovementEnabled,
                    onChanged: cubit.setSnapMovementEnabled,
                  ),
                  onTap: () => cubit.setSnapMovementEnabled(!settings.snapMovementEnabled),
                ),
                LBRow(
                  title: l10n.lbSoundFx,
                  subtitle: l10n.lbSoundFxSub,
                  trailing: LBToggle(value: settings.soundEnabled, onChanged: cubit.setSoundEnabled),
                  onTap: () => cubit.setSoundEnabled(!settings.soundEnabled),
                ),
                LBRow(
                  title: l10n.lbMusic,
                  trailing: LBToggle(value: settings.musicEnabled, onChanged: cubit.setMusicEnabled),
                  onTap: () => cubit.setMusicEnabled(!settings.musicEnabled),
                ),
                if (widget.onShowTutorial != null)
                  LBRow(
                    title: l10n.poHowToPlay,
                    leading: const LBPixelIcon(LBIcon.eye, cell: 3.6),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onShowTutorial!();
                    },
                  ),
                LBRow(
                  title: l10n.poGameGuide,
                  leading: const LBPixelIcon(LBIcon.grid, cell: 3.6),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(AppRoutes.instructions);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PauseRow extends StatelessWidget {
  const _PauseRow({
    required this.title,
    required this.onTap,
    this.aside,
    this.kind = LBBlockKind.outline,
  });

  final String title;
  final String? aside;
  final VoidCallback onTap;
  final LBBlockKind kind;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      height: context.lbCell * 3,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      // The title is the action; the aside is a hint. So the title keeps
      // its width and the aside gives way (it ellipsizes first), the
      // opposite of before, when "QUIT TO MENU" was the one cut.
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                title,
                maxLines: 1,
                style: LBText.button(p, color: fg, size: 14).copyWith(letterSpacing: 2.4),
              ),
            ),
          ),
          if (aside != null) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                aside!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: LBText.body(p, color: fg.withValues(alpha: .7), size: 11),
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap, this.color});

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            LBFeedback.tap();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(
              label.toUpperCase(),
              style: LBText.label(context.lb, color: color ?? context.lb.inkMuted).copyWith(
                fontSize: 10,
                decoration: TextDecoration.underline,
                decorationColor: (color ?? context.lb.inkMuted).withValues(alpha: .5),
              ),
            ),
          ),
        ),
      );
}

/// A control-layout choice block (SWIPE / D-PAD / TURN / STICK). Shared by
/// the pause settings sheet and the Settings screen.
class LBControlChoice extends StatelessWidget {
  const LBControlChoice({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final kind = selected ? LBBlockKind.fill : LBBlockKind.outline;
    final fg = LBBlock.foregroundOf(kind, p);
    return Semantics(
      selected: selected,
      child: LBBlock(
        kind: kind,
        height: context.lbCell * 3.5,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: LBText.button(p, color: fg, size: 13).copyWith(letterSpacing: 1.6)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(subtitle, style: LBText.body(p, color: fg.withValues(alpha: .7), size: 10.5)),
            ),
          ],
        ),
      ),
    );
  }
}
