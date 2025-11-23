import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/services/vibration_service.dart';
import 'package:volume_controller/volume_controller.dart';

class InputProvider extends ChangeNotifier {
  final dynamic _ref;

  bool _disposed = false;

  InputProvider(this._ref) {
    _initVolumeListener();
  }

  Future<void> _initVolumeListener() async {
    await VolumeController.instance.setVolume(0.5);
    // Wait for volume to stabilize to avoid initial trigger
    await Future.delayed(const Duration(milliseconds: 500));

    if (_disposed) return;

    VolumeController.instance.addListener((volume) {
      if (_disposed) return;

      final inputMode = _ref.read(settingsProvider).inputMode;
      if (inputMode != InputMode.standaloneMode) return;

      // Ignore small fluctuations
      if ((volume - 0.5).abs() < 0.02) return;

      if (volume > 0.5) {
        increment();
      } else {
        confirm();
      }

      VolumeController.instance.setVolume(0.5);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    VolumeController.instance.removeListener();
    super.dispose();
  }

  int _currentValue = 0;
  int _inputStep = 0;
  String _partialMove = "";

  int get currentValue => _currentValue;
  int get inputStep => _inputStep;
  String get partialMove => _partialMove;

  Future<void> increment() async {
    await VibrationService().feedbackTap();
    _currentValue = (_currentValue % 8) + 1;
    notifyListeners();
  }

  Future<void> confirm() async {
    if (_currentValue == 0) return;

    await VibrationService().feedbackSuccess();
    String char;
    if (_inputStep % 2 == 0) {
      // File a-h
      char = String.fromCharCode('a'.codeUnitAt(0) + _currentValue - 1);
    } else {
      // Rank 1-8
      char = _currentValue.toString();
    }

    _partialMove += char;
    _currentValue = 0;
    _inputStep++;

    if (_inputStep == 4) {
      // Move complete
      String from = _partialMove.substring(0, 2);
      String to = _partialMove.substring(2, 4);

      _ref.read(gameProvider).makeMove(from, to);

      // Reset
      _partialMove = "";
      _inputStep = 0;
    }
    notifyListeners();
  }

  String get displayText {
    if (_currentValue == 0) return "${_partialMove}_";
    String char;
    if (_inputStep % 2 == 0) {
      // File
      char = String.fromCharCode('a'.codeUnitAt(0) + _currentValue - 1);
    } else {
      // Rank
      char = _currentValue.toString();
    }
    return _partialMove + char;
  }
}

final inputProvider = ChangeNotifierProvider((ref) {
  return InputProvider(ref);
});
