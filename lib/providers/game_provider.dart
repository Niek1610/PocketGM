import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  Side playingAs = Side.white;

  GameProvider() {
    loadSettings();
  }

  void setColor(Side color) async {
    playingAs = color;
    notifyListeners();
    if (kDebugMode) {
      print(playingAs);
    }
    await StorageService().saveColor(color);
  }

  void loadSettings() {
    playingAs = StorageService().loadColor();
  }
}

final gameProvider = ChangeNotifierProvider((ref) => GameProvider());
