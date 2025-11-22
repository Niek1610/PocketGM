import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/providers/game_provider.dart';

class InterfaceInputProvider extends ChangeNotifier {
  final GameProvider _gameProvider;

  InterfaceInputProvider(this._gameProvider);

  int _currentValue = 1;
  int _inputStep = 0;
  String _partialMove = "";

  int get currentValue => _currentValue;
  int get inputStep => _inputStep;
  String get partialMove => _partialMove;

  void increment() {
    _currentValue = (_currentValue % 8) + 1;
    notifyListeners();
  }

  void confirm() {
    String char;
    if (_inputStep % 2 == 0) {
      // a-h
      char = String.fromCharCode('a'.codeUnitAt(0) + _currentValue - 1);
    } else {
      //  1-8
      char = _currentValue.toString();
    }

    _partialMove += char;
    _currentValue = 1;
    _inputStep++;

    if (_inputStep == 4) {
      String from = _partialMove.substring(0, 2);
      String to = _partialMove.substring(2, 4);

      _gameProvider.makeMove(from, to);

      _partialMove = "";
      _inputStep = 0;
    }
    notifyListeners();
  }

  String get displayText {
    String char;
    if (_inputStep % 2 == 0) {
      char = String.fromCharCode('a'.codeUnitAt(0) + _currentValue - 1);
    } else {
      char = _currentValue.toString();
    }
    return _partialMove + char;
  }
}

final interfaceInputProvider = ChangeNotifierProvider((ref) {
  final game = ref.read(gameProvider);
  return InterfaceInputProvider(game);
});
