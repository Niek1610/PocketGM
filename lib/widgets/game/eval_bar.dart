import 'package:flutter/material.dart';
import 'package:pocketgm/constants/colors..dart';

class EvalBar extends StatelessWidget {
  final double score;
  final bool isFlipped;

  const EvalBar({super.key, required this.score, this.isFlipped = false});

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(-10.0, 10.0);

    double whitePercentage = (clampedScore + 10) / 20;
    whitePercentage = whitePercentage.clamp(0.05, 0.95);

    if (isFlipped) {}

    return Container(
      width: 12,
      decoration: BoxDecoration(
        color: isFlipped ? white : black,

        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            flex: ((1 - whitePercentage) * 1000).toInt(),
            child: Container(),
          ),

          Expanded(
            flex: (whitePercentage * 1000).toInt(),
            child: Container(
              decoration: BoxDecoration(
                color: isFlipped ? black : white,
                borderRadius: isFlipped
                    ? const BorderRadius.vertical(top: Radius.circular(4))
                    : const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
