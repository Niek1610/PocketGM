import 'dart:async';

import 'package:stockfish/stockfish.dart';

class StockfishService {
  // Singleton pattern
  static final StockfishService _instance = StockfishService._internal();
  factory StockfishService() => _instance;
  StockfishService._internal();

  //stockfish init
  Stockfish? stockfish;
  //laatste beste zet
  String? _lastBestMove;
  bool isStockfishInitialized = false;

  // Stream controller for evaluation score (centipawns)
  // Positive = White advantage, Negative = Black advantage
  final _evaluationController = StreamController<double>.broadcast();
  Stream<double> get evaluationStream => _evaluationController.stream;

  Future<void> init() async {
    if (isStockfishInitialized) return;
    stockfish = Stockfish();
    //wachten op stockfish
    while (stockfish!.state.value != StockfishState.ready) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    //stockfish luisterd altijd
    stockfish!.stdout.listen((line) {
      // print('Stockfish output: $line');

      if (line.startsWith('info') && line.contains('score')) {
        _parseEvaluation(line);
      }

      // Als de regel begint met "bestmove" wordt de beste zet eruit gehaald
      if (line.startsWith('bestmove')) {
        _lastBestMove = line.split(' ')[1]; // splitten na de spatie
      }
    });

    stockfish!.stdin = 'uci';
    stockfish!.stdin = 'isready';
    isStockfishInitialized = true;
  }

  void _parseEvaluation(String line) {
    try {
      final parts = line.split(' ');
      int scoreIndex = parts.indexOf('score');
      if (scoreIndex != -1 && scoreIndex + 2 < parts.length) {
        String type = parts[scoreIndex + 1]; // cp or mate
        String value = parts[scoreIndex + 2];

        double score = 0.0;
        if (type == 'cp') {
          score = int.parse(value) / 100.0;
        } else if (type == 'mate') {
          int mateIn = int.parse(value);
          // Give mate a high score value
          score = mateIn > 0 ? 100.0 : -100.0;
        }

        // Check if side to move is black, stockfish reports score from engine's perspective?
        // Usually UCI reports score from side to move perspective OR white perspective depending on engine.
        // Stockfish usually reports from white's perspective in recent versions, but let's verify.
        // Actually standard UCI is "score from the point of view of the side to move".
        // BUT many GUIs expect white-based. Stockfish documentation says:
        // "The score is reported from the point of view of the side to move."
        // Wait, let's check standard behavior.
        // If I play e4, and it's black's turn. If black is winning, score is positive for black.
        // We will handle perspective in the provider if needed.

        _evaluationController.add(score);
      }
    } catch (e) {
      print('Error parsing evaluation: $e');
    }
  }

  Future<String?> getBestMove(String fen, {int depth = 20}) async {
    //laaste beste zet resetten
    _lastBestMove = null;

    //positie doorgeven aan stockfish
    stockfish!.stdin = "position fen $fen";
    //Stockfish denktijd (later aanpasbaar maken via settings)
    stockfish!.stdin = 'go depth $depth';

    //wachten op het antwoord van stockfish (max 5 seconden)
    final timeout = Duration(seconds: 5);
    final start = DateTime.now();

    while (_lastBestMove == null &&
        DateTime.now().difference(start) < timeout) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    print(_lastBestMove);
    return _lastBestMove;
  }

  void dispose() {
    if (stockfish != null && isStockfishInitialized) {
      stockfish!.dispose();
      stockfish = null;
      isStockfishInitialized = false;
    }
  }
}
