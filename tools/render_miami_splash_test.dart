// Renders the Miami Nights native-splash background from the same scene the
// app paints, so the launch screen and the in-app theme match exactly.
//
//   flutter test tools/render_miami_splash_test.dart
//
// Writes assets/splash/miami_nights_bg.png (1290x2796, a 19.5:9 portrait
// that covers phones; iOS and Android scale it to fill). Lives outside test/
// so the normal suite never runs it.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/miami_nights_scene.dart';

void main() {
  testWidgets('render Miami Nights splash background', (tester) async {
    await tester.runAsync(() async {
      const size = Size(1290, 2796);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // Slightly dimmed and with a soft sun so the centred logo stays the
      // hero; the floor grid stays bright, it's the signature of the look.
      MiamiNightsScene.paint(canvas, size, dim: .12, sun: .85);
      final image = await recorder
          .endRecording()
          .toImage(size.width.toInt(), size.height.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('assets/splash/miami_nights_bg.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
