import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/services/engine/stockfish.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';
import 'package:chessground/chessground.dart';
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

  Future<void> _initializeStockfish() async {
    await stockfishService.init();
    ref.read(gameProvider).onStockfishReady();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final inputMode = settings.inputMode;

    return AppScaffold(
      title: "Playing as ${gameState.playingAs.name}",
      actions: [
        IconButton(
          onPressed: () {
            context.push("/settings");
          },
          icon: Icon(Icons.settings),
        ),
      ],
      body: Stack(
        children: [
          Column(
            children: [
              Text(
                "${gameState.sideToMove} is next to move",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: white),
              ),
              SizedBox(height: 8),
              Container(
                width: 200,
                color: const Color.fromARGB(255, 41, 41, 41),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "input",
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.copyWith(color: white),
                  ),
                ),
              ),
              Container(
                width: 200,
                color: black,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    gameState.lastMove.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.copyWith(color: white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Chessboard(
                settings: ChessboardSettings(
                  pieceShiftMethod: PieceShiftMethod.either,
                ),
                size: screenWidth,
                orientation: gameState.playingAs,
                fen: gameState.fen,
                game: GameData(
                  playerSide: inputMode == InputMode.interfaceMode
                      ? PlayerSide.both
                      : PlayerSide.none,
                  sideToMove: gameState.sideToMove,
                  validMoves: ValidMoves(
                    gameState.validMoves.unlock.map(
                      (from, destinations) => MapEntry(
                        Square.fromName(from),
                        destinations.map((s) => Square.fromName(s)).toISet(),
                      ),
                    ),
                  ),
                  promotionMove: null,
                  onMove: (move, {isDrop}) {
                    gameState.makeMove(
                      move.from.name,
                      move.to.name,
                      promotion: move.promotion,
                    );
                  },
                  onPromotionSelection: (role) {},
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {
                          gameState.resetGame();
                        },
                        text: "Reset",
                      ),
                    ),

                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {
                          gameState.undoMove();
                        },
                        text: "Undo",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.17,
            minChildSize: 0.17,
            maxChildSize: 0.45,
            builder: (context, scrollController) {
              return Container(
                color: const Color.fromARGB(255, 42, 29, 54),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<InputMode>(
                          value: inputMode,
                          dropdownColor: const Color.fromARGB(255, 42, 29, 54),
                          style: TextStyle(color: white),
                          items: [
                            DropdownMenuItem(
                              value: InputMode.bleMode,
                              child: Text("PocketGM"),
                            ),
                            DropdownMenuItem(
                              value: InputMode.standaloneMode,
                              child: Text("Standalone"),
                            ),
                            DropdownMenuItem(
                              value: InputMode.interfaceMode,
                              child: Text("Interface"),
                            ),
                          ],
                          onChanged: (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .setInputMode(value!);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ..._buildInstructionsSection(inputMode),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInstructionsSection(InputMode mode) {
    switch (mode) {
      case InputMode.bleMode:
        return [
          Text(
            "Instructions",
            style: TextStyle(color: white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Connect your PocketGM device via Bluetooth. The device will count columns (a-h) and rows (1-8) to input moves.",
            style: TextStyle(color: white),
          ),
          SizedBox(height: 16),
          PrimaryButton(onPressed: () {}, text: "Connect device"),
          SizedBox(height: 8),
        ];

      case InputMode.standaloneMode:
        return [
          Text(
            "Instructions",
            style: TextStyle(color: white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Use your device's volume buttons to count columns (a-h) and rows (1-8) to input moves.",
            style: TextStyle(color: white),
          ),
          SizedBox(height: 12),
        ];

      case InputMode.interfaceMode:
        return [
          Text(
            "Instructions",
            style: TextStyle(color: white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Use the buttons below to count columns (a-h) and rows (1-8) to input moves manually.",
            style: TextStyle(color: white),
          ),
          SizedBox(height: 16),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: PrimaryButton(onPressed: () {}, text: "−"),
              ),
              Expanded(
                child: PrimaryButton(onPressed: () {}, text: "+"),
              ),
            ],
          ),
        ];
    }
  }
}
