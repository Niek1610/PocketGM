import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  Position _position = Chess.initial;
  List<Move> _moveHistory = [];
  Move? _lastMove;
  Side _playingAs = Side.white;

  GameProvider() {
    _loadSettings();
  }

  String get fen => _position.fen;
  Side get sideToMove => _position.turn;
  Side get playingAs => _playingAs;
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);
  Move? get lastMove => _lastMove;

  IMapOfSets<String, String> get validMoves {
    final Map<String, Set<String>> moves = {};

    _position.legalMoves.forEach((fromSquare, destinations) {
      moves[fromSquare.name] = destinations.squares.map((s) => s.name).toSet();
    });

    return moves.lock;
  }

  bool makeMove(String fromSquare, String toSquare, {Role? promotion}) {
    try {
      final from = Square.fromName(fromSquare);
      final to = Square.fromName(toSquare);

      final move = NormalMove(from: from, to: to, promotion: promotion);

      if (!_position.isLegal(move)) {
        if (kDebugMode) {
          print('Illegal move: $fromSquare -> $toSquare');
        }
        return false;
      }

      _position = _position.play(move);

      _moveHistory.add(move);
      _lastMove = move;

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error making move: $e');
      }
      return false;
    }
  }

  void resetGame() {
    _position = Chess.initial;
    _moveHistory = [];
    _lastMove = null;

    notifyListeners();
  }

  bool undoMove() {
    if (_moveHistory.isEmpty) return false;

    _position = Chess.initial;
    final movesToReplay = _moveHistory.sublist(0, _moveHistory.length - 1);

    for (final move in movesToReplay) {
      _position = _position.play(move);
    }

    _moveHistory.removeLast();
    _lastMove = _moveHistory.isNotEmpty ? _moveHistory.last : null;

    notifyListeners();
    return true;
  }

  Future<void> setPlayingAs(Side color) async {
    _playingAs = color;
    notifyListeners();

    await StorageService().saveColor(color);
  }

  void _loadSettings() {
    _playingAs = StorageService().loadColor();
  }
}

final gameProvider = ChangeNotifierProvider((ref) => GameProvider());
