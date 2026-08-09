import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/sync/statistics_merge.dart';

/// Drift guard between the Dart and C# statistics merge rules.
///
/// The two implementations live in separate repositories, which is what makes
/// this awkward. There are two layers, and they catch different things:
///
///   * The same-repo tests below assert this repo's field lists against this
///     repo's fixture copy. That catches editing a list and forgetting the
///     fixture — but NOT a change made correctly here and never mirrored to
///     the backend, because that leaves both repos internally consistent.
///
///   * [_crossRepoFixtureComparison] compares this repo's fixture against the
///     backend's own copy, and is the check that actually detects drift. It
///     only runs when both repos are checked out as siblings; it skips when
///     the backend isn't there rather than failing, so it guards a developer
///     machine and not an isolated build.
///
/// The C# half is
/// `tests/SnakeClassic.Application.Tests/Sync/StatisticsMergeContractTests.cs`
/// and carries the mirror-image check.
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

  _crossRepoFixtureComparison(loadContract);
}

/// Compare this repo's fixture with the backend repo's copy when both are
/// checked out side by side.
///
/// This is the only check that can actually see drift. The same-repo tests
/// above pass happily when someone updates a field list AND this fixture
/// together and never touches the backend — both repos stay internally
/// consistent while their merge rules diverge, which is precisely the natural
/// workflow (the test fails, the fixture is right there, you fix it locally
/// and move on).
///
/// Skips rather than fails when the sibling repo is absent, so this remains a
/// developer-machine guard. If the repos ever build somewhere that has only
/// one of them, nothing here will catch drift and the contract needs a single
/// shared source instead.
void _crossRepoFixtureComparison(
  Map<String, dynamic> Function() loadLocalContract,
) {
  const backendRelativePath =
      'snake-classic-backend/tests/SnakeClassic.Application.Tests/Fixtures/'
      'statistics_merge_contract.json';

  File? locateBackendFixture() {
    // Walk up from the package root looking for a directory that contains the
    // backend repo. Depth is bounded so a missing sibling can't turn into a
    // walk to the filesystem root.
    var dir = Directory.current.absolute;
    for (var i = 0; i < 5; i++) {
      final candidate = File('${dir.path}/$backendRelativePath');
      if (candidate.existsSync()) return candidate;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  final backendFixture = locateBackendFixture();

  test('fixture matches the backend repo copy (cross-repo drift guard)', () {
    if (backendFixture == null) {
      // Deliberately not a failure — see the doc comment.
      printOnFailure('backend repo not found alongside this one');
      markTestSkipped(
        'Backend repo not checked out as a sibling — cross-repo drift '
        'cannot be verified from here.',
      );
      return;
    }

    final local = loadLocalContract();
    final remote =
        jsonDecode(backendFixture.readAsStringSync()) as Map<String, dynamic>;

    // Compare the MEANING, not the bytes: the two repos have different
    // line-ending settings (git converts LF to CRLF on checkout here), so a
    // byte comparison would fail on formatting noise and get muted.
    expect(
      remote['version'],
      local['version'],
      reason: 'Contract version differs between repos — one side is stale. '
          'Backend copy: ${backendFixture.path}',
    );
    expect(
      (remote['monotonicLongFields'] as List).cast<String>().toList()..sort(),
      (local['monotonicLongFields'] as List).cast<String>().toList()..sort(),
      reason: 'monotonicLongFields differs between repos — the Dart and C# '
          'statistics merges will silently disagree.',
    );
    expect(
      (remote['monotonicMapFields'] as List).cast<String>().toList()..sort(),
      (local['monotonicMapFields'] as List).cast<String>().toList()..sort(),
      reason: 'monotonicMapFields differs between repos — the Dart and C# '
          'statistics merges will silently disagree.',
    );
  });
}
