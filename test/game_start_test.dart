import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/services/engine/stockfish.dart';
import 'package:pocketgm/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockfish/stockfish.dart';

class StartingStockfish implements Stockfish {
  final writes = <String>[];

  @override
  Stream<String> get stdout => const Stream.empty();

  @override
  final ValueNotifier<StockfishState> state = ValueNotifier(
    StockfishState.starting,
  );

  @override
  set stdin(String line) {
    if (state.value != StockfishState.ready) {
      throw StateError('Stockfish is not ready (${state.value})');
    }
    writes.add(line);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CountingGameProvider extends GameProvider {
  CountingGameProvider(super.settings);

  int requests = 0;

  @override
  Future<String?> getBestMoveUCI() async {
    requests++;
    return null;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'game_mode': 0, 'input_mode': 2});
    await StorageService().init();
    StockfishService().isStockfishInitialized = false;
  });

  tearDown(() {
    StockfishService().stockfish = null;
    StockfishService().isStockfishInitialized = false;
  });

  testWidgets('white can start while Stockfish is still loading', (
    tester,
  ) async {
    final engine = StartingStockfish();
    final service = StockfishService()..stockfish = engine;
    final settings = SettingsProvider();
    final game = GameProvider(settings);
    addTearDown(game.dispose);
    addTearDown(settings.dispose);
    addTearDown(engine.state.dispose);

    game.startGame();
    await tester.pump();

    expect(game.isGameStarted, isTrue);
    expect(game.playingAs, Side.white);
    expect(service.isStockfishInitialized, isFalse);
    expect(engine.writes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('concurrent engine initialization shares a single startup', (
    tester,
  ) async {
    final engine = StartingStockfish();
    final service = StockfishService()..stockfish = engine;
    addTearDown(engine.state.dispose);

    final first = service.init();
    final second = service.init();
    expect(identical(first, second), isTrue);
    engine.state.value = StockfishState.ready;
    await tester.pump(const Duration(milliseconds: 100));
    await Future.wait([first, second]);

    expect(service.isStockfishInitialized, isTrue);
    expect(engine.writes, ['uci', 'isready']);
  });

  test('engine queries before readiness return no move', () async {
    final service = StockfishService();
    expect(await service.getBestMove(Chess.initial.fen), isNull);
  });

  testWidgets('white requests its first move when the engine becomes ready', (
    tester,
  ) async {
    final settings = SettingsProvider();
    final game = CountingGameProvider(settings);
    addTearDown(game.dispose);
    addTearDown(settings.dispose);

    game.startGame();
    await tester.pump();
    expect(game.requests, 0);

    StockfishService().isStockfishInitialized = true;
    game.onStockfishReady();
    await tester.pump();
    expect(game.requests, 1);
  });

  testWidgets('entering a move while loading does not query Stockfish', (
    tester,
  ) async {
    final engine = StartingStockfish();
    StockfishService().stockfish = engine;
    final settings = SettingsProvider();
    await settings.setPlayingAs(Side.black);
    final game = GameProvider(settings);
    addTearDown(game.dispose);
    addTearDown(settings.dispose);
    addTearDown(engine.state.dispose);

    game.startGame();
    expect(await game.makeMove('e2', 'e4'), isTrue);
    await tester.pump();

    expect(game.sideToMove, Side.black);
    expect(engine.writes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a reset game does not request a move when loading finishes', (
    tester,
  ) async {
    final settings = SettingsProvider();
    final game = CountingGameProvider(settings);
    addTearDown(game.dispose);
    addTearDown(settings.dispose);

    game.startGame();
    game.resetGame();
    StockfishService().isStockfishInitialized = true;
    game.onStockfishReady();
    await tester.pump();

    expect(game.isGameStarted, isFalse);
    expect(game.requests, 0);
  });

  testWidgets('black waits for the opponent when the engine becomes ready', (
    tester,
  ) async {
    final settings = SettingsProvider();
    await settings.setPlayingAs(Side.black);
    final game = CountingGameProvider(settings);
    addTearDown(game.dispose);
    addTearDown(settings.dispose);

    game.startGame();
    StockfishService().isStockfishInitialized = true;
    game.onStockfishReady();
    await tester.pump();

    expect(game.isGameStarted, isTrue);
    expect(game.requests, 0);
  });
}
