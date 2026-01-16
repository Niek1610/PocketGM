import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/openings_provider.dart';

/// Widget that shows opening move suggestions during the game
class OpeningGuide extends ConsumerWidget {
  const OpeningGuide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openings = ref.watch(openingsProvider);
    final gameState = ref.watch(gameProvider);

    if (openings.selectedOpening == null || !openings.hasNextMove) {
      return const SizedBox.shrink();
    }

    final nextMove = openings.nextMove;
    if (nextMove == null) return const SizedBox.shrink();

    final from = nextMove.substring(0, 2);
    final to = nextMove.substring(2, 4);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor.withOpacity(0.3),
            buttonColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: buttonColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: buttonColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  openings.selectedOpening!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${openings.remainingMovesCount} zetten over',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Volgende: ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$from → $to',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Auto-play button
              Material(
                color: openings.isAutoPlayEnabled
                    ? buttonColor
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _playNextMove(ref, from, to),
                  onLongPress: () {
                    ref.read(openingsProvider.notifier).setAutoPlay(
                          !openings.isAutoPlayEnabled,
                        );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      openings.isAutoPlayEnabled
                          ? Icons.play_circle_filled
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Clear button
              Material(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => ref.read(openingsProvider.notifier).clearSelection(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _playNextMove(WidgetRef ref, String from, String to) {
    final success = ref.read(gameProvider).makeMove(from, to);
    if (success != false) {
      ref.read(openingsProvider.notifier).advanceMove();
    }
  }
}
