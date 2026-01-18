import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/widgets/game/overlay_container.dart';
import 'package:pocketgm/widgets/primary_button.dart';

class GameOverOverlay extends ConsumerWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return OverlayContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(gameState), size: 64, color: _getIconColor(gameState)),
          const SizedBox(height: 24),
          Text(
            _getTitle(gameState),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gameState.gameResultMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${gameState.moveHistory.length} moves played",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: "New Game",
                onPressed: () {
                  ref.read(gameProvider).resetGame();
                  ref.read(gameProvider).startGame();
                },
                width: 140,
                backgroundColor: buttonColor,
              ),
              const SizedBox(width: 16),
              PrimaryButton(
                text: "Exit",
                onPressed: () {
                  context.go('/');
                },
                width: 100,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(GameProvider gameState) {
    if (gameState.didPlayerWin) {
      return Icons.emoji_events_rounded;
    }
    if (gameState.gameResult == GameResult.draw) {
      return Icons.handshake_rounded;
    }
    return Icons.sentiment_dissatisfied_rounded;
  }

  Color _getIconColor(GameProvider gameState) {
    if (gameState.didPlayerWin) {
      return Colors.amber;
    }
    if (gameState.gameResult == GameResult.draw) {
      return Colors.white;
    }
    return Colors.redAccent;
  }

  String _getTitle(GameProvider gameState) {
    if (gameState.didPlayerWin) {
      return "You Win!";
    }
    if (gameState.gameResult == GameResult.draw) {
      return "It's a Draw!";
    }
    return "You Lose";
  }
}
