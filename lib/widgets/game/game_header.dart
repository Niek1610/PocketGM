import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/models/game_mode.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/input_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';

class GameHeader extends ConsumerWidget {
  const GameHeader({super.key});

  String _getInstructionText(
    GameProvider gameState,
    SettingsProvider settings,
  ) {
    final isUserTurn = gameState.sideToMove == gameState.playingAs;
    final isQuickMode = settings.gameMode == GameMode.quick;

    if (isUserTurn) {
      if (isQuickMode) {
        return "Stockfish is thinking...";
      } else {
        return "Enter your move";
      }
    } else {
      return "Enter opponent's move";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final input = ref.watch(inputProvider);

    return Column(
      children: [
        Text(
          "${gameState.sideToMove.name} to move",
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: white),
        ),
        Text(
          _getInstructionText(gameState, settings),
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: white.withOpacity(0.7)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildActionButton(
              context,
              label: "Repeat",
              icon: Icons.volume_up,
              onPressed: () => gameState.repeatLastMoveFeedback(),
            ),
            const SizedBox(width: 12),
            _buildInfoBox(
              context,
              label: "Input",
              value: input.displayText,
              color: const Color.fromARGB(255, 41, 41, 41),
            ),
            const SizedBox(width: 12),
            _buildInfoBox(
              context,
              label: "Last Move",
              value: gameState.lastMove?.toString() ?? "-",
              color: black,
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              context,
              label: "Undo",
              icon: Icons.undo,
              onPressed: () => gameState.undoMove(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: white.withOpacity(0.5), fontSize: 10),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 36, // Match height of info box content roughly
            width: 36,
            decoration: BoxDecoration(
              color: white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: white.withOpacity(0.5), fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: white,
              fontFamily: 'Courier',
            ),
          ),
        ),
      ],
    );
  }
}
