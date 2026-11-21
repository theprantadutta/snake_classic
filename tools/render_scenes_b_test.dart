// Visual check of the Neon / Cyberpunk / Space / Crystal scenes without a
// device:
//   flutter test tools/render_scenes_b_test.dart
// Writes build/scene_<theme>_{phone,board,tablet}.png. Each render carries
// a mock card (cardBase + a white text bar) and, on the board, a mock snake
// in the theme's SnakeStyle plus food with its ring, so readability can be
// judged. Outside test/ so the normal suite never runs it.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/design/scenes/crystal.dart';
import 'package:snake_classic/design/scenes/cyberpunk.dart';
import 'package:snake_classic/design/scenes/neon.dart';
import 'package:snake_classic/design/scenes/space.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

Future<void> _render(String name, Size size, void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final image = await recorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory('build').createSync(recursive: true);
  File('build/scene_$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _card(Canvas c, Rect r, ThemeScene scene, LBPalette p, double s) {
  final rr = RRect.fromRectAndRadius(r, Radius.circular(s * .02));
  c.drawRRect(rr, Paint()..color = scene.cardBase);
  c.drawRRect(rr, Paint()..color = p.blockFill);
  c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .004
        ..color = p.blockStroke);
  final bar = Rect.fromLTWH(r.left + r.width * .08, r.top + r.height * .28,
      r.width * .55, r.height * .16);
  c.drawRect(bar, Paint()..color = Colors.white);
  final bar2 = Rect.fromLTWH(r.left + r.width * .08, r.top + r.height * .58,
      r.width * .38, r.height * .1);
  c.drawRect(bar2, Paint()..color = p.inkMuted);
  // A primary button.
  final b = Rect.fromLTWH(r.right - r.width * .3, r.top + r.height * .3,
      r.width * .22, r.height * .4);
  final g = scene.primaryGradient;
  c.drawRRect(
      RRect.fromRectAndRadius(b, Radius.circular(s * .01)),
      Paint()
        ..color = p.lime
        ..shader = g?.createShader(b));
  c.drawRect(
      Rect.fromCenter(center: b.center, width: b.width * .6, height: b.height * .2),
      Paint()..color = p.onLime);
}

void _header(Canvas c, Size size, ThemeScene scene, LBPalette p) {
  final r = Rect.fromLTWH(0, 0, size.width, size.height * .07);
  c.drawRect(r, Paint()..color = scene.headerBand);
  c.drawRect(
      Rect.fromLTWH(size.width * .06, r.height * .4, size.width * .3, r.height * .22),
      Paint()..color = p.ink);
}

void _grid(Canvas c, Size size, LBPalette p, int cells) {
  final paint = Paint()
    ..color = p.gridLine
    ..strokeWidth = 1;
  final cw = size.width / cells;
  for (var i = 1; i < cells; i++) {
    c.drawLine(Offset(i * cw, 0), Offset(i * cw, size.height), paint);
    c.drawLine(Offset(0, i * cw), Offset(size.width, i * cw), paint);
  }
}

void _snake(Canvas c, Size size, ThemeScene scene, LBPalette p, int cells) {
  final cell = size.width / cells;
  final style = scene.snakeStyle;
  // Head at (12,9), body trailing left then down.
  final pts = <Offset>[
    for (var i = 0; i < 6; i++) Offset(12.0 - i, 9),
    for (var i = 1; i <= 4; i++) Offset(7, 9.0 + i),
  ];
  final rects = [
    for (final q in pts)
      Rect.fromLTWH(q.dx * cell + cell * .06, q.dy * cell + cell * .06,
          cell * .88, cell * .88)
  ];
  final n = rects.length;
  final radius = Radius.circular(cell * .15);
  for (var i = n - 1; i >= 1; i--) {
    final t = i / (n - 1);
    final col = style.bodyAt(t, p.lime).withValues(alpha: 1 - style.tailFade * t);
    c.drawRRect(RRect.fromRectAndRadius(rects[i], radius), Paint()..color = col);
  }
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = cell * .07;
  for (var i = n - 1; i >= 1; i--) {
    final t = i / (n - 1);
    final r = rects[i];
    if (style.edge != null) {
      edge.color = style.edge!.withValues(alpha: .75 - .45 * t);
      c.drawRRect(RRect.fromRectAndRadius(r.deflate(cell * .035), radius), edge);
    }
    if (style.shine > 0) {
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(r.left + r.width * .18, r.top + r.height * .14,
                  r.width * .64, r.height * .16),
              Radius.circular(r.height * .08)),
          Paint()..color = Colors.white.withValues(alpha: style.shine));
    }
  }
  final head = rects.first;
  c.drawRRect(
      RRect.fromRectAndRadius(head.inflate(cell * .12), Radius.circular(cell * .3)),
      Paint()
        ..color = p.head.withValues(alpha: .45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .3));
  c.drawRRect(RRect.fromRectAndRadius(head, Radius.circular(cell * .3)),
      Paint()..color = p.head);
  // Food at (15, 6).
  final fc = Offset(15.5 * cell, 6.5 * cell);
  c.drawCircle(
      fc,
      cell * .5,
      Paint()
        ..color = p.food.withValues(alpha: .5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .3));
  c.drawCircle(fc, cell * .36, Paint()..color = p.food);
}

void main() {
  final scenes = <String, (GameTheme, ThemeScene)>{
    'neon': (GameTheme.neon, const NeonThemeScene()),
    'cyberpunk': (GameTheme.cyberpunk, const CyberpunkThemeScene()),
    'space': (GameTheme.space, const SpaceThemeScene()),
    'crystal': (GameTheme.crystal, const CrystalThemeScene()),
  };
  final only = Platform.environment['SCENE'];

  testWidgets('render theme scenes B', (tester) async {
    await tester.runAsync(() async {
      for (final e in scenes.entries) {
        if (only != null && only.isNotEmpty && !only.split(',').contains(e.key)) {
          continue;
        }
        final (theme, scene) = e.value;
        final p = LBPalette.of(theme);

        const phone = Size(1080, 2340);
        await _render('${e.key}_phone', phone, (c) {
          c.drawRect(Offset.zero & phone, Paint()..color = p.board);
          scene.paintBackdrop(c, phone, menu: true);
          _header(c, phone, scene, p);
          final s = math.min(phone.width, phone.height);
          for (var i = 0; i < 4; i++) {
            _card(c, Rect.fromLTWH(60, 420.0 + i * 420, 960, 300), scene, p, s);
          }
        });

        const board = Size(1000, 1000);
        await _render('${e.key}_board', board, (c) {
          c.drawRect(Offset.zero & board, Paint()..color = p.board);
          scene.paintBackdrop(c, board, menu: false);
          if (scene.hasMotion) scene.paintMotion(c, board, 3.7);
          _grid(c, board, p, 20);
          _snake(c, board, scene, p, 20);
        });

        const tablet = Size(1340, 800);
        await _render('${e.key}_tablet', tablet, (c) {
          c.drawRect(Offset.zero & tablet, Paint()..color = p.board);
          scene.paintBackdrop(c, tablet, menu: true);
          _header(c, tablet, scene, p);
          _card(c, const Rect.fromLTWH(220, 180, 900, 220), scene, p, 800);
          _card(c, const Rect.fromLTWH(220, 460, 900, 220), scene, p, 800);
        });
      }
    });
  });
}
