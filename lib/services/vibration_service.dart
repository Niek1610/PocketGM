import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();

  factory VibrationService() {
    return _instance;
  }

  VibrationService._internal();

  Future<bool> get _hasVibrator async => await Vibration.hasVibrator();
  Future<bool> get _hasAmplitudeControl async =>
      await Vibration.hasAmplitudeControl();

  Future<void> vibrate({int duration = 500}) async {
    if (await _hasVibrator) {
      Vibration.vibrate(duration: duration);
    }
  }

  Future<void> vibratePreset(VibrationPreset preset) async {
    if (await _hasVibrator) {
      Vibration.vibrate(preset: preset);
    }
  }

  Future<void> vibratePattern(
    List<int> pattern, {
    List<int>? intensities,
  }) async {
    if (await _hasVibrator) {
      if (intensities != null && await _hasAmplitudeControl) {
        Vibration.vibrate(pattern: pattern, intensities: intensities);
      } else {
        Vibration.vibrate(pattern: pattern);
      }
    }
  }

  Future<void> feedbackTap() async {
    await vibrate(duration: 50);
  }

  Future<void> feedbackSuccess() async {
    await vibratePreset(VibrationPreset.quickSuccessAlert);
  }

  Future<void> feedbackError() async {
    await vibratePreset(VibrationPreset.emergencyAlert);
  }

  Future<void> feedbackMove(String from, String to) async {
    final fromCol =
        from.substring(0, 1).toLowerCase().codeUnitAt(0) -
        'a'.codeUnitAt(0) +
        1;
    final fromRow = int.parse(from.substring(1, 2));

    final toCol =
        to.substring(0, 1).toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    final toRow = int.parse(to.substring(1, 2));

    List<int> pattern = [];
    List<int> intensities = [];

    void addPulses(int count) {
      for (int i = 0; i < count; i++) {
        pattern.addAll([50, 500]);
        intensities.addAll([255, 0]);
      }
      pattern.add(1200);
      intensities.add(0);
    }

    addPulses(fromCol);
    addPulses(fromRow);
    addPulses(toCol);
    addPulses(toRow);

    await vibratePattern(pattern, intensities: intensities);
  }
}
