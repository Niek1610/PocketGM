import 'package:dartchess/dartchess.dart';
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
}
