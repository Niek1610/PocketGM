import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/services/engine/stockfish.dart';
import 'package:pocketgm/services/vibration_service.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';
import 'package:pocketgm/widgets/game/eval_bar.dart';
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
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title:
          "Playing as ${gameState.playingAs.name[0].toUpperCase()}${gameState.playingAs.name.substring(1)}",
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
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double evalBarWidth = 12.0;
                    final double totalEvalWidth = evalBarWidth;

                    final double boardSize =
                        constraints.maxWidth - totalEvalWidth;

                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: evalBarWidth,
                              height: boardSize,
                              child: EvalBar(
                                score: gameState.currentEvaluation,
                                isFlipped: settings.playingAs == Side.black,
                              ),
                            ),
                            SizedBox(
                              width: boardSize,
                              height: boardSize,
                              child: const GameBoard(),
                            ),
                          ],
                        ),
                        const InputArea(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (!gameState.isGameStarted)
            Container(
              color: Colors.black.withOpacity(0.85),

              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: EdgeInsets.only(left: 32, right: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Ready to play?",
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Playing as ${gameState.playingAs.name[0].toUpperCase()}${gameState.playingAs.name.substring(1)}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Improve your game with real-time analysis and feedback.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: "Start Game",
                        onPressed: () {
                          ref.read(gameProvider).startGame();
                        },
                        width: 200,
                        backgroundColor: buttonColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
