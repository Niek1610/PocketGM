import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/widgets/game/overlay_container.dart';
import 'package:pocketgm/widgets/primary_button.dart';

class StartGameOverlay extends ConsumerWidget {
  const StartGameOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return OverlayContainer(
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
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Playing as ${_formatSide(gameState.playingAs)}",
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
    );
  }

  String _formatSide(Side side) {
    return side.name[0].toUpperCase() + side.name.substring(1);
  }
}
