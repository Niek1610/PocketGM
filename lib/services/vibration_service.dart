import 'package:pocketgm/models/vibration_speed.dart';
import 'package:pocketgm/providers/bluetooth_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();

  factory VibrationService() {
    return _instance;
  }

  VibrationService._internal();

  /// Reference to BluetoothProvider for ESP32 vibration
  BluetoothProvider? _bluetoothProvider;

  /// Set the BluetoothProvider for ESP32 vibration support
  void setBluetoothProvider(BluetoothProvider? provider) {
    _bluetoothProvider = provider;
  }

  /// Check if ESP32 is connected and should receive vibration commands
  bool get _useEsp32 {
    final result = _bluetoothProvider?.isConnectedToEsp32 ?? false;
    print(
      'VibrationService._useEsp32: $result (provider: $_bluetoothProvider)',
    );
    return result;
  }

  Future<bool> get _hasVibrator async => await Vibration.hasVibrator();
  Future<bool> get _hasAmplitudeControl async =>
      await Vibration.hasAmplitudeControl();

  Future<void> vibrate({int duration = 500}) async {
    print(
      'VibrationService.vibrate called, duration: $duration, useEsp32: $_useEsp32',
    );
    if (_useEsp32) {
      await _bluetoothProvider!.sendVibration(duration);
    } else if (await _hasVibrator) {
      Vibration.vibrate(duration: duration);
    }
  }

  Future<void> vibratePreset(VibrationPreset preset) async {
    // For ESP32, convert preset to simple vibration
    if (_useEsp32) {
      // Map presets to approximate durations
      int duration;
      switch (preset) {
        case VibrationPreset.quickSuccessAlert:
          duration = 100;
          break;
        case VibrationPreset.emergencyAlert:
          duration = 500;
          break;
        default:
          duration = 200;
      }
      await _bluetoothProvider!.sendVibration(duration);
    } else if (await _hasVibrator) {
      Vibration.vibrate(preset: preset);
    }
  }

  Future<void> vibratePattern(
    List<int> pattern, {
    List<int>? intensities,
  }) async {
    if (_useEsp32) {
      await _bluetoothProvider!.sendVibrationPattern(pattern);
    } else if (await _hasVibrator) {
      if (intensities != null && await _hasAmplitudeControl) {
        Vibration.vibrate(pattern: pattern, intensities: intensities);
      } else {
        Vibration.vibrate(pattern: pattern);
      }
    }
  }

  Future<void> feedbackTap() async {
    await vibrate(duration: 150);
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

    int pulseDuration = 150;
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

    void addPulses(int count, bool isLast) {
      for (int i = 0; i < count; i++) {
        pattern.addAll([pulseDuration, gapDuration]);
        intensities.addAll([strength, 0]);
      }
      // Add extra pause between groups (not after the last group)
      if (!isLast) {
        // Replace last gapDuration with groupGapDuration
        pattern[pattern.length - 1] = groupGapDuration;
      }
    }

    addPulses(fromCol, false);
    addPulses(fromRow, false);
    addPulses(toCol, false);
    addPulses(toRow, true);

    await vibratePattern(pattern, intensities: intensities);
  }

  Future<void> feedbackBlunder() async {
    // Long, heavy vibration (STOP!)
    await vibratePattern([0, 1000], intensities: [0, 255]);
  }

  Future<void> feedbackMistake() async {
    // Two quick pulses (Warning)
    await vibratePattern([0, 100, 100, 100], intensities: [0, 200, 0, 200]);
  }

  Future<void> feedbackGood() async {
    // Very short tick (Safe)
    await vibrate(duration: 20);
  }

  Future<void> feedbackOpponentBlunder() async {
    // Three quick pulses (Opportunity!)
    await vibratePattern(
      [0, 100, 50, 100, 50, 100],
      intensities: [0, 255, 0, 255, 0, 255],
    );
  }

  Future<void> stop() async {
    if (_useEsp32) {
      // Send 0 duration to stop vibration
      await _bluetoothProvider!.sendVibration(0);
    } else if (await _hasVibrator) {
      Vibration.cancel();
    }
  }
}
