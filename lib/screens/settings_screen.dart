import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/models/input_log_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/models/promotion_choice.dart';
import 'package:pocketgm/models/vibration_speed.dart';
import 'package:pocketgm/providers/bluetooth_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final bluetooth = ref.watch(bluetoothProvider);

    return AppScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('General'),
          _buildSection(
            children: [
              SwitchListTile(
                activeColor: white,
                activeTrackColor: buttonColor,
                title: const Text(
                  'Rotate Board for Black',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Flip input and vibration patterns when playing as Black (h-a, 8-1)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: settings.rotateBoardForBlack,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setRotateBoardForBlack(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Engine'),
          _buildSection(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stockfish Depth',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${settings.stockfishDepth}',
                          style: const TextStyle(color: white),
                        ),
                      ],
                    ),
                    Slider(
                      activeColor: white,
                      inactiveColor: Colors.white24,
                      value: settings.stockfishDepth.toDouble(),
                      min: 1,
                      max: 15,
                      divisions: 14,
                      onChanged: (double value) {
                        ref
                            .read(settingsProvider.notifier)
                            .setStockfishDepth(value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Game Settings'),
          _buildSection(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Mode',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
              ),
              _buildRadioTile<InputLogMode>(
                title: 'Quick-Mode',
                subtitle:
                    'Only log opponent moves (assumes you follow suggestions)',
                value: InputLogMode.quickMode,
                groupValue: settings.inputLogMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputLogMode(mode!),
              ),
              _buildDivider(),
              _buildRadioTile<InputLogMode>(
                title: 'Full-Mode',
                subtitle: 'Log both your moves and opponent moves',
                value: InputLogMode.fullMode,
                groupValue: settings.inputLogMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputLogMode(mode!),
              ),
              _buildDivider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Pawn Promotion',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<PromotionChoice>(
                  value: settings.promotionChoice,
                  dropdownColor: buttonColor,
                  style: const TextStyle(color: white),
                  isExpanded: true,
                  underline: Container(height: 1, color: Colors.white24),
                  icon: const Icon(Icons.arrow_drop_down, color: white),
                  items: PromotionChoice.values.map((PromotionChoice choice) {
                    return DropdownMenuItem<PromotionChoice>(
                      value: choice,
                      child: Text(
                        choice.name[0].toUpperCase() + choice.name.substring(1),
                        style: const TextStyle(color: white),
                      ),
                    );
                  }).toList(),
                  onChanged: (PromotionChoice? newValue) {
                    if (newValue != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .setPromotionChoice(newValue);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Input Mode'),
          _buildSection(
            children: [
              _buildRadioTile<InputMode>(
                title: 'PocketGM (BLE Device)',
                value: InputMode.bleMode,
                groupValue: settings.inputMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputMode(mode!),
              ),
              if (settings.inputMode == InputMode.bleMode)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    leading: Icon(
                      bluetooth.connectedDevice != null
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: bluetooth.connectedDevice != null
                          ? Colors.greenAccent
                          : Colors.white54,
                      size: 20,
                    ),
                    title: Text(
                      bluetooth.connectedDevice != null
                          ? (bluetooth.connectedDevice!.platformName.isNotEmpty
                                ? bluetooth.connectedDevice!.platformName
                                : "Connected Device")
                          : 'Not connected',
                      style: TextStyle(
                        color: bluetooth.connectedDevice != null
                            ? white
                            : Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onTap: () => context.push('/bluetooth'),
                  ),
                ),
              _buildDivider(),
              _buildRadioTile<InputMode>(
                title: 'Standalone (Mobile Volume Buttons)',
                value: InputMode.standaloneMode,
                groupValue: settings.inputMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputMode(mode!),
              ),
              _buildDivider(),
              _buildRadioTile<InputMode>(
                title: 'Interface (On-screen buttons)',
                value: InputMode.interfaceMode,
                groupValue: settings.inputMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputMode(mode!),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Vibration'),
          _buildSection(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Strength',
                          style: TextStyle(
                            color: white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${settings.vibrationStrength}',
                          style: const TextStyle(color: white),
                        ),
                      ],
                    ),
                    Slider(
                      activeColor: white,
                      inactiveColor: Colors.white24,
                      value: settings.vibrationStrength.toDouble(),
                      min: 0,
                      max: 255,
                      divisions: 255,
                      onChanged: (double value) {
                        ref
                            .read(settingsProvider.notifier)
                            .setVibrationStrength(value.toInt());
                      },
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Pattern Speed',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile<VibrationSpeed>(
                      title: 'Slow',
                      value: VibrationSpeed.slow,
                      groupValue: settings.vibrationSpeed,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setVibrationSpeed(v!),
                      compact: true,
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile<VibrationSpeed>(
                      title: 'Normal',
                      value: VibrationSpeed.normal,
                      groupValue: settings.vibrationSpeed,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setVibrationSpeed(v!),
                      compact: true,
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile<VibrationSpeed>(
                      title: 'Fast',
                      value: VibrationSpeed.fast,
                      groupValue: settings.vibrationSpeed,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setVibrationSpeed(v!),
                      compact: true,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white10);
  }

  Widget _buildRadioTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    bool compact = false,
  }) {
    return RadioListTile<T>(
      contentPadding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16.0),
      activeColor: white,
      title: Text(
        title,
        style: TextStyle(
          color: white,
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            )
          : null,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      dense: compact,
    );
  }
}
