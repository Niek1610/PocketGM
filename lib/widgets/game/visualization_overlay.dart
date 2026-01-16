import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/providers/input_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/providers/visualization_provider.dart';

/// Returns the squares to highlight based on current input state
Set<String> getHighlightedSquares({
  required int currentValue,
  required int inputStep,
  required String partialMove,
  required bool isFlipped,
}) {
  final highlights = <String>{};
  
  if (currentValue == 0 && partialMove.isEmpty) {
    return highlights;
  }

  // Get current selection based on step
  String? getCurrentChar() {
    if (currentValue == 0) return null;
    
    if (inputStep % 2 == 0) {
      // Column (a-h)
      if (isFlipped) {
        return String.fromCharCode('h'.codeUnitAt(0) - (currentValue - 1));
      } else {
        return String.fromCharCode('a'.codeUnitAt(0) + currentValue - 1);
      }
    } else {
      // Row (1-8)
      if (isFlipped) {
        return (9 - currentValue).toString();
      } else {
        return currentValue.toString();
      }
    }
  }

  // Add "from" square highlight if we have it
  if (partialMove.length >= 2) {
    highlights.add(partialMove.substring(0, 2));
  }

  // Add current selection highlight
  final currentChar = getCurrentChar();
  
  if (inputStep == 0 && currentChar != null) {
    // Selecting from column - highlight entire column
    for (int row = 1; row <= 8; row++) {
      highlights.add('$currentChar$row');
    }
  } else if (inputStep == 1 && currentChar != null && partialMove.length >= 1) {
    // Selecting from row - highlight the specific square
    final col = partialMove[0];
    highlights.add('$col$currentChar');
  } else if (inputStep == 2 && currentChar != null) {
    // Selecting to column - highlight entire column
    for (int row = 1; row <= 8; row++) {
      highlights.add('$currentChar$row');
    }
  } else if (inputStep == 3 && currentChar != null && partialMove.length >= 3) {
    // Selecting to row - highlight the specific square
    final col = partialMove[2];
    highlights.add('$col$currentChar');
  }

  return highlights;
}

/// Color for highlighted squares
Color getHighlightColor(String square, String partialMove) {
  // "From" square gets a different color than current selection
  if (partialMove.length >= 2 && square == partialMove.substring(0, 2)) {
    return Colors.blue.withOpacity(0.5);
  }
  return Colors.orange.withOpacity(0.5);
}
