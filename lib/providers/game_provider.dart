import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/models/game_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/models/promotion_choice.dart';

import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/services/engine/stockfish.dart';
import 'package:pocketgm/services/vibration_service.dart';

class GameProvider extends ChangeNotifier {
  Position _position = Chess.initial;
  List<Move> _moveHistory = [];
  Move? _lastMove;
  bool _isGameStarted = false;
  double _currentEvaluation = 0.0;
  double _previousEvaluation = 0.0;

  final stockfishService = StockfishService();

  final SettingsProvider _settings;

  GameProvider(this._settings) {
    stockfishService.evaluationStream.listen((score) {
      // Stockfish reports score from side to move perspective.
      // We want to normalize it to White's perspective for the UI bar usually.
      // If it's Black's turn, and score is +1.0 (Black is winning),
      // then from White's perspective it is -1.0.

      if (_position.turn == Side.black) {
        _currentEvaluation = -score;
      } else {
        _currentEvaluation = score;
      }
      notifyListeners();
    });
  }

  void onStockfishReady() {
    if (_isGameStarted) {
      _checkAndPlayBestMove();
    }
  }

  String get fen => _position.fen;
  Side get sideToMove => _position.turn;
  Side get playingAs => _settings.playingAs;
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);
  Move? get lastMove => _lastMove;
  GameMode get gameMode => _settings.gameMode;
  InputMode get inputMode => _settings.inputMode;
  bool get isGameStarted => _isGameStarted;
  double get currentEvaluation => _currentEvaluation;

  void startGame() {
    _isGameStarted = true;
    notifyListeners();
    _checkAndPlayBestMove();
  }

  void _checkAndPlayBestMove() {
    if (_settings.gameMode == GameMode.feedback) return;

    if (_position.turn == _settings.playingAs && !_position.isGameOver) {
      _getAndPlayBestMove();
    }
  }

  Future<String?> getBestMoveUCI() async {
    return await stockfishService.getBestMove(
      fen,
      depth: _settings.stockfishDepth,
    );
  }

  Future<void> sendUserMoveFeedback(String from, String to) async {
    final isFlipped =
        _settings.playingAs == Side.black && _settings.rotateBoardForBlack;
    await VibrationService().feedbackMove(
      from,
      to,
      isFlipped: isFlipped,
      strength: _settings.vibrationStrength,
      speed: _settings.vibrationSpeed,
    );
  }

  Future<void> _getAndPlayBestMove() async {
    final bestMove = await getBestMoveUCI();
    if (bestMove != null) {
      //split de move op naar "from" en "to"
      final from = bestMove.substring(0, 2);
      final to = bestMove.substring(2, 4);
      sendUserMoveFeedback(from, to);
      if (_settings.gameMode == GameMode.quick) {
        makeMove(from, to);
      }
    }
  }

  IMapOfSets<String, String> get validMoves {
    final Map<String, Set<String>> moves = {};

    _position.legalMoves.forEach((fromSquare, destinations) {
      moves[fromSquare.name] = destinations.squares.map((s) => s.name).toSet();
    });

    return moves.lock;
  }

  Future<bool> makeMove(
    String fromSquare,
    String toSquare, {
    Role? promotion,
  }) async {
    try {
      final from = Square.fromName(fromSquare);
      final to = Square.fromName(toSquare);

      // Check for auto-promotion if promotion is not specified
      if (promotion == null) {
        final piece = _position.board.pieceAt(from);
        if (piece?.role == Role.pawn) {
          final isWhite = piece?.color == Side.white;
          final isPromotionRank =
              (isWhite && to.rank == Rank.values.last) ||
              (!isWhite && to.rank == Rank.values.first);

          if (isPromotionRank) {
            switch (_settings.promotionChoice) {
              case PromotionChoice.queen:
                promotion = Role.queen;
                break;
              case PromotionChoice.rook:
                promotion = Role.rook;
                break;
              case PromotionChoice.bishop:
                promotion = Role.bishop;
                break;
              case PromotionChoice.knight:
                promotion = Role.knight;
                break;
            }
          }
        }
      }

      final move = NormalMove(from: from, to: to, promotion: promotion);

      if (!_position.isLegal(move)) {
        await VibrationService().feedbackError();
        if (kDebugMode) {
          print('Illegal move: $fromSquare -> $toSquare');
        }
        return false;
      }

      _previousEvaluation = _currentEvaluation;
      _position = _position.play(move);

      _moveHistory.add(move);
      _lastMove = move;

      notifyListeners();

      if (_settings.gameMode == GameMode.feedback) {
        // Analyze the move for feedback
        _analyzeMoveFeedback(_position.turn.opposite);
      } else {
        if (_position.turn == _settings.playingAs && !_position.isGameOver) {
          _getAndPlayBestMove();
        }
      }

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
    _isGameStarted = false;

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
    _checkAndPlayBestMove();
    return true;
  }

  Future<void> setPlayingAs(Side color) async {
    await _settings.setPlayingAs(color);
    notifyListeners();
  }

  Future<void> repeatLastMoveFeedback() async {
    if (_lastMove != null) {
      if (_lastMove is NormalMove) {
        final move = _lastMove as NormalMove;
        await sendUserMoveFeedback(move.from.name, move.to.name);
      }
    }
  }

  Future<void> _analyzeMoveFeedback(Side sideThatMoved) async {
    // Trigger a search to update evaluation
    await getBestMoveUCI();

    // Calculate eval from the perspective of the side that just moved
    final evalAfter = _getEvalForSide(sideThatMoved, _currentEvaluation);
    final evalBefore = _getEvalForSide(sideThatMoved, _previousEvaluation);

    final diff = evalAfter - evalBefore;

    // Thresholds
    const blunderThreshold = -2.0;
    const mistakeThreshold = -0.5;
    const opponentBlunderThreshold = 2.0;

    if (sideThatMoved == playingAs) {
      if (diff < blunderThreshold) {
        await VibrationService().feedbackBlunder();
      } else if (diff < mistakeThreshold) {
        await VibrationService().feedbackMistake();
      } else {
        await VibrationService().feedbackGood();
      }
    } else {
      // Opponent moved. If their eval dropped significantly (my eval rose)
      // diff is from Opponent's perspective.
      if (diff < -opponentBlunderThreshold) {
        await VibrationService().feedbackOpponentBlunder();
      }
    }
  }

  double _getEvalForSide(Side side, double evalWhite) {
    return side == Side.white ? evalWhite : -evalWhite;
  }

  @override
  void dispose() {
    // Don't dispose Stockfish here since it's a singleton
    super.dispose();
  }
}

final gameProvider = ChangeNotifierProvider((ref) {
  final settings = ref.read(settingsProvider);
  return GameProvider(settings);
});
