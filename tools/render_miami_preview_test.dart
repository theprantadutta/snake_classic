// Visual check of the Miami Nights scene without a device:
//   flutter test tools/render_miami_preview_test.dart
// Writes build/miami_preview_{board,menu,wide}.png. Outside test/ so the
// normal suite never runs it.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/miami_nights_scene.dart';

Future<void> _render(String name, Size size, void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final image = await recorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory('build').createSync(recursive: true);
  File('build/miami_preview_$name.png')
      .writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render Miami previews', (tester) async {
    await tester.runAsync(() async {
      const board = Size(1000, 1000);
      await _render('board', board, (c) {
        MiamiNightsScene.paint(c, board, dim: .3, animatedFloor: true);
        MiamiNightsScene.paintFloorMotion(c, board, 1.1, dim: .3);
      });
      const menu = Size(1080, 2340);
      await _render('menu', menu, (c) {
        MiamiNightsScene.paint(c, menu,
            dim: .5, lines: .4, sun: .55, horizonVeil: .45);
      });
      const wide = Size(1340, 800);
      await _render('wide', wide, (c) {
        MiamiNightsScene.paint(c, wide, dim: .15, sun: .85);
      });
    });
  });
}
