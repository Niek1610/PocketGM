import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';
import 'package:chessground/chessground.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final double screenWidth = MediaQuery.of(context).size.width;

    return AppScaffold(
      title: "Playing as ${gameState.playingAs.name}",
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      body: Column(
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
                "${gameState.lastMove}",
                style: Theme.of(
                  context,
                ).textTheme.labelSmall!.copyWith(color: white),
              ),
            ),
          ),
          SizedBox(height: 16),
          Chessboard(
            settings: ChessboardSettings(
              pieceShiftMethod: PieceShiftMethod.tapTwoSquares,
            ),
            size: screenWidth,
            orientation: gameState.playingAs,
            fen: gameState.fen,
            game: GameData(
              playerSide: gameState.sideToMove == gameState.playingAs
                  ? (gameState.playingAs == Side.white
                        ? PlayerSide.white
                        : PlayerSide.black)
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
        ],
      ),
    );
  }
}
