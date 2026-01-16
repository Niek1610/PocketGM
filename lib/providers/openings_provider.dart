import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pocketgm/models/opening.dart';
import 'package:pocketgm/services/storage_service.dart';

class OpeningsProvider extends ChangeNotifier {
  List<Opening> _customOpenings = [];
  Opening? _selectedOpening;
  int _currentMoveIndex = 0;
  bool _isAutoPlayEnabled = false;

  OpeningsProvider() {
    _loadCustomOpenings();
  }

  List<Opening> get customOpenings => List.unmodifiable(_customOpenings);
  List<Opening> get allOpenings => [...DefaultOpenings.all, ..._customOpenings];
  Opening? get selectedOpening => _selectedOpening;
  int get currentMoveIndex => _currentMoveIndex;
  bool get isAutoPlayEnabled => _isAutoPlayEnabled;

  /// Check if there's a next move available in the selected opening
  bool get hasNextMove {
    if (_selectedOpening == null) return false;
    return _currentMoveIndex < _selectedOpening!.moves.length;
  }

  /// Get the next move in UCI format (e.g., 'e2e4')
  String? get nextMove {
    if (!hasNextMove) return null;
    return _selectedOpening!.moves[_currentMoveIndex];
  }

  /// Get remaining moves count
  int get remainingMovesCount {
    if (_selectedOpening == null) return 0;
    return _selectedOpening!.moves.length - _currentMoveIndex;
  }

  /// Select an opening to use
  void selectOpening(Opening? opening) {
    _selectedOpening = opening;
    _currentMoveIndex = 0;
    notifyListeners();
  }

  /// Clear the selected opening
  void clearSelection() {
    _selectedOpening = null;
    _currentMoveIndex = 0;
    notifyListeners();
  }

  /// Advance to the next move (called after a move is made)
  void advanceMove() {
    if (hasNextMove) {
      _currentMoveIndex++;
      notifyListeners();
    }
  }

  /// Reset to the beginning of the opening
  void resetOpening() {
    _currentMoveIndex = 0;
    notifyListeners();
  }

  /// Toggle auto-play mode
  void setAutoPlay(bool enabled) {
    _isAutoPlayEnabled = enabled;
    notifyListeners();
  }

  /// Add a custom opening
  Future<void> addCustomOpening(Opening opening) async {
    _customOpenings.add(opening);
    await _saveCustomOpenings();
    notifyListeners();
  }

  /// Remove a custom opening
  Future<void> removeCustomOpening(String id) async {
    _customOpenings.removeWhere((o) => o.id == id);
    if (_selectedOpening?.id == id) {
      _selectedOpening = null;
      _currentMoveIndex = 0;
    }
    await _saveCustomOpenings();
    notifyListeners();
  }

  /// Update a custom opening
  Future<void> updateCustomOpening(Opening opening) async {
    final index = _customOpenings.indexWhere((o) => o.id == opening.id);
    if (index != -1) {
      _customOpenings[index] = opening;
      if (_selectedOpening?.id == opening.id) {
        _selectedOpening = opening;
        _currentMoveIndex = 0;
      }
      await _saveCustomOpenings();
      notifyListeners();
    }
  }

  Future<void> _loadCustomOpenings() async {
    _customOpenings = StorageService().loadCustomOpenings();
    notifyListeners();
  }

  Future<void> _saveCustomOpenings() async {
    await StorageService().saveCustomOpenings(_customOpenings);
  }
}

final openingsProvider = ChangeNotifierProvider<OpeningsProvider>(
  (ref) => OpeningsProvider(),
);
