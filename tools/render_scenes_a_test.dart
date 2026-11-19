// Visual check of the Classic / Modern / Retro scenes without a device:
//   flutter test tools/render_scenes_a_test.dart
// Writes build/scene_<theme>_{menu,board,wide}.png. Each render is drawn at
// logical size then scaled to the output, like a real device: the phone
// menu is 360x780 dp at 3x, the board is the 20x20 world (400 units) at
// 2.5x, the wide shot is a 1340x800 dp tablet at 1x. Mock cards, a header,
// a primary button and a snake are drawn on top to judge readability.
// Outside test/ so the normal suite never runs it.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/design/scenes/classic.dart';
import 'package:snake_classic/design/scenes/modern.dart';
import 'package:snake_classic/design/scenes/retro.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

Future<void> _render(String name, Size logical, double scale,
    void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(scale);
  draw(canvas);
  final image = await recorder.endRecording().toImage(
      (logical.width * scale).round(), (logical.height * scale).round());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory('build').createSync(recursive: true);
  File('build/scene_$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _grid(Canvas c, Size size, double cell, Color color) {
  final p = Paint()
    ..color = color
    ..strokeWidth = 1;
  final x0 = (size.width % cell) / 2;
  for (var x = x0; x <= size.width; x += cell) {
    c.drawLine(Offset(x, 0), Offset(x, size.height), p);
  }
  for (var y = 0.0; y <= size.height; y += cell) {
    c.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
}

void _textBar(Canvas c, double x, double y, double w, double h, Color color) =>
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(h / 2)),
        Paint()..color = color);

/// An outlined LBBlock: cardBase under a translucent lime fill + stroke.
void _card(Canvas c, Rect r, ThemeScene scene, LBPalette p) {
  final rr = RRect.fromRectAndRadius(r, const Radius.circular(LB.blockRadius));
  c.drawRRect(rr, Paint()..color = scene.cardBase);
  c.drawRRect(rr, Paint()..color = p.blockFill);
  c.drawRRect(
      rr.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = p.blockStroke);
  _textBar(c, r.left + 14, r.top + 14, r.width * .5, 9, p.ink);
  _textBar(c, r.left + 14, r.top + 32, r.width * .7, 6, p.inkMuted);
  _textBar(c, r.left + 14, r.top + 46, r.width * .4, 6, p.inkDim);
}

void _primary(Canvas c, Rect r, ThemeScene scene, LBPalette p) {
  final rr = RRect.fromRectAndRadius(r, const Radius.circular(LB.blockRadius));
  final g = scene.primaryGradient;
  c.drawRRect(rr,
      g != null ? (Paint()..shader = g.createShader(r)) : (Paint()..color = p.lime));
  _textBar(c, r.center.dx - 30, r.center.dy - 5, 60, 10, p.onLime);
}

void _menu(Canvas c, Size size, ThemeScene scene, LBPalette p, double cell) {
  scene.paintBackdrop(c, size, menu: true);
  _grid(c, size, cell, p.gridLine);
  // Pinned header.
  c.drawRect(Rect.fromLTWH(0, 0, size.width, 64), Paint()..color = scene.headerBand);
  _textBar(c, 20, 30, 120, 12, p.ink);
  // Big title on the bare art (home logo area).
  _textBar(c, 20, 110, size.width * .55, 22, p.lime);
  _textBar(c, 20, 142, size.width * .4, 8, p.inkMuted);
  final w = (size.width - 40).clamp(0.0, 560.0);
  var y = 180.0;
  for (var i = 0; i < 3; i++) {
    _card(c, Rect.fromLTWH(20, y, w, 66), scene, p);
    y += 80;
  }
  _primary(c, Rect.fromLTWH(20, y + 10, w, 52), scene, p);
}

void _board(Canvas c, ThemeScene scene, LBPalette p) {
  const size = Size(400, 400);
  c.drawRect(Offset.zero & size, Paint()..color = p.board);
  scene.paintBackdrop(c, size, menu: false);
  if (scene.hasMotion) scene.paintMotion(c, size, 7.3);
  _grid(c, size, 20, p.lime.withValues(alpha: .09));
  // Ghost score "120" stand-in.
  if (scene.busyBoard) {
    c.drawRect(const Rect.fromLTWH(140, 160, 120, 60),
        Paint()..color = Colors.black.withValues(alpha: .38));
  }
  c.drawRect(const Rect.fromLTWH(140, 160, 120, 60),
      Paint()..color = p.lime.withValues(alpha: scene.busyBoard ? .14 : .08));
  // Snake: head at (9,9) heading right, body trailing left and down.
  const cells = [(9, 9), (8, 9), (7, 9), (6, 9), (6, 10), (6, 11), (5, 11),
      (4, 11), (3, 11), (3, 12)];
  final style = scene.snakeStyle;
  final n = cells.length;
  final body = Paint();
  for (var i = n - 1; i >= 1; i--) {
    final t = i / (n - 1);
    body.color = style.bodyAt(t, p.lime).withValues(alpha: 1 - style.tailFade * t);
    final (x, y) = cells[i];
    final r = Rect.fromLTWH(x * 20.0 + 1, y * 20.0 + 1, 18, 18);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), body);
    if (style.edge != null) {
      c.drawRRect(
          RRect.fromRectAndRadius(r.deflate(.7), const Radius.circular(3)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = style.edge!.withValues(alpha: .75 - .45 * t));
    }
    if (style.shine > 0) {
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(r.left + r.width * .18, r.top + r.height * .14,
                  r.width * .64, r.height * .16),
              const Radius.circular(1.5)),
          Paint()..color = Colors.white.withValues(alpha: style.shine));
    }
  }
  final head = Rect.fromLTWH(9 * 20.0 + 1, 9 * 20.0 + 1, 18, 18);
  c.drawRRect(RRect.fromRectAndRadius(head.inflate(2.4), const Radius.circular(6)),
      Paint()
        ..color = p.head.withValues(alpha: .45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  c.drawRRect(RRect.fromRectAndRadius(head, const Radius.circular(5)),
      Paint()..color = p.head);
  // Food at (14, 6), plus one near the edge at (1, 2).
  for (final (fx, fy) in const [(14, 6), (1, 2)]) {
    final fc = Offset(fx * 20.0 + 10, fy * 20.0 + 10);
    final ring = scene.foodRing;
    if (ring != null) {
      c.drawCircle(fc, 9.5, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = ring.withValues(alpha: .8));
    }
    c.drawCircle(fc, 7, Paint()..color = p.food);
    c.drawCircle(fc + const Offset(-2, -2), 2, Paint()..color = Colors.white70);
  }
}

void main() {
  testWidgets('render scenes A', (tester) async {
    await tester.runAsync(() async {
      final scenes = <String, (GameTheme, ThemeScene)>{
        'classic': (GameTheme.classic, const ClassicThemeScene()),
        'modern': (GameTheme.modern, const ModernThemeScene()),
        'retro': (GameTheme.retro, const RetroThemeScene()),
      };
      for (final MapEntry(key: name, value: (theme, scene)) in scenes.entries) {
        final p = LBPalette.of(theme);
        const phone = Size(360, 780);
        await _render('${name}_menu', phone, 3,
            (c) => _menu(c, phone, scene, p, 20));
        await _render('${name}_board', const Size(400, 400), 2.5,
            (c) => _board(c, scene, p));
        const wide = Size(1340, 800);
        await _render('${name}_wide', wide, 1,
            (c) => _menu(c, wide, scene, p, 27));
      }
    });
  });
}
