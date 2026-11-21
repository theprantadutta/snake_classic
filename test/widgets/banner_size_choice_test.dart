import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';

void main() {
  group('useLargeBanner', () {
    test('every non-gameplay placement is large, on any screen', () {
      for (final s in const [Size(320, 568), Size(384, 832), Size(1280, 800)]) {
        expect(useLargeBanner(gameplay: false, screen: s), isTrue, reason: '$s');
      }
    });

    test('gameplay is large on tall portrait phones (A24 384x832)', () {
      expect(useLargeBanner(gameplay: true, screen: const Size(384, 832)),
          isTrue);
      expect(useLargeBanner(gameplay: true, screen: const Size(360, 780)),
          isTrue);
    });

    test('gameplay keeps the classic size on short phones', () {
      for (final s in const [Size(320, 568), Size(360, 640), Size(360, 760)]) {
        expect(useLargeBanner(gameplay: true, screen: s), isFalse, reason: '$s');
      }
    });

    test('gameplay keeps the classic size in landscape', () {
      expect(useLargeBanner(gameplay: true, screen: const Size(1280, 800)),
          isFalse);
    });
  });
}
