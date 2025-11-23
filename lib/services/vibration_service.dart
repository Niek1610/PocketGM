import 'package:pocketgm/models/vibration_speed.dart';
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

  Future<void> feedbackMove(
    String from,
    String to, {
    bool isFlipped = false,
    int strength = 255,
    VibrationSpeed speed = VibrationSpeed.normal,
  }) async {
    int fromCol =
        from.substring(0, 1).toLowerCase().codeUnitAt(0) -
        'a'.codeUnitAt(0) +
        1;
    int fromRow = int.parse(from.substring(1, 2));

    int toCol =
        to.substring(0, 1).toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    int toRow = int.parse(to.substring(1, 2));

    if (isFlipped) {
      fromCol = 9 - fromCol;
      fromRow = 9 - fromRow;
      toCol = 9 - toCol;
      toRow = 9 - toRow;
    }

    int pulseDuration = 50;
    int gapDuration;
    int groupGapDuration;

    switch (speed) {
      case VibrationSpeed.fast:
        gapDuration = 200;
        groupGapDuration = 600;
        break;
      case VibrationSpeed.slow:
        gapDuration = 800;
        groupGapDuration = 1600;
        break;
      case VibrationSpeed.normal:
        gapDuration = 500;
        groupGapDuration = 1200;
        break;
    }

    List<int> pattern = [];
    List<int> intensities = [];

    void addPulses(int count) {
      for (int i = 0; i < count; i++) {
        pattern.addAll([pulseDuration, gapDuration]);
        intensities.addAll([strength, 0]);
      }
      pattern.add(groupGapDuration);
      intensities.add(0);
    }

    addPulses(fromCol);
    addPulses(fromRow);
    addPulses(toCol);
    addPulses(toRow);

    await vibratePattern(pattern, intensities: intensities);
  }

  Future<void> stop() async {
    if (await _hasVibrator) {
      Vibration.cancel();
    }
  }
}
