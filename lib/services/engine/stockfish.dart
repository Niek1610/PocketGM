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
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    stockfish = Stockfish();
    //wachten op stockfish
    while (stockfish!.state.value != StockfishState.ready) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    //stockfish luisterd altijd
    stockfish!.stdout.listen((line) {
      print('Stockfish output: $line');

      // Als de regel begint met "bestmove" wordt de beste zet eruit gehaald
      if (line.startsWith('bestmove')) {
        _lastBestMove = line.split(' ')[1]; // splitten na de spatie
      }
    });

    stockfish!.stdin = 'uci';
    stockfish!.stdin = 'isready';
    _isInitialized = true;
  }

  Future<String?> getBestMove(String fen) async {
    //laaste beste zet resetten
    _lastBestMove = null;

    //positie doorgeven aan stockfish
    stockfish!.stdin = "position fen $fen";
    //Stockfish denktijd (later aanpasbaar maken via settings)
    stockfish!.stdin = 'go movetime 1000';

    //wachten op het antwoord van stockfish (max 5 seconden)
    final timeout = Duration(seconds: 5);
    final start = DateTime.now();

    while (_lastBestMove == null &&
        DateTime.now().difference(start) < timeout) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    return _lastBestMove;
  }

  void dispose() {
    if (stockfish != null && _isInitialized) {
      stockfish!.dispose();
      stockfish = null;
      _isInitialized = false;
    }
  }
}
