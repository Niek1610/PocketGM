// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/models/input_log_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/models/promotion_choice.dart';
import 'package:pocketgm/models/vibration_speed.dart';
import 'package:pocketgm/services/storage_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsProvider extends ChangeNotifier {
  Side _playingAs = Side.white;
  InputLogMode _inputLogMode = InputLogMode.quickMode;
  InputMode _inputMode = InputMode.interfaceMode;
  bool _rotateBoardForBlack = false;
  int _vibrationStrength = 255;
  VibrationSpeed _vibrationSpeed = VibrationSpeed.normal;
  int _stockfishDepth = 15;
  PromotionChoice _promotionChoice = PromotionChoice.queen;
  bool _wakelock = false;

  SettingsProvider() {
    _loadSettings();
  }

  Side get playingAs => _playingAs;
  InputLogMode get inputLogMode => _inputLogMode;
  InputMode get inputMode => _inputMode;
  bool get rotateBoardForBlack => _rotateBoardForBlack;
  int get vibrationStrength => _vibrationStrength;
  VibrationSpeed get vibrationSpeed => _vibrationSpeed;
  int get stockfishDepth => _stockfishDepth;
  PromotionChoice get promotionChoice => _promotionChoice;
  bool get wakelock => _wakelock;

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

  Future<void> setInputLogMode(InputLogMode mode) async {
    _inputLogMode = mode;
    notifyListeners();
    await StorageService().saveInputLogMode(mode);
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

  Future<void> setWakelock(bool value) async {
    _wakelock = value;
    notifyListeners();
    await StorageService().saveWakelock(value);
    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  Future<void> _loadSettings() async {
    _playingAs = StorageService().loadColor();
    _inputLogMode = StorageService().loadInputLogMode();
    _inputMode = StorageService().loadInputMode();
    _rotateBoardForBlack = StorageService().loadRotateBoardForBlack();
    _vibrationStrength = StorageService().loadVibrationStrength();
    _vibrationSpeed = StorageService().loadVibrationSpeed();
    _stockfishDepth = StorageService().loadStockfishDepth();
    _promotionChoice = StorageService().loadPromotionChoice();
    _wakelock = StorageService().loadWakelock();

    if (_wakelock) {
      WakelockPlus.enable();
    }

    notifyListeners();
  }
}

final settingsProvider = ChangeNotifierProvider((ref) => SettingsProvider());
