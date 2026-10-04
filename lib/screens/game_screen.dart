import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/providers/bluetooth_provider.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/services/engine/stockfish.dart';
import 'package:pocketgm/services/vibration_service.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';
import 'package:pocketgm/widgets/game/eval_bar.dart';
import 'package:pocketgm/widgets/game/game_board.dart';
import 'package:pocketgm/widgets/game/game_header.dart';
import 'package:pocketgm/widgets/game/game_over_overlay.dart';
import 'package:pocketgm/widgets/game/input_area.dart';
import 'package:pocketgm/widgets/game/start_game_overlay.dart';

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
    // connect VibrationService to BluetoothProvider for ESP32 support
    final btProvider = ref.read(bluetoothProvider);
    VibrationService().setBluetoothProvider(btProvider);
  }

  @override
  void dispose() {
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
    if (!mounted) return;
    ref.read(gameProvider).onStockfishReady();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: "Playing as ${gameState.playingAs.name}",
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
          if (gameState.isGameOver && gameState.isGameStarted)
            const GameOverOverlay(),
          if (!gameState.isGameStarted) const StartGameOverlay(),
        ],
      ),
    );
  }
}
