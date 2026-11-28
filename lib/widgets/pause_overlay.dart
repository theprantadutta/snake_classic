import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:material_ui/material_ui.dart';
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
import 'package:snake_classic/widgets/control_layout_preview.dart';
import 'package:snake_classic/widgets/control_tuning.dart';
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
      // Three groups spread over the real screen height (header + run card,
      // actions, footer) instead of one block floating in the middle with a
      // dead third below it (owner review 2026-11-21). Scrolls when short.
      content = LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          // Full width between the standard gutters (owner: "take more
          // width"); tablets cap the column at 480 dp below.
          padding: EdgeInsets.symmetric(
            horizontal: context.lbGutter,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, box.maxHeight - 40),
            ),
            child: Center(
              // Center loosens constraints, so the min height is restated
              // here or the spacers have nothing to fill.
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  minHeight: math.max(0, box.maxHeight - 40),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // One block, sitting a little above centre; the
                      // footer links pin to the bottom.
                      const Spacer(flex: 2),
                      Center(
                        child: Semantics(
                          header: true,
                          child: LBCellText(
                            l10n.lbPauseTitle,
                            cell: 11 * context.uiScale,
                            glow: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.lbPauseLine,
                        textAlign: TextAlign.center,
                        style: LBText.body(
                          p,
                          color: p.ink.withValues(alpha: .75),
                          size: 13,
                        ),
                      ),
                      if (gs != null) ...[
                        SizedBox(height: cell * 1.2),
                        _RunCard(
                          score: context.formatInt(gs.score),
                          length: '${gs.snake.length}',
                          time: _elapsed(gs),
                          scoreLabel: l10n.lbScoreLabel,
                          lengthLabel: l10n.lbLength,
                          timeLabel: l10n.rvTime.toUpperCase(),
                        ),
                      ],
                      SizedBox(height: cell * 1.6),
                      LBBlock(
                        kind: LBBlockKind.fill,
                        height: cell * 4.4,
                        alignment: Alignment.center,
                        semanticLabel: l10n.lbResume,
                        onTap: _startResume,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LBPixelIcon(LBIcon.play, cell: 4, color: p.onLime),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.lbResume,
                                  style: LBText.button(
                                    p,
                                    color: p.onLime,
                                    size: 18,
                                  ).copyWith(letterSpacing: 4),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  l10n.lbResumeSub,
                                  style: LBText.label(
                                    p,
                                    color: p.onLime.withValues(alpha: .7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PauseRow(
                        icon: LBIcon.restart,
                        title: l10n.lbRestart,
                        aside: l10n.lbRestartSub,
                        onTap: widget.onRestart,
                      ),
                      const SizedBox(height: 8),
                      _PauseRow(
                        icon: LBIcon.gear,
                        title: l10n.lbPauseSettings,
                        aside: l10n.lbPauseSettingsSub,
                        onTap: () => _openSettings(context),
                      ),
                      const SizedBox(height: 8),
                      _PauseRow(
                        icon: LBIcon.back,
                        title: l10n.lbQuit,
                        aside: l10n.lbQuitSub,
                        kind: LBBlockKind.danger,
                        onTap: widget.onHome,
                      ),
                      // A downloaded Play update waiting for a restart. Only
                      // ever visible once the download has landed.
                      ValueListenableBuilder<bool>(
                        valueListenable:
                            InAppUpdateService().updateReadyToInstall,
                        builder: (context, ready, _) => ready
                            ? _PauseRow(
                                icon: LBIcon.gift,
                                title: l10n.poUpdateReady,
                                kind: LBBlockKind.gold,
                                onTap: () =>
                                    InAppUpdateService().completeUpdate(),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const Spacer(flex: 3),
                      SizedBox(height: cell * .8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TextLink(
                            label: l10n.poStore,
                            onTap: () => context.push(AppRoutes.store),
                          ),
                          Text('  ·  ',
                              style: LBText.label(p, color: p.inkDim)),
                          _TextLink(
                            label: l10n.lbGoPro,
                            color: LB.gold,
                            onTap: () =>
                                context.push(AppRoutes.premiumBenefits),
                          ),
                        ],
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

    // Blur the board behind the overlay so the pause visibly disengages the
    // world. Lighter than before (.78 -> .62): the theme's board should still
    // read underneath, not turn into a black void.
    // Clipped: a BackdropFilter blurs everything painted behind it up to
    // its nearest clip, which without one is the whole screen. That is
    // what blurred the banner above the play area along with the board.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColoredBox(
          color: p.board.withValues(alpha: .62),
          child: SafeArea(child: content),
        ),
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
      builder: (sheetContext) =>
          BlocBuilder<GameSettingsCubit, GameSettingsState>(
            builder: (context, settings) {
              final cubit = context.read<GameSettingsCubit>();
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LBSectionLabel(l10n.lbControls),
                    Row(
                      children: [
                        for (final (label, sub, dPad, layout) in [
                          (
                            l10n.lbCtrlSwipe,
                            l10n.lbCtrlSwipeSub,
                            false,
                            ControlLayout.dPad,
                          ),
                          (
                            l10n.lbCtrlDpad,
                            l10n.lbCtrlDpadSub,
                            true,
                            ControlLayout.dPad,
                          ),
                          (
                            l10n.lbCtrlTurn,
                            l10n.lbCtrlTurnSub,
                            true,
                            ControlLayout.turnButtons,
                          ),
                          (
                            l10n.lbCtrlStick,
                            l10n.lbCtrlStickSub,
                            true,
                            ControlLayout.joystick,
                          ),
                        ]) ...[
                          Expanded(
                            child: LBControlChoice(
                              title: label,
                              subtitle: sub,
                              selected: dPad
                                  ? settings.dPadEnabled &&
                                        settings.controlLayout == layout
                                  : !settings.dPadEnabled,
                              onTap: () {
                                cubit.setDPadEnabled(dPad);
                                if (dPad) cubit.setControlLayout(layout);
                              },
                              preview: ControlLayoutPreview(
                                dPadEnabled: dPad,
                                layout: layout,
                                dPadPosition: settings.dPadPosition,
                                controlSize: settings.controlSize,
                                theme: widget.theme,
                              ),
                            ),
                          ),
                          if (layout != ControlLayout.joystick)
                            const SizedBox(width: 6),
                        ],
                      ],
                    ),
                    ControlTuning(settings: settings),
                    const SizedBox(height: 8),
                    LBRow(
                      title: settings.snapMovementEnabled
                          ? l10n.poSnapOn
                          : l10n.poSnapOff,
                      trailing: LBToggle(
                        value: settings.snapMovementEnabled,
                        onChanged: cubit.setSnapMovementEnabled,
                      ),
                      onTap: () => cubit.setSnapMovementEnabled(
                        !settings.snapMovementEnabled,
                      ),
                    ),
                    LBRow(
                      title: l10n.lbSoundFx,
                      subtitle: l10n.lbSoundFxSub,
                      trailing: LBToggle(
                        value: settings.soundEnabled,
                        onChanged: cubit.setSoundEnabled,
                      ),
                      onTap: () =>
                          cubit.setSoundEnabled(!settings.soundEnabled),
                    ),
                    LBRow(
                      title: l10n.lbMusic,
                      trailing: LBToggle(
                        value: settings.musicEnabled,
                        onChanged: cubit.setMusicEnabled,
                      ),
                      onTap: () =>
                          cubit.setMusicEnabled(!settings.musicEnabled),
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

/// The run so far: SCORE, LENGTH and TIME as big readouts in one card
/// (it used to be a single 10 pt dim line).
class _RunCard extends StatelessWidget {
  const _RunCard({
    required this.score,
    required this.length,
    required this.time,
    required this.scoreLabel,
    required this.lengthLabel,
    required this.timeLabel,
  });

  final String score, length, time;
  final String scoreLabel, lengthLabel, timeLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    Widget stat(String label, String value, Color color) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: LBText.value(p, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: LBText.label(p, color: p.inkMuted),
                ),
              ),
            ],
          ),
        );
    Widget divider() => Container(
          width: 1,
          height: context.lbCell * 1.6,
          color: p.lime.withValues(alpha: .18),
        );
    return LBBlock(
      kind: LBBlockKind.outline,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          stat(scoreLabel, score, LB.gold),
          divider(),
          stat(lengthLabel, length, p.head),
          divider(),
          stat(timeLabel, time, p.ink),
        ],
      ),
    );
  }
}

class _PauseRow extends StatelessWidget {
  const _PauseRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.aside,
    this.kind = LBBlockKind.outline,
  });

  final LBIcon icon;
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
      height: context.lbCell * 3.5,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      // Icon, then the title with its hint UNDER it (side by side, the hint
      // was cut to "controls · …" / "run ends he…"), then an arrow.
      child: Row(
        children: [
          LBPixelIcon(icon, cell: 3.6, color: fg),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: LBText.button(
                      p,
                      color: fg,
                      size: 14,
                    ).copyWith(letterSpacing: 2.4),
                  ),
                ),
                if (aside != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    aside!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.body(
                      p,
                      color: fg.withValues(alpha: .72),
                      size: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          LBPixelIcon(LBIcon.next, cell: 2.4, color: fg.withValues(alpha: .7)),
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
          style: LBText.label(context.lb, color: color ?? context.lb.inkMuted)
              .copyWith(
                fontSize: 10,
                decoration: TextDecoration.underline,
                decorationColor: (color ?? context.lb.inkMuted).withValues(
                  alpha: .5,
                ),
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
    this.preview,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// What the gameplay screen looks like with this control, shown above the
  /// title so nobody has to pick blind. See ControlLayoutPreview.
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final kind = selected ? LBBlockKind.fill : LBBlockKind.outline;
    final fg = LBBlock.foregroundOf(kind, p);
    return Semantics(
      selected: selected,
      child: LBBlock(
        kind: kind,
        height: preview == null ? context.lbCell * 3.5 : null,
        padding: preview == null
            ? const EdgeInsets.symmetric(horizontal: 4)
            : const EdgeInsets.fromLTRB(5, 5, 5, 9),
        alignment: Alignment.center,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preview != null) ...[preview!, const SizedBox(height: 8)],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: LBText.button(
                  p,
                  color: fg,
                  size: 13,
                ).copyWith(letterSpacing: 1.6),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: LBText.body(
                  p,
                  color: fg.withValues(alpha: .7),
                  size: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
