import 'dart:convert';
import 'package:dartchess/dartchess.dart';
import 'package:pocketgm/models/game_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/models/opening.dart';
import 'package:pocketgm/models/vibration_speed.dart';
import 'package:pocketgm/models/promotion_choice.dart';
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

  Future<void> saveGameMode(GameMode mode) async {
    await _prefs.setInt('game_mode', mode.index);
  }

  GameMode loadGameMode() {
    final index = _prefs.getInt('game_mode') ?? 0;
    if (index < 0 || index >= GameMode.values.length) {
      return GameMode.quick;
    }
    return GameMode.values[index];
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

  Future<void> saveStockfishDepth(int value) async {
    await _prefs.setInt('stockfish_depth', value);
  }

  int loadStockfishDepth() {
    final depth = _prefs.getInt('stockfish_depth') ?? 15;
    if (depth > 15) return 15;
    return depth;
  }

  Future<void> savePromotionChoice(PromotionChoice choice) async {
    await _prefs.setInt('promotion_choice', choice.index);
  }

  PromotionChoice loadPromotionChoice() {
    final index = _prefs.getInt('promotion_choice') ?? 0; // Default to queen
    if (index < 0 || index >= PromotionChoice.values.length) {
      return PromotionChoice.queen;
    }
    return PromotionChoice.values[index];
  }

  Future<void> saveAllowTouchInput(bool value) async {
    await _prefs.setBool('allow_touch_input', value);
  }

  bool loadAllowTouchInput() {
    return _prefs.getBool('allow_touch_input') ?? true;
  }

  Future<void> saveCustomOpenings(List<Opening> openings) async {
    final jsonList = openings.map((o) => o.toJson()).toList();
    await _prefs.setString('custom_openings', jsonEncode(jsonList));
  }

  List<Opening> loadCustomOpenings() {
    final jsonString = _prefs.getString('custom_openings');
    if (jsonString == null) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) {
        return Opening.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  dynamic _openingFromJson(Map<String, dynamic> json) {
    // This will be called with the Opening.fromJson factory
    // We return a map that can be converted later
    return json;
  }
}
