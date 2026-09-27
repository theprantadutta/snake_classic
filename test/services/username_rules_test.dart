import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/username_service.dart';

/// The client's username rules must reject everything the server's
/// SetUsernameCommandValidator rejects. When they drifted, names the client
/// accepted went to PUT /users/username and came back as validation
/// failures (SNAKE-CLASSIC-API-10).
void main() {
  final service = UsernameService();
  bool valid(String name) => service.validateUsername(name).isValid;

  test('rejects the shapes the server regex refuses', () {
    for (final name in [
      'Jürgen',
      'Max Power',
      'snake-fan',
      'first.last',
      '1stPlace',
      '_leading',
      'ab',
      'a' * 21,
    ]) {
      expect(valid(name), isFalse, reason: name);
    }
    expect(valid('Swift_Viper_42'), isTrue);
  });

  test('every server reserved word is reserved on the client too', () {
    final validator = File(
      '../snake-classic-backend/src/SnakeClassic.Application/Features/Users/'
      'Commands/SetUsername/SetUsernameCommandValidator.cs',
    );
    if (!validator.existsSync()) {
      markTestSkipped('backend repo not checked out beside the app');
      return;
    }
    final block = RegExp(
      r'ReservedWords\s*=\s*new\([^)]*\)\s*\{([^}]*)\}',
    ).firstMatch(validator.readAsStringSync())!.group(1)!;
    final serverWords = RegExp(r'"([^"]+)"')
        .allMatches(block)
        .map((m) => m.group(1)!)
        .toList();

    expect(serverWords, isNotEmpty);
    for (final word in serverWords) {
      // Reserved words are 3+ chars except "ban"/"mod"/"dev"; either way the
      // client must not call them valid.
      expect(valid(word), isFalse, reason: word);
      expect(valid(word.toUpperCase()), isFalse, reason: word.toUpperCase());
    }
  });

  test('generated names always fit the server limits', () {
    final random = Random(7);
    for (var i = 0; i < 2000; i++) {
      final name = service.generateRandomUsername();
      expect(valid(name), isTrue, reason: name);
    }
    // The longest pair in either word list, which used to overflow.
    final longest =
        UsernameService.composeGeneratedName('Lightning', 'Guardian', random);
    expect(longest.length, lessThanOrEqualTo(UsernameService.maxLength));
    expect(valid(longest), isTrue, reason: longest);
  });
}
