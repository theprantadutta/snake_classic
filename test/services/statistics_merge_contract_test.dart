import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/sync/statistics_merge.dart';

/// Drift guard between the Dart and C# statistics merge rules.
///
/// The two implementations live in separate repositories, so neither can read
/// the other's source in CI. Instead both assert against a fixture that is
/// byte-identical in each repo. Add a counter on one side only and that side
/// fails here; update the fixture to fix it and the other repo starts failing
/// until it catches up.
///
/// The C# half is
/// `tests/SnakeClassic.Application.Tests/Sync/StatisticsMergeContractTests.cs`.
void main() {
  Map<String, dynamic> loadContract() {
    final file = File('test/fixtures/statistics_merge_contract.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'Merge contract fixture missing at ${file.path}. It is not '
          'optional — without it this test would pass vacuously and the '
          'Dart/C# lists could drift apart unnoticed.',
    );
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  List<String> stringList(Object? value) =>
      (value as List).cast<String>().toList()..sort();

  test('monotonic counter fields match the shared contract exactly', () {
    final contract = loadContract();

    // Order-insensitive but membership-exact: the fold iterates the list, so
    // order is irrelevant, but a missing or extra name is a real defect.
    expect(
      [...kStatsMonotonicFields]..sort(),
      stringList(contract['monotonicLongFields']),
    );
  });

  test('monotonic map fields match the shared contract exactly', () {
    final contract = loadContract();

    expect(
      [...kStatsMonotonicMapFields]..sort(),
      stringList(contract['monotonicMapFields']),
    );
  });

  test('gameModeCount is covered — it was missing from both sides', () {
    // Pinned by name because this one had a real bug: the field is serialised
    // in the model JSON and read by the per-mode achievement evaluators, but
    // was absent from both merge lists, so two devices playing different
    // modes overwrote each other's counts.
    expect(kStatsMonotonicMapFields, contains('gameModeCount'));
    expect(
      stringList(loadContract()['monotonicMapFields']),
      contains('gameModeCount'),
    );
  });

  test('contract declares a version so a stale copy is detectable', () {
    expect(loadContract()['version'], isA<int>());
    expect(loadContract()['version'], greaterThan(0));
  });
}
