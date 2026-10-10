import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/game_bottom_bar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// A miniature of the gameplay screen with one control layout in place, so a
/// player can see what a choice gives them before they pick it.
///
/// It is the real screen scaled down rather than an illustration: the
/// control zone is the actual [GameBottomBar] (the same widget gameplay
/// builds) at a phone-sized frame, so the preview cannot drift from what the
/// game draws. Everything above the zone (HUD, level wall, board, info row)
/// is a lightweight stand-in, since only the zone differs between choices.
/// Inert by construction: no pointers, no semantics of its own.
class ControlLayoutPreview extends StatefulWidget {
  const ControlLayoutPreview({
    super.key,
    required this.dPadEnabled,
    required this.layout,
    required this.theme,
    this.dPadPosition = DPadPosition.bottomCenter,
  });

  /// False is swipe; true draws [layout].
  final bool dPadEnabled;
  final ControlLayout layout;
  final DPadPosition dPadPosition;
  final GameTheme theme;

  /// The logical frame the miniature is laid out in before scaling: a
  /// typical phone's play area under the banner.
  static const Size frame = Size(360, 700);

  @override
  State<ControlLayoutPreview> createState() => _ControlLayoutPreviewState();
}

class _ControlLayoutPreviewState extends State<ControlLayoutPreview> {
  // The swipe pad's compass needs a cue; the preview never swipes.
  final ValueNotifier<LBSwipeCue?> _cue = ValueNotifier(null);

  @override
  void dispose() {
    _cue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    const frame = ControlLayoutPreview.frame;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: AspectRatio(
          aspectRatio: frame.width / frame.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.board,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.lime.withValues(alpha: .22)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox.fromSize(
                  size: frame,
                  // Phone metrics inside the frame, whatever device shows
                  // the preview, so a tablet's settings screen previews the
                  // same layout a phone would get.
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: frame,
                      padding: EdgeInsets.zero,
                      viewPadding: EdgeInsets.zero,
                      textScaler: TextScaler.noScaling,
                    ),
                    child: _screen(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _screen(BuildContext context) {
    final p = context.lb;
    const side = 340.0;
    return Column(
      children: [
        // HUD stand-in: level pill and the pause button.
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _stub(p.lime.withValues(alpha: .7), 54, 16),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.lime.withValues(alpha: .4)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Level wall.
        SizedBox(
          width: side,
          height: 17,
          child: CustomPaint(painter: _WallPainter(p.lime)),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: side,
          height: side,
          child: CustomPaint(
            painter: _BoardPainter(
              board: p.board,
              line: p.lime.withValues(alpha: .09),
              wall: p.lime.withValues(alpha: .32),
              snake: p.lime,
              head: p.head,
              apple: LB.apple,
            ),
          ),
        ),
        // Info row stand-in.
        SizedBox(
          width: side,
          height: 40,
          child: Align(
            alignment: Alignment.centerRight,
            child: _stub(p.ink.withValues(alpha: .35), 110, 12),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, zone) => GameBottomBar(
              theme: widget.theme,
              isSmallScreen: false,
              height: zone.maxHeight,
              dPadEnabled: widget.dPadEnabled,
              dPadPosition: widget.dPadPosition,
              controlLayout: widget.layout,
              onDirection: (_) {},
              onRelativeTurn: (_) {},
              // Drawn live, not dimmed: this is how it looks mid-run.
              canSteerOverride: true,
              swipeZone: _swipePad(context, zone.maxHeight),
            ),
          ),
        ),
      ],
    );
  }

  /// Mirrors the gameplay swipe pad.
  Widget _swipePad(BuildContext context, double height) {
    final p = context.lb;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.lime.withValues(alpha: .03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.lime.withValues(alpha: .14)),
      ),
      child: Center(
        child: LBSwipeCompass(
          cue: _cue,
          size: ((height - 20) * .8).clamp(54, 150),
        ),
      ),
    );
  }

  static Widget _stub(Color color, double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(height / 3),
    ),
  );
}

class _WallPainter extends CustomPainter {
  _WallPainter(this.lime);

  final Color lime;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 20;
    final c = size.width / count;
    for (var i = 0; i < count; i++) {
      final lit = i < 7;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * c + 1, 0, c - 2, size.height - 3),
          Radius.circular(c * .22),
        ),
        Paint()..color = lime.withValues(alpha: lit ? .7 : .12),
      );
    }
  }

  @override
  bool shouldRepaint(_WallPainter old) => old.lime != lime;
}

/// A 20×20 board with a short snake heading toward an apple.
class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.board,
    required this.line,
    required this.wall,
    required this.snake,
    required this.head,
    required this.apple,
  });

  final Color board;
  final Color line;
  final Color wall;
  final Color snake;
  final Color head;
  final Color apple;

  static const _cells = 20;
  static const _body = [
    (5, 12),
    (6, 12),
    (7, 12),
    (8, 12),
    (8, 11),
    (8, 10),
    (9, 10),
    (10, 10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / _cells;
    canvas.drawRect(Offset.zero & size, Paint()..color = board);
    final grid = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (var i = 0; i <= _cells; i++) {
      canvas.drawLine(Offset(i * c, 0), Offset(i * c, size.height), grid);
      canvas.drawLine(Offset(0, i * c), Offset(size.width, i * c), grid);
    }
    RRect cell(int x, int y) => RRect.fromRectAndRadius(
      Rect.fromLTWH(x * c + c * .06, y * c + c * .06, c * .88, c * .88),
      Radius.circular(c * .22),
    );
    for (var i = 0; i < _body.length; i++) {
      final (x, y) = _body[i];
      final isHead = i == _body.length - 1;
      final t = i / (_body.length - 1);
      canvas.drawRRect(
        cell(x, y),
        Paint()..color = isHead ? head : snake.withValues(alpha: .55 + .45 * t),
      );
    }
    canvas.drawCircle(
      Offset(14.5 * c, 10.5 * c),
      c * .32,
      Paint()..color = apple,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = wall
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_BoardPainter old) => false;
}
