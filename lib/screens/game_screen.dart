import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/services/engine/stockfish.dart';
import 'package:pocketgm/services/vibration_service.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';
import 'package:pocketgm/widgets/game/game_board.dart';
import 'package:pocketgm/widgets/game/game_header.dart';
import 'package:pocketgm/widgets/game/input_area.dart';
import 'package:pocketgm/widgets/primary_button.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final stockfishService = StockfishService();

  @override
  void initState() {
    super.initState();
    _initializeStockfish();
  }

  @override
  void dispose() {
    // We can't access ref here easily in dispose to read provider if the widget is unmounted?
    // Actually we can use ref.read in dispose if we are careful, but usually it's better to do cleanup in deactivate or just rely on the provider state management.
    // But the user wants to reset game when leaving screen.
    super.dispose();
  }

  @override
  void deactivate() {
    ref.read(gameProvider).resetGame();
    VibrationService().stop();
    super.deactivate();
  }

  Future<void> _initializeStockfish() async {
    await stockfishService.init();
    ref.read(gameProvider).onStockfishReady();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return AppScaffold(
      title: "Playing as ${gameState.playingAs.name}",
      actions: [
        IconButton(
          onPressed: () {
            context.push("/settings");
          },
          icon: const Icon(Icons.settings),
        ),
      ],
      body: Stack(
        children: [
          Column(
            children: [
              const GameHeader(),
              const SizedBox(height: 24),
              const GameBoard(),

              const InputArea(),
            ],
          ),
          if (!gameState.isGameStarted)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ready to play?",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: "Start Game",
                      onPressed: () {
                        ref.read(gameProvider).startGame();
                      },
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
