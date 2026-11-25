import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/app_release_policy.dart';
import 'package:snake_classic/services/app_release_service.dart';

/// Answers getAppRelease with a fixed policy row.
class _FakeApi implements ApiService {
  _FakeApi(this.row);
  final Map<String, dynamic>? row;
  String? askedFor;

  @override
  Future<Map<String, dynamic>?> getAppRelease(String platform) async {
    askedFor = platform;
    return row;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _row({String? url, String min = '8.1.1'}) => {
  'enabled': true,
  'latest_version': '8.2.0',
  'minimum_supported_version': min,
  'store_url': url,
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('android: below the minimum is required, Play listing as fallback', () async {
    final service = AppReleaseService.forTesting();
    final api = _FakeApi(_row());
    final prompt = await service.check(
      api: api,
      currentVersionOverride: '8.1.0',
      platformOverride: 'android',
      force: true,
    );
    expect(api.askedFor, 'android');
    expect(prompt, UpdatePrompt.required);
    expect(service.updateRequired, isTrue);
    expect(service.storeUrl, AppReleaseService.playStoreUrl);
  });

  test('android: a newer latest version alone shows nothing (Play owns it)', () async {
    final service = AppReleaseService.forTesting();
    final prompt = await service.check(
      api: _FakeApi(_row(min: '8.0.0')),
      currentVersionOverride: '8.1.0',
      platformOverride: 'android',
      force: true,
    );
    expect(prompt, UpdatePrompt.none);
    expect(service.updateRequired, isFalse);
    expect(service.storeUrl, isNull);
  });

  test('android: the dashboard store URL wins over the default', () async {
    final service = AppReleaseService.forTesting();
    await service.check(
      api: _FakeApi(_row(url: 'https://play.google.com/store/apps/details?id=x')),
      currentVersionOverride: '8.1.0',
      platformOverride: 'android',
      force: true,
    );
    expect(service.storeUrl, 'https://play.google.com/store/apps/details?id=x');
  });

  test('ios: the optional notice still shows', () async {
    final service = AppReleaseService.forTesting();
    final prompt = await service.check(
      api: _FakeApi(_row(url: 'https://apps.apple.com/app/id6779621362', min: '8.0.0')),
      currentVersionOverride: '8.1.0',
      platformOverride: 'ios',
      force: true,
    );
    expect(prompt, UpdatePrompt.optional);
    expect(service.storeUrl, 'https://apps.apple.com/app/id6779621362');
  });

  test('ios: no store URL means no destination', () async {
    final service = AppReleaseService.forTesting();
    await service.check(
      api: _FakeApi(_row()),
      currentVersionOverride: '8.1.0',
      platformOverride: 'ios',
      force: true,
    );
    expect(service.storeUrl, isNull);
  });
}
