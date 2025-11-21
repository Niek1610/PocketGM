// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  Side _playingAs = Side.white;
  InputMode _inputMode = InputMode.quickMode;

  SettingsProvider() {
    _loadSettings();
  }

  Side get playingAs => _playingAs;
  InputMode get inputMode => _inputMode;

  Future<void> setPlayingAs(Side color) async {
    _playingAs = color;
    notifyListeners();
    await StorageService().saveColor(color);
  }

  Future<void> setInputMode(InputMode mode) async {
    _inputMode = mode;
    notifyListeners();
    await StorageService().saveInputMode(mode);
  }

  Future<void> _loadSettings() async {
    _playingAs = StorageService().loadColor();
    _inputMode = StorageService().loadInputMode();
    notifyListeners();
  }
}

final settingsProvider = ChangeNotifierProvider((ref) => SettingsProvider());
