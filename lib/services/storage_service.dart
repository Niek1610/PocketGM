import 'package:dartchess/dartchess.dart';
import 'package:pocketgm/models/input_mode.dart';
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
    await _prefs.setInt('input_mode', mode.index);
  }

  InputLogMode loadInputLogMode() {
    final index = _prefs.getInt('input_mode') ?? 0;
    return InputLogMode.values[index];
  }
}
