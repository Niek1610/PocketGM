import 'package:dartchess/dartchess.dart';
import 'package:pocketgm/models/input_log_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/models/vibration_speed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton pattern (1 instance voor hele app)
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Side loadColor() {
    final index = _prefs.getInt('Color') ?? 0;

    return Side.values[index];
  }

  Future<void> saveColor(Side color) async {
    await _prefs.setInt('color', color.index);
  }

  Future<void> saveInputLogMode(InputLogMode mode) async {
    await _prefs.setInt('input_log_mode', mode.index);
  }

  InputLogMode loadInputLogMode() {
    final index = _prefs.getInt('input_log_mode') ?? 0;
    return InputLogMode.values[index];
  }

  Future<void> saveInputMode(InputMode mode) async {
    await _prefs.setInt('input_mode', mode.index);
  }

  InputMode loadInputMode() {
    final index = _prefs.getInt('input_mode') ?? 0;
    return InputMode.values[index];
  }

  Future<void> saveRotateBoardForBlack(bool value) async {
    await _prefs.setBool('rotate_board_for_black', value);
  }

  bool loadRotateBoardForBlack() {
    return _prefs.getBool('rotate_board_for_black') ?? false;
  }

  Future<void> saveVibrationStrength(int value) async {
    await _prefs.setInt('vibration_strength', value);
  }

  int loadVibrationStrength() {
    return _prefs.getInt('vibration_strength') ?? 255;
  }

  Future<void> saveVibrationSpeed(VibrationSpeed speed) async {
    await _prefs.setInt('vibration_speed', speed.index);
  }

  VibrationSpeed loadVibrationSpeed() {
    final index = _prefs.getInt('vibration_speed') ?? 1; // Default to normal
    if (index < 0 || index >= VibrationSpeed.values.length) {
      return VibrationSpeed.normal;
    }
    return VibrationSpeed.values[index];
  }
}
