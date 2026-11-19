import 'dart:async';

import 'package:snake_classic/widgets/lb/lb_block.dart';

/// Runs before every test file in this directory tree.
///
/// The idle glow pulse on primary blocks loops forever, which would make
/// every `pumpAndSettle` on a screen with a primary button time out. Tests
/// that cover the pulse turn it back on themselves.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LBBlock.idleGlowPulse = false;
  await testMain();
}
