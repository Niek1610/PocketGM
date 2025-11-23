// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/models/game_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/models/promotion_choice.dart';
import 'package:pocketgm/models/vibration_speed.dart';
import 'package:pocketgm/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  Side _playingAs = Side.white;
  GameMode _gameMode = GameMode.quick;
  InputMode _inputMode = InputMode.interfaceMode;
  bool _rotateBoardForBlack = false;
  int _vibrationStrength = 255;
  VibrationSpeed _vibrationSpeed = VibrationSpeed.normal;
  int _stockfishDepth = 15;
  PromotionChoice _promotionChoice = PromotionChoice.queen;
  bool _allowTouchInput = true;

  SettingsProvider() {
    _loadSettings();
  }

  Side get playingAs => _playingAs;
  GameMode get gameMode => _gameMode;
  InputMode get inputMode => _inputMode;
  bool get rotateBoardForBlack => _rotateBoardForBlack;
  int get vibrationStrength => _vibrationStrength;
  VibrationSpeed get vibrationSpeed => _vibrationSpeed;
  int get stockfishDepth => _stockfishDepth;
  PromotionChoice get promotionChoice => _promotionChoice;
  bool get allowTouchInput => _allowTouchInput;

  Future<void> setPlayingAs(Side color) async {
    _playingAs = color;
    notifyListeners();
    await StorageService().saveColor(color);
  }

  Future<void> setRotateBoardForBlack(bool value) async {
    _rotateBoardForBlack = value;
    notifyListeners();
    await StorageService().saveRotateBoardForBlack(value);
  }

  Future<void> setGameMode(GameMode mode) async {
    _gameMode = mode;
    notifyListeners();
    await StorageService().saveGameMode(mode);
  }

  Future<void> setInputMode(InputMode mode) async {
    _inputMode = mode;
    notifyListeners();
    await StorageService().saveInputMode(mode);
  }

  Future<void> setVibrationStrength(int value) async {
    _vibrationStrength = value;
    notifyListeners();
    await StorageService().saveVibrationStrength(value);
  }

  Future<void> setVibrationSpeed(VibrationSpeed speed) async {
    _vibrationSpeed = speed;
    notifyListeners();
    await StorageService().saveVibrationSpeed(speed);
  }

  Future<void> setStockfishDepth(int value) async {
    _stockfishDepth = value;
    notifyListeners();
    await StorageService().saveStockfishDepth(value);
  }

  Future<void> setPromotionChoice(PromotionChoice choice) async {
    _promotionChoice = choice;
    notifyListeners();
    await StorageService().savePromotionChoice(choice);
  }

  Future<void> setAllowTouchInput(bool value) async {
    _allowTouchInput = value;
    notifyListeners();
    await StorageService().saveAllowTouchInput(value);
  }

  Future<void> _loadSettings() async {
    _playingAs = StorageService().loadColor();
    _gameMode = StorageService().loadGameMode();
    _inputMode = StorageService().loadInputMode();
    _rotateBoardForBlack = StorageService().loadRotateBoardForBlack();
    _vibrationStrength = StorageService().loadVibrationStrength();
    _vibrationSpeed = StorageService().loadVibrationSpeed();
    _stockfishDepth = StorageService().loadStockfishDepth();
    _promotionChoice = StorageService().loadPromotionChoice();
    _allowTouchInput = StorageService().loadAllowTouchInput();

    notifyListeners();
  }
}

final settingsProvider = ChangeNotifierProvider((ref) => SettingsProvider());
