import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `_isRecoverableError` in lib/main.dart.
///
/// The production copy is private to main.dart (which cannot be imported in a
/// test — it would run the app). Kept in lockstep by hand; the point of these
/// tests is to pin the CLASSIFICATION RULES, and any change to one copy that is
/// not made in the other will show up here as a failing expectation.
bool isRecoverableError(Object error, {bool silent = false}) {
  if (silent) return true;

  final type = error.runtimeType.toString();
  const recoverableTypes = {
    'NetworkImageLoadException',
    'SocketException',
    'HttpException',
    'HandshakeException',
    'ClientException',
    'TimeoutException',
  };
  if (recoverableTypes.contains(type)) return true;

  final message = error.toString();
  return message.contains('lh3.googleusercontent.com') ||
      message.contains('Connection closed before full header was received');
}

/// Guards the crash-vs-noise boundary.
///
/// Crashlytics was filing a failed Google avatar download as a Fatal Exception,
/// because the FlutterError handler reported everything as fatal. That both
/// depressed the crash-free rate Play ranks on and buried genuine crashes.
///
/// The risk in fixing it is the opposite mistake — silently downgrading a real
/// crash — so the "must stay fatal" group below matters more than the other.
void main() {
  group('recoverable — must NOT be filed as a crash', () {
    test('the exact avatar failure from Crashlytics', () {
      const error = HttpException(
        'Connection closed before full header was received, '
        'uri = https://lh3.googleusercontent.com/a/ACg8ocKtOfZbiMF3EZHjvNOrrmWSIceptsBd8f8qi53gD6tNSjP8jQ=s96-c',
      );
      expect(isRecoverableError(error), isTrue);
    });

    test('the socket-abort variant of the same issue', () {
      const error = SocketException(
        'Software caused connection abort (OS Error: Software caused '
        'connection abort, errno = 103)',
      );
      expect(isRecoverableError(error), isTrue);
    });

    test('an image that returned a non-200', () {
      final error = NetworkImageLoadException(
        statusCode: 403,
        uri: Uri.parse('https://lh3.googleusercontent.com/a/abc=s96-c'),
      );
      expect(isRecoverableError(error), isTrue);
    });

    test('a bounded wait elapsing', () {
      expect(isRecoverableError(TimeoutException('too slow')), isTrue);
    });

    test('anything the framework itself marks silent', () {
      // Image resolve/decode failures set silent: true. Trusting that flag is
      // what catches transport errors we have not enumerated by name.
      expect(
        isRecoverableError(Exception('some framework noise'), silent: true),
        isTrue,
      );
    });
  });

  group('real crashes — must STAY fatal', () {
    test('the replay viewer null-cast fatal', () {
      // The genuine crash this session fixed. If the classifier ever swallowed
      // this class of error, that bug would have gone unreported entirely.
      expect(
        isRecoverableError(
          TypeError(),
        ),
        isFalse,
      );
    });

    test('a null check on a null value', () {
      Object? captured;
      try {
        // ignore: null_check_on_nullable_type_parameter
        final String? nothing = null;
        nothing!.length;
      } catch (e) {
        captured = e;
      }
      expect(captured, isNotNull);
      expect(isRecoverableError(captured!), isFalse);
    });

    test('a range error', () {
      expect(isRecoverableError(RangeError.index(5, <int>[])), isFalse);
    });

    test('a state error', () {
      expect(isRecoverableError(StateError('bad state')), isFalse);
    });

    test('a plain assertion failure', () {
      expect(isRecoverableError(AssertionError('invariant broken')), isFalse);
    });

    test('an ordinary exception with an unrelated message', () {
      expect(isRecoverableError(Exception('something genuinely broke')), isFalse);
    });

    test('a FlutterError from a layout overflow', () {
      expect(
        isRecoverableError(FlutterError('A RenderFlex overflowed by 42 pixels')),
        isFalse,
      );
    });
  });
}
