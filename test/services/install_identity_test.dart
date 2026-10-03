import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/config/ui_design.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';
import 'package:uuid/uuid.dart';

void main() {
  Future<PackageInfo> info() async => PackageInfo(
        appName: 'Snake Classic',
        packageName: 'com.pranta.snakeclassic',
        version: '6.8.0',
        buildNumber: '60',
      );

  setUp(InstallIdentity.resetForTest);
  tearDown(InstallIdentity.resetForTest);

  test('mints a v4 install id once and keeps it across launches', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await InstallIdentity.load(packageInfo: info);
    expect(Uuid.isValidUUID(fromString: first.installId), isTrue);
    expect(first.appVersion, '6.8.0');
    expect(first.build, 60);
    expect(first.design, kUiDesign);

    InstallIdentity.resetForTest(); // a new process
    final second = await InstallIdentity.load(packageInfo: info);
    expect(second.installId, first.installId);
  });

  test('every request carries the install and build headers', () async {
    expect(InstallIdentity.clientHeaders.keys,
        containsAll(['X-Platform', 'X-UI-Design']),
        reason: 'known even before load');
    expect(InstallIdentity.clientHeaders['X-UI-Design'], kUiDesign);

    SharedPreferences.setMockInitialValues({});
    final id = await InstallIdentity.load(packageInfo: info);
    expect(InstallIdentity.clientHeaders, {
      'X-Install-Id': id.installId,
      'X-App-Version': '6.8.0',
      'X-App-Build': '60',
      'X-Platform': InstallIdentity.platformName,
      'X-UI-Design': kUiDesign,
    });
  });
}
