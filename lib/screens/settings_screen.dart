import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/models/game_mode.dart';
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
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
                          'Stockfish depth',
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
                    Text(
                      'Lower values are faster; higher values improve accuracy.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Game'),
          _buildSection(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Game mode',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
              ),
              _buildRadioTile<GameMode>(
                title: 'Quick mode',
                subtitle:
                    'Enter your opponent\'s moves and follow the vibration suggestions for your own.',
                value: GameMode.quick,
                groupValue: settings.gameMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setGameMode(mode!),
              ),
              _buildDivider(),
              _buildRadioTile<GameMode>(
                title: 'Full mode',
                subtitle:
                    'Enter both players\' moves. Vibrations suggest your next move.',
                value: GameMode.full,
                groupValue: settings.gameMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setGameMode(mode!),
              ),
              _buildDivider(),
              _buildRadioTile<GameMode>(
                title: 'Feedback mode',
                subtitle:
                    'Enter both players\' moves. Vibrations flag blunders and opportunities.',
                value: GameMode.feedback,
                groupValue: settings.gameMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setGameMode(mode!),
              ),
              _buildDivider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Pawn promotion',
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
              _buildDivider(),
              SwitchListTile(
                activeColor: white,
                activeTrackColor: buttonColor,
                title: const Text(
                  'Rotate board for black',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Reverse input and vibration coordinates (h–a, 8–1).',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: settings.rotateBoardForBlack,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setRotateBoardForBlack(value);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Input'),
          _buildSection(
            children: [
              _buildRadioTile<InputMode>(
                title: 'PocketGM device',
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
                                : 'Connected device')
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
                title: 'Phone volume buttons',
                value: InputMode.standaloneMode,
                groupValue: settings.inputMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputMode(mode!),
              ),
              _buildDivider(),
              _buildRadioTile<InputMode>(
                title: 'On-screen buttons',
                value: InputMode.interfaceMode,
                groupValue: settings.inputMode,
                onChanged: (mode) =>
                    ref.read(settingsProvider.notifier).setInputMode(mode!),
              ),
              _buildDivider(),
              SwitchListTile(
                activeColor: white,
                activeTrackColor: buttonColor,
                title: const Text(
                  'Touch input',
                  style: TextStyle(color: white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Drag pieces on the board to enter moves.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: settings.allowTouchInput,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setAllowTouchInput(value);
                },
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
                  'Pattern speed',
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
        title,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
