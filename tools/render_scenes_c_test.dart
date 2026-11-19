// Visual check of the Ocean, Forest and Desert scenes without a device:
//   flutter test tools/render_scenes_c_test.dart
// Writes build/scene_<theme>_{phone,board,tablet}.png. Each image has a
// mock card + button (menus) or a mock snake + food (board) so contrast
// can be judged. Outside test/ so the normal suite never runs it.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/design/scenes/desert.dart';
import 'package:snake_classic/design/scenes/forest.dart';
import 'package:snake_classic/design/scenes/ocean.dart';
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

void _menuMocks(Canvas c, Size size, ThemeScene scene, LBPalette p) {
  final w = size.width;
  final u = math.min(w, size.height) / 360; // ~dp
  // Pinned header band.
  c.drawRect(Rect.fromLTWH(0, 0, w, 64 * u), Paint()..color = scene.headerBand);
  c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(20 * u, 26 * u, 120 * u, 14 * u), Radius.circular(3 * u)),
      Paint()..color = p.ink);
  // Title text straight on the art (no card).
  c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(20 * u, 90 * u, 180 * u, 22 * u), Radius.circular(4 * u)),
      Paint()..color = p.ink);
  c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(20 * u, 120 * u, 130 * u, 10 * u), Radius.circular(3 * u)),
      Paint()..color = p.inkMuted);
  // Outlined card.
  final card = Rect.fromLTWH(20 * u, 150 * u, w - 40 * u, 100 * u);
  final rr = RRect.fromRectAndRadius(card, Radius.circular(6 * u));
  c.drawRRect(rr, Paint()..color = scene.cardBase);
  c.drawRRect(rr, Paint()..color = p.blockFill);
  c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * u
        ..color = p.blockStroke);
  for (var i = 0; i < 3; i++) {
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(card.left + 16 * u, card.top + (18 + i * 26) * u,
                (i == 0 ? 160 : 220 - i * 40) * u, (i == 0 ? 14 : 9) * u),
            Radius.circular(3 * u)),
        Paint()..color = i == 0 ? p.ink : p.inkMuted);
  }
  // Primary button.
  final btn = Rect.fromLTWH(20 * u, 270 * u, w - 40 * u, 48 * u);
  final g = scene.primaryGradient;
  c.drawRRect(
      RRect.fromRectAndRadius(btn, Radius.circular(6 * u)),
      Paint()
        ..color = p.lime
        ..shader = g?.createShader(btn));
  c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: btn.center, width: 90 * u, height: 14 * u),
          Radius.circular(3 * u)),
      Paint()..color = p.onLime);
  // Secondary text line on the art lower down.
  c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(20 * u, 340 * u, 200 * u, 10 * u), Radius.circular(3 * u)),
      Paint()..color = p.inkDim);
}

void _boardMocks(Canvas c, Size size, ThemeScene scene, LBPalette p) {
  const n = 20;
  final cell = size.width / n;
  final grid = Paint()
    ..color = p.gridLine
    ..strokeWidth = 1;
  for (var i = 1; i < n; i++) {
    c.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), grid);
    c.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), grid);
  }
  // Snake: head at (12,9) going right, body bends down-left.
  const cells = [
    [12, 9], [11, 9], [10, 9], [9, 9], [8, 9], [8, 10], [8, 11], [8, 12],
    [7, 12], [6, 12], [5, 12],
  ];
  final rects = [
    for (final cc in cells)
      Rect.fromLTWH(cc[0] * cell, cc[1] * cell, cell, cell).deflate(cell * .05),
  ];
  final style = scene.snakeStyle;
  final nn = rects.length;
  final body = Paint();
  for (var i = nn - 1; i >= 1; i--) {
    final t = i / (nn - 1);
    body.color = style.bodyAt(t, p.lime).withValues(alpha: 1 - style.tailFade * t);
    c.drawRRect(RRect.fromRectAndRadius(rects[i], Radius.circular(cell * .15)), body);
  }
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = cell * .07;
  final shine = Paint()..color = Colors.white.withValues(alpha: style.shine);
  for (var i = nn - 1; i >= 1; i--) {
    final t = i / (nn - 1);
    final r = rects[i];
    if (style.edge != null) {
      edge.color = style.edge!.withValues(alpha: .75 - .45 * t);
      c.drawRRect(
          RRect.fromRectAndRadius(r.deflate(cell * .035), Radius.circular(cell * .15)),
          edge);
    }
    if (style.shine > 0) {
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(r.left + r.width * .18, r.top + r.height * .14,
                  r.width * .64, r.height * .16),
              Radius.circular(r.height * .08)),
          shine);
    }
  }
  final head = rects.first;
  c.drawRRect(
      RRect.fromRectAndRadius(head.inflate(cell * .12), Radius.circular(cell * .3)),
      Paint()
        ..color = p.head.withValues(alpha: .45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .3));
  c.drawRRect(RRect.fromRectAndRadius(head, Radius.circular(cell * .25)),
      Paint()..color = p.head);
  // Food at (15,6) and one near the bottom-left art (3,17).
  for (final f in const [Offset(15.5, 6.5), Offset(3.5, 17.5), Offset(16.5, 3.5)]) {
    final fc = f * cell;
    final ring = scene.foodRing;
    if (ring != null) {
      c.drawCircle(
          fc,
          cell * .58,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * .07
            ..color = ring.withValues(alpha: .85));
    }
    c.drawCircle(fc, cell * .36, Paint()..color = p.food);
    c.drawCircle(fc + Offset(-cell * .1, -cell * .1), cell * .1,
        Paint()..color = Colors.white.withValues(alpha: .6));
  }
}

void main() {
  final scenes = <String, (GameTheme, ThemeScene)>{
    'ocean': (GameTheme.ocean, const OceanThemeScene()),
    'forest': (GameTheme.forest, const ForestThemeScene()),
    'desert': (GameTheme.desert, const DesertThemeScene()),
  };
  final only = Platform.environment['SCENE'];
  testWidgets('render ocean/forest/desert scenes', (tester) async {
    await tester.runAsync(() async {
      for (final e in scenes.entries) {
        if (only != null && only.isNotEmpty && only != e.key) continue;
        final (theme, scene) = e.value;
        final p = LBPalette.of(theme);
        const phone = Size(1080, 2340);
        await _render('${e.key}_phone', phone, (c) {
          c.drawRect(Offset.zero & phone, Paint()..color = p.board);
          scene.paintBackdrop(c, phone, menu: true);
          _menuMocks(c, phone, scene, p);
        });
        const board = Size(1000, 1000);
        await _render('${e.key}_board', board, (c) {
          c.drawRect(Offset.zero & board, Paint()..color = p.board);
          scene.paintBackdrop(c, board, menu: false);
          if (scene.hasMotion) scene.paintMotion(c, board, 3.7);
          _boardMocks(c, board, scene, p);
        });
        const tablet = Size(1340, 800);
        await _render('${e.key}_tablet', tablet, (c) {
          c.drawRect(Offset.zero & tablet, Paint()..color = p.board);
          scene.paintBackdrop(c, tablet, menu: true);
          _menuMocks(c, tablet, scene, p);
        });
        // Clean art, no mocks, to judge the painting itself.
        await _render('${e.key}_art', phone, (c) {
          scene.paintBackdrop(c, phone, menu: false);
        });
      }
    });
  });
}
