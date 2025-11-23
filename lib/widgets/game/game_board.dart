import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;

        return Chessboard(
          settings: const ChessboardSettings(
            pieceShiftMethod: PieceShiftMethod.either,
          ),
          size: boardSize,
          orientation: gameState.playingAs,
          fen: gameState.fen,
          game: GameData(
            playerSide: settings.inputMode == InputMode.interfaceMode
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
