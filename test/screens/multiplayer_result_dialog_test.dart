import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/app_localizations_en.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/multiplayer_game_screen.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/versus/versus_match_widgets.dart';

/// The end of a Versus match, on the real game screen.
///
/// Found on two devices against production: a winner sometimes got no
/// verdict at all (frozen board, LIVE, rival OUT, "rival is 10 points
/// ahead"), Back after the match offered to "forfeit" it, and the footer
/// told winners about losses. Everything here is driven through a fake
/// MultiplayerCubit, pushing the states the real one emits.
void main() {
  final l10n = AppLocalizationsEn();
  const me = 'me-uid';
  const rival = 'rival-uid';
  const rivalName = 'Viper';

  late _FakeMultiplayerCubit mp;

  MatchPlayerState player(
    String id,
    String name, {
    required int index,
    bool alive = true,
    int score = 0,
    String? death,
  }) {
    final y = 4 + index * 8;
    return MatchPlayerState(
      playerIndex: index,
      userId: id,
      username: name,
      alive: alive,
      connected: true,
      direction: Direction.right,
      score: score,
      deathReason: death,
      body: [Position(6, y), Position(5, y), Position(4, y)],
    );
  }

  MatchSnapshot snapshot({
    int tick = 1,
    int myScore = 0,
    int rivalScore = 0,
    bool rivalAlive = true,
    bool meAlive = true,
    String? rivalDeath,
    String? myDeath,
  }) => MatchSnapshot(
    tick: tick,
    tickMs: 150,
    elapsedGameMs: tick * 150,
    food: const Position(12, 12),
    players: [
      player(me, 'Me', index: 0, score: myScore, alive: meAlive, death: myDeath),
      player(
        rival,
        rivalName,
        index: 1,
        score: rivalScore,
        alive: rivalAlive,
        death: rivalDeath,
      ),
    ],
  );

  MatchEndResult result({
    required String? winner,
    String reason = 'last_alive',
    int myScore = 0,
    int rivalScore = 0,
    String? myDeath,
    String? rivalDeath,
  }) => MatchEndResult(
    reason: reason,
    winnerUserId: winner,
    winnerCoinReward: 0,
    players: [
      MatchEndPlayer(
        playerIndex: 0,
        userId: me,
        username: 'Me',
        score: myScore,
        foodsEaten: myScore ~/ 10,
        alive: myDeath == null,
        deathReason: myDeath,
      ),
      MatchEndPlayer(
        playerIndex: 1,
        userId: rival,
        username: rivalName,
        score: rivalScore,
        foodsEaten: rivalScore ~/ 10,
        alive: rivalDeath == null,
        deathReason: rivalDeath,
      ),
    ],
  );

  MultiplayerState playing(MatchSnapshot s) =>
      MultiplayerState(status: MultiplayerStatus.playing, snapshot: s);

  MultiplayerState finished(MatchSnapshot s, MatchEndResult? end) =>
      MultiplayerState(
        status: MultiplayerStatus.finished,
        snapshot: s,
        matchEnd: end,
      );

  Future<void> pumpScreen(
    WidgetTester tester, {
    required MultiplayerState initial,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    mp = _FakeMultiplayerCubit(initial);
    final router = GoRouter(
      initialLocation: AppRoutes.multiplayerGame,
      routes: [
        GoRoute(
          path: AppRoutes.multiplayerLobby,
          builder: (_, _) => const Scaffold(body: Text('LOBBY-PLACEHOLDER')),
        ),
        GoRoute(
          path: AppRoutes.multiplayerGame,
          builder: (_, _) => const MultiplayerGameScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MultiplayerCubit>.value(value: mp),
          BlocProvider<AuthCubit>(create: (_) => _FakeAuthCubit(me)),
          BlocProvider<ThemeCubit>(create: (_) => _StubThemeCubit()),
          BlocProvider<GameSettingsCubit>(
            create: (_) => _StubGameSettingsCubit(),
          ),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(extensions: [LBPalette.of(GameTheme.classic)]),
          routerConfig: router,
        ),
      ),
    );
    // Not pumpAndSettle: busy cells and the board animate forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Past the death-shake beat before the verdict.
  Future<void> waitForVerdict(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pushAndPump(WidgetTester tester, MultiplayerState s) async {
    mp.push(s);
    await tester.pump();
  }

  VersusOutcome? shownOutcome(WidgetTester tester) {
    final cards = find.byType(VersusResultCard);
    if (cards.evaluate().isEmpty) return null;
    return tester.widget<VersusResultCard>(cards).outcome;
  }

  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  tearDown(() => mp.close());

  group('verdict', () {
    testWidgets('winner gets VICTORY when the rival ran into them', (
      tester,
    ) async {
      await pumpScreen(tester, initial: playing(snapshot(myScore: 20)));
      final last = snapshot(
        tick: 2,
        myScore: 20,
        rivalScore: 30,
        rivalAlive: false,
        rivalDeath: 'opponent',
      );
      await pushAndPump(
        tester,
        finished(
          last,
          result(
            winner: me,
            myScore: 20,
            rivalScore: 30,
            rivalDeath: 'opponent',
          ),
        ),
      );
      await waitForVerdict(tester);

      expect(shownOutcome(tester), VersusOutcome.victory);
      expect(find.text(l10n.lbVersusFooterVictory), findsOneWidget);
      expect(find.text(l10n.lbVersusFooterDefeat), findsNothing);
    });

    testWidgets('winner with fewer points gets VICTORY when the rival hit '
        'itself', (tester) async {
      await pumpScreen(tester, initial: playing(snapshot(myScore: 10)));
      await pushAndPump(
        tester,
        finished(
          snapshot(
            tick: 2,
            myScore: 10,
            rivalScore: 20,
            rivalAlive: false,
            rivalDeath: 'self',
          ),
          result(winner: me, myScore: 10, rivalScore: 20, rivalDeath: 'self'),
        ),
      );
      await waitForVerdict(tester);

      expect(shownOutcome(tester), VersusOutcome.victory);
      expect(find.text(l10n.mpLastSnakeStanding), findsOneWidget);
    });

    testWidgets('loser gets DEFEAT with the defeat footer', (tester) async {
      await pumpScreen(tester, initial: playing(snapshot()));
      await pushAndPump(
        tester,
        finished(
          snapshot(tick: 2, meAlive: false, myDeath: 'wall', rivalScore: 10),
          result(winner: rival, rivalScore: 10, myDeath: 'wall'),
        ),
      );
      await waitForVerdict(tester);

      expect(shownOutcome(tester), VersusOutcome.defeat);
      expect(find.text(l10n.lbVersusFooterDefeat), findsOneWidget);
    });

    testWidgets('a draw gets the draw footer', (tester) async {
      await pumpScreen(tester, initial: playing(snapshot()));
      await pushAndPump(
        tester,
        finished(
          snapshot(tick: 2, myScore: 10, rivalScore: 10),
          result(
            winner: null,
            reason: 'timeout',
            myScore: 10,
            rivalScore: 10,
          ),
        ),
      );
      await waitForVerdict(tester);

      expect(shownOutcome(tester), VersusOutcome.draw);
      expect(find.text(l10n.lbVersusFooterDraw), findsOneWidget);
    });

    testWidgets('a screen built after the match ended still shows the '
        'verdict', (tester) async {
      // The lobby could replace the game route after GameEnded landed; the
      // new State never saw matchEnd change, so it never showed a result.
      await pumpScreen(
        tester,
        initial: finished(
          snapshot(tick: 9, myScore: 30, rivalAlive: false, rivalDeath: 'wall'),
          result(winner: me, myScore: 30, rivalDeath: 'wall'),
        ),
      );
      await waitForVerdict(tester);

      expect(shownOutcome(tester), VersusOutcome.victory);
    });

    testWidgets('the verdict is shown once, however many states follow', (
      tester,
    ) async {
      await pumpScreen(tester, initial: playing(snapshot()));
      final end = finished(
        snapshot(tick: 2, myScore: 10, rivalAlive: false, rivalDeath: 'wall'),
        result(winner: me, myScore: 10, rivalDeath: 'wall'),
      );
      await pushAndPump(tester, end);
      // Settlement and other updates keep arriving after the result.
      await pushAndPump(
        tester,
        MultiplayerState(
          status: MultiplayerStatus.finished,
          snapshot: end.snapshot,
          matchEnd: end.matchEnd,
          settlementStatus: SettlementStatus.processing,
        ),
      );
      await waitForVerdict(tester);
      await pushAndPump(
        tester,
        MultiplayerState(
          status: MultiplayerStatus.finished,
          snapshot: end.snapshot,
          matchEnd: end.matchEnd,
          settlementStatus: SettlementStatus.applied,
        ),
      );
      await waitForVerdict(tester);

      expect(find.byType(VersusResultCard), findsOneWidget);
    });
  });

  group('back after the match', () {
    testWidgets('during the match, Back asks about forfeiting', (tester) async {
      await pumpScreen(tester, initial: playing(snapshot()));
      await systemBack(tester);

      expect(find.text(l10n.mpLeaveGameTitle.toUpperCase()), findsOneWidget);
    });

    testWidgets('Back shows the result again, never the forfeit warning', (
      tester,
    ) async {
      await pumpScreen(tester, initial: playing(snapshot()));
      await pushAndPump(
        tester,
        finished(
          snapshot(tick: 2, myScore: 10, rivalAlive: false, rivalDeath: 'wall'),
          result(winner: me, myScore: 10, rivalDeath: 'wall'),
        ),
      );
      await waitForVerdict(tester);
      expect(shownOutcome(tester), VersusOutcome.victory);

      // Back closes the dialog (the system's own handling of a dialog)...
      await systemBack(tester);
      expect(find.byType(VersusResultCard), findsNothing);

      // ...and Back on the board brings the verdict back.
      await systemBack(tester);
      expect(shownOutcome(tester), VersusOutcome.victory);
      expect(find.text(l10n.mpLeaveGameTitle.toUpperCase()), findsNothing);
      expect(find.text(l10n.mpLeaveGameBody), findsNothing);
    });

    testWidgets('finished without a result: Back goes straight to the lobby', (
      tester,
    ) async {
      await pumpScreen(tester, initial: playing(snapshot()));
      await pushAndPump(tester, finished(snapshot(tick: 2), null));
      await systemBack(tester);

      expect(find.text(l10n.mpLeaveGameTitle.toUpperCase()), findsNothing);
      expect(find.text('LOBBY-PLACEHOLDER'), findsOneWidget);
    });
  });

  testWidgets('finished without a result leaves for the lobby after the '
      'grace period', (tester) async {
    await pumpScreen(tester, initial: playing(snapshot()));
    await pushAndPump(tester, finished(snapshot(tick: 2), null));

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('LOBBY-PLACEHOLDER'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('LOBBY-PLACEHOLDER'), findsOneWidget);
    expect(find.text(l10n.mpErrNoResult), findsOneWidget);
    expect(mp.leaveCalls, 1);
  });

  testWidgets('a result that arrives inside the grace period is shown', (
    tester,
  ) async {
    await pumpScreen(tester, initial: playing(snapshot()));
    final last = snapshot(tick: 2, myScore: 10, rivalAlive: false);
    await pushAndPump(tester, finished(last, null));
    await tester.pump(const Duration(seconds: 1));
    await pushAndPump(
      tester,
      finished(last, result(winner: me, myScore: 10, rivalDeath: 'wall')),
    );
    await waitForVerdict(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(shownOutcome(tester), VersusOutcome.victory);
    expect(find.text('LOBBY-PLACEHOLDER'), findsNothing);
  });

  group('HUD after the match', () {
    testWidgets('LIVE becomes FINAL and the taunts stop', (tester) async {
      await pumpScreen(
        tester,
        initial: playing(snapshot(myScore: 10, rivalScore: 20)),
      );
      expect(find.byKey(const ValueKey('versus-badge-live')), findsOneWidget);
      expect(find.text(l10n.lbMatchBehind(rivalName, '10')), findsOneWidget);

      // last_alive: the dead rival holds more points than the winner.
      await pushAndPump(
        tester,
        finished(
          snapshot(
            tick: 2,
            myScore: 10,
            rivalScore: 20,
            rivalAlive: false,
            rivalDeath: 'self',
          ),
          result(winner: me, myScore: 10, rivalScore: 20, rivalDeath: 'self'),
        ),
      );

      expect(find.byKey(const ValueKey('versus-badge-live')), findsNothing);
      expect(find.byKey(const ValueKey('versus-badge-final')), findsOneWidget);
      expect(find.text(l10n.lbMatchBehind(rivalName, '10')), findsNothing);
      expect(find.text(l10n.lbMatchOver), findsOneWidget);
    });

    testWidgets('snapshots stalling mid-match say so on the board', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        initial: playing(snapshot(myScore: 10, rivalScore: 20)),
      );
      expect(
        find.byKey(const ValueKey('versus-stall-notice')),
        findsNothing,
      );

      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('versus-stall-notice')),
        findsOneWidget,
      );
      expect(find.text(l10n.lbMatchBehind(rivalName, '10')), findsNothing);
      expect(
        find.byKey(const ValueKey('versus-badge-reconnecting')),
        findsOneWidget,
      );

      // The next snapshot clears it.
      await pushAndPump(
        tester,
        playing(snapshot(tick: 2, myScore: 10, rivalScore: 20)),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('versus-stall-notice')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('versus-badge-live')), findsOneWidget);
    });
  });

  testWidgets('tablet landscape shows the verdict too', (tester) async {
    await pumpScreen(
      tester,
      size: const Size(1340, 800),
      initial: playing(snapshot()),
    );
    await pushAndPump(
      tester,
      finished(
        snapshot(tick: 2, meAlive: false, myDeath: 'head_on'),
        result(winner: rival, myDeath: 'head_on'),
      ),
    );
    await waitForVerdict(tester);

    expect(shownOutcome(tester), VersusOutcome.defeat);
    expect(tester.takeException(), isNull);
  });

  test('every outcome has its own footer', () {
    final footers = {
      for (final o in VersusOutcome.values) versusResultFooter(l10n, o),
    };
    expect(footers, hasLength(VersusOutcome.values.length));
  });
}

/// A MultiplayerCubit that only holds state. [push] stands in for the
/// cubit's own emits; the few methods the screen calls are answered here.
class _FakeMultiplayerCubit extends Cubit<MultiplayerState>
    implements MultiplayerCubit {
  _FakeMultiplayerCubit(super.initial);

  int leaveCalls = 0;

  void push(MultiplayerState s) => emit(s);

  @override
  bool get canSteer => state.status == MultiplayerStatus.playing;

  @override
  bool get lastMatchWasQuickMatch => true;

  @override
  Future<void> leaveGame() async {
    leaveCalls++;
    emit(const MultiplayerState(status: MultiplayerStatus.idle));
  }

  @override
  Future<void> queueAgain() async {}

  @override
  void playLocalEatFeedback() {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit(String uid)
    : super(
        AuthState(
          status: AuthStatus.authenticated,
          user: UnifiedUser(
            uid: uid,
            userType: UserType.google,
            username: 'me',
            displayName: 'Me',
            createdAt: DateTime(2026),
            lastSeen: DateTime(2026),
          ),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _StubThemeCubit extends Cubit<ThemeState> implements ThemeCubit {
  _StubThemeCubit() : super(const ThemeState(currentTheme: GameTheme.classic));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _StubGameSettingsCubit extends Cubit<GameSettingsState>
    implements GameSettingsCubit {
  _StubGameSettingsCubit() : super(GameSettingsState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
