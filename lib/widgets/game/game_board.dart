import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/input_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/providers/visualization_provider.dart';
import 'package:pocketgm/widgets/game/visualization_overlay.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final visualization = ref.watch(visualizationProvider);
    final inputState = ref.watch(inputProvider);

    // Calculate highlights for visualization mode
    final isFlipped =
        settings.playingAs == Side.black && settings.rotateBoardForBlack;
    
    final highlightedSquares = visualization.isEnabled
        ? getHighlightedSquares(
            currentValue: inputState.currentValue,
            inputStep: inputState.inputStep,
            partialMove: inputState.partialMove,
            isFlipped: isFlipped,
          )
        : <String>{};

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;

        return Chessboard(
          settings: ChessboardSettings(
            pieceShiftMethod: PieceShiftMethod.either,
            boxShadow: const [],
          ),
          size: boardSize,
          orientation: gameState.playingAs,
          fen: gameState.fen,
          shapes: highlightedSquares.map((square) {
            return Circle(
              orig: Square.fromName(square),
              color: getHighlightColor(square, inputState.partialMove),
            );
          }).toISet(),
          game: GameData(
            playerSide: settings.allowTouchInput
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
        );
      },
    );
  }
}
