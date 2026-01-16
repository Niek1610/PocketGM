import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider that tracks visualization state for showing input highlights on the board
class VisualizationProvider extends ChangeNotifier {
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  void toggleEnabled() {
    setEnabled(!_isEnabled);
  }
}

final visualizationProvider = ChangeNotifierProvider<VisualizationProvider>(
  (ref) => VisualizationProvider(),
);
