import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/core/observability/error_classification.dart';

/// Guards the crash-vs-noise boundary.
///
/// The crash reporter was filing a failed Google avatar download as a fatal
/// exception, because the FlutterError handler reported everything as fatal.
/// That both depressed the crash-free rate Play ranks on and buried genuine
/// crashes.
///
/// The risk in fixing it is the opposite mistake — silently downgrading a real
/// crash — so the "must stay fatal" group below matters more than the other.
///
/// This exercises the PRODUCTION classifier directly. It used to hold a
/// hand-copied duplicate of a function private to main.dart, kept in lockstep
/// by discipline alone; the real one now lives in lib/core/observability/ and
/// is imported above, so the two can no longer drift apart.
///
/// The classifier is consumed by Sentry's `beforeSend` hook, which downgrades
/// a recoverable error's level to `warning` and marks it handled instead of
/// letting it count as a crash.
void main() {
  group('recoverable — must NOT be filed as a crash', () {
    test('the exact avatar failure from the field', () {
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
