import 'package:flutter/material.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Small Living Board pieces shared by the in-run overlays, the ad surfaces,
/// the walkthrough and the steering controls. Visual only: nothing here owns
/// input, timers or callbacks.

/// A pixel arrow pointing in a board [direction]. Left/right are the kit's
/// `back` / `next` icons; up/down are `next` turned a quarter.
class LBArrowIcon extends StatelessWidget {
  const LBArrowIcon({super.key, required this.direction, this.cell = 3, this.color});

  final Direction direction;
  final double cell;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case Direction.left:
        return LBPixelIcon(LBIcon.back, cell: cell, color: color);
      case Direction.right:
        return LBPixelIcon(LBIcon.next, cell: cell, color: color);
      case Direction.up:
        return RotatedBox(quarterTurns: 3, child: LBPixelIcon(LBIcon.next, cell: cell, color: color));
      case Direction.down:
        return RotatedBox(quarterTurns: 1, child: LBPixelIcon(LBIcon.next, cell: cell, color: color));
    }
  }
}

/// A 5×5 "turn" glyph: an arrow that bends toward [left] or right, drawn in
/// the same rounded cells as [LBPixelIcon].
class LBTurnGlyph extends StatelessWidget {
  const LBTurnGlyph({super.key, required this.left, this.cell = 4, this.color});

  final bool left;
  final double cell;
  final Color? color;

  static const List<String> _left = ['.x...', 'xxxx.', '.x.x.', '...x.', '...x.'];

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? context.lb.lime;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(cell * 5),
        painter: _GlyphPainter(_left, cell, c, mirror: !left),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.rows, this.cell, this.color, {this.mirror = false});

  final List<String> rows;
  final double cell;
  final Color color;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        if (rows[r][c] != 'x') continue;
        final col = mirror ? rows[r].length - 1 - c : c;
        path.addRRect(lbCellRect(col * cell, r * cell, cell));
      }
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.cell != cell || old.color != color || old.mirror != mirror || old.rows != rows;
}

/// An indeterminate "working on it" row of cells: one lit cell walks left to
/// right. Replaces the Material spinner on loading beats.
class LBCellSpinner extends StatefulWidget {
  const LBCellSpinner({super.key, this.count = 5, this.cell = 8, this.color});

  final int count;
  final double cell;
  final Color? color;

  @override
  State<LBCellSpinner> createState() => _LBCellSpinnerState();
}

class _LBCellSpinnerState extends State<LBCellSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 110 * widget.count),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final color = widget.color ?? p.lime;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final head = (_c.value * widget.count).floor() % widget.count;
          return LBCellsBar(
            count: widget.count,
            value: 1,
            cell: widget.cell,
            colorAt: (i) {
              final behind = (head - i) % widget.count;
              return switch (behind) {
                0 => color,
                1 => color.withValues(alpha: .45),
                _ => color.withValues(alpha: .13),
              };
            },
          );
        },
      ),
    );
  }
}

/// Step progress as a row of cells: done cells half-lit, the current one
/// fully lit, the rest off.
class LBStepCells extends StatelessWidget {
  const LBStepCells({super.key, required this.total, required this.index, this.cell = 8});

  final int total;
  final int index;
  final double cell;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    if (total <= 0) return const SizedBox.shrink();
    return LBCellsBar(
      count: total,
      value: 1,
      cell: cell,
      colorAt: (i) => i == index
          ? p.lime
          : i < index
              ? p.lime.withValues(alpha: .45)
              : p.cellOff,
    );
  }
}

/// The two-cell switch face (`[lit grey][off]` / `[off][lit lime]`) without
/// its own gesture handling, for rows that own the tap themselves.
class LBSwitchFace extends StatelessWidget {
  const LBSwitchFace({super.key, required this.value, this.cell = 16, this.enabled = true});

  final bool value;
  final double cell;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value ? 1 : 0),
      duration: const Duration(milliseconds: 140),
      builder: (context, t, _) => CustomPaint(
        size: Size(cell * 2, cell),
        painter: _SwitchFacePainter(
          t: t,
          cell: cell,
          on: Color.lerp(p.inkDim, p.lime, t)!.withValues(alpha: enabled ? 1 : .4),
          off: p.cellOff,
        ),
      ),
    );
  }
}

class _SwitchFacePainter extends CustomPainter {
  _SwitchFacePainter({required this.t, required this.cell, required this.on, required this.off});

  final double t;
  final double cell;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(lbCellRect(0, 0, cell), Paint()..color = off);
    canvas.drawRRect(lbCellRect(cell, 0, cell), Paint()..color = off);
    canvas.drawRRect(lbCellRect(cell * t, 0, cell), Paint()..color = on);
  }

  @override
  bool shouldRepaint(_SwitchFacePainter old) =>
      old.t != t || old.cell != cell || old.on != on || old.off != off;
}

/// Living Board look for a [TextButton] that must stay a TextButton (skip
/// links whose tests and semantics rely on it).
ButtonStyle lbTextButtonStyle(LBPalette p, {Color? color}) => TextButton.styleFrom(
      foregroundColor: color ?? p.inkMuted,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LB.blockRadius)),
      textStyle: LBText.button(p, size: 11.5).copyWith(
        letterSpacing: 1.6,
        decoration: TextDecoration.underline,
      ),
    );

/// Material icons that callers still pass in (as data on public APIs) and
/// their pixel equivalents. Anything unmapped falls back to the Material
/// glyph so meaning is never lost.
final Map<IconData, LBIcon> _iconMap = {
  Icons.monetization_on: LBIcon.coin,
  Icons.celebration: LBIcon.star,
  Icons.bolt: LBIcon.bolt,
  Icons.flash_on: LBIcon.bolt,
  Icons.speed: LBIcon.bolt,
  Icons.emoji_events: LBIcon.trophy,
  Icons.check_rounded: LBIcon.check,
  Icons.check: LBIcon.check,
  Icons.check_circle: LBIcon.check,
  Icons.info_outline_rounded: LBIcon.eye,
  Icons.info_outline: LBIcon.eye,
  Icons.error_outline_rounded: LBIcon.x,
  Icons.error_outline: LBIcon.x,
  Icons.close: LBIcon.x,
  Icons.sports_esports: LBIcon.swords,
  Icons.calendar_today: LBIcon.calendar,
  Icons.help_outline: LBIcon.eye,
  Icons.school: LBIcon.star,
  Icons.dashboard: LBIcon.grid,
  Icons.swipe: LBIcon.next,
  Icons.arrow_forward: LBIcon.next,
  Icons.arrow_back: LBIcon.back,
  Icons.gamepad: LBIcon.plus,
  Icons.restaurant: LBIcon.apple,
  Icons.local_fire_department: LBIcon.flame,
  Icons.warning_amber: LBIcon.skull,
  Icons.warning_amber_rounded: LBIcon.bolt,
  Icons.do_not_disturb_on: LBIcon.x,
  Icons.pause_circle_outline: LBIcon.pause,
  Icons.analytics: LBIcon.chart,
  Icons.insights_rounded: LBIcon.chart,
  Icons.games: LBIcon.play,
  Icons.play_circle_fill: LBIcon.play,
  Icons.settings: LBIcon.gear,
  Icons.person: LBIcon.user,
  Icons.star: LBIcon.star,
  Icons.favorite: LBIcon.heart,
  Icons.timer: LBIcon.hourglass,
  Icons.lock: LBIcon.lock,
  Icons.share: LBIcon.invite,
  Icons.people: LBIcon.friends,
  Icons.videogame_asset_rounded: LBIcon.plus,
  Icons.music_note: LBIcon.music,
  Icons.volume_up: LBIcon.sound,
  Icons.workspace_premium: LBIcon.crown,
  Icons.shield: LBIcon.shield,
  Icons.card_giftcard: LBIcon.gift,
};

/// The pixel icon for a Material [icon], or null when there is none.
LBIcon? lbIconFor(IconData? icon) => icon == null ? null : _iconMap[icon];

/// Draws [icon] as its pixel equivalent (see [lbIconFor]), or as the Material
/// glyph at the same size when the kit has no match.
class LBMappedIcon extends StatelessWidget {
  const LBMappedIcon(this.icon, {super.key, this.cell = 3, this.color});

  final IconData icon;
  final double cell;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (icon == Icons.arrow_upward || icon == Icons.arrow_upward_rounded) {
      return LBArrowIcon(direction: Direction.up, cell: cell, color: color);
    }
    if (icon == Icons.arrow_downward || icon == Icons.arrow_downward_rounded) {
      return LBArrowIcon(direction: Direction.down, cell: cell, color: color);
    }
    final mapped = lbIconFor(icon);
    if (mapped != null) return LBPixelIcon(mapped, cell: cell, color: color);
    return Icon(icon, size: cell * 5, color: color ?? DefaultTextStyle.of(context).style.color);
  }
}
