import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/models/game_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/input_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';

class InputArea extends ConsumerWidget {
  const InputArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final inputMode = settings.inputMode;
    final gameState = ref.watch(gameProvider);

    final isUserTurn = gameState.sideToMove == gameState.playingAs;
    final isQuickMode = settings.gameMode == GameMode.quick;
    final isInputAllowed = !(isUserTurn && isQuickMode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, settings),
          const SizedBox(height: 20),
          _buildContent(context, ref, inputMode, isInputAllowed, settings),
          const SizedBox(height: 12), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    SettingsProvider settings,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<InputMode>(
              value: settings.inputMode,
              dropdownColor: const Color(0xFF2C2C2C),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 20,
              ),
              isDense: true,
              items: const [
                DropdownMenuItem(
                  value: InputMode.bleMode,
                  child: Text("PocketGM"),
                ),
                DropdownMenuItem(
                  value: InputMode.standaloneMode,
                  child: Text("Standalone"),
                ),
                DropdownMenuItem(
                  value: InputMode.interfaceMode,
                  child: Text("Interface"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setInputMode(value);
                }
              },
            ),
          ),
        ),
        if (settings.playingAs == Side.black)
          Row(
            children: [
              const Text(
                "Rotate Input",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: settings.rotateBoardForBlack,
                activeColor: white,
                activeTrackColor: buttonColor,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setRotateBoardForBlack(value);
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InputMode mode,
    bool isInputAllowed,
    SettingsProvider settings,
  ) {
    final isFlipped =
        settings.playingAs == Side.black && settings.rotateBoardForBlack;
    final colRange = isFlipped ? "h-a" : "a-h";
    final rowRange = isFlipped ? "8-1" : "1-8";

    switch (mode) {
      case InputMode.interfaceMode:
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                label: "Increment",
                icon: Icons.add_rounded,
                onPressed: isInputAllowed
                    ? () => ref.read(inputProvider.notifier).increment()
                    : null,
                onLongPress: isInputAllowed
                    ? () => ref
                          .read(inputProvider.notifier)
                          .handleLongPressIncrement()
                    : null,
                color: Colors.blueGrey.shade700,
                isActive: isInputAllowed,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                label: "Confirm",
                icon: Icons.check_rounded,
                onPressed: isInputAllowed
                    ? () => ref.read(inputProvider.notifier).confirm()
                    : null,
                onLongPress: isInputAllowed
                    ? () => ref
                          .read(inputProvider.notifier)
                          .handleLongPressConfirm()
                    : null,
                color: buttonColor,
                isActive: isInputAllowed,
              ),
            ),
          ],
        );

      case InputMode.standaloneMode:
        return _buildInstructionCard(
          context,
          icon: Icons.volume_up_rounded,
          title: "Volume Control",
          text:
              "Use volume buttons to input moves.\nCols: $colRange | Rows: $rowRange",
        );

      case InputMode.bleMode:
        return Column(
          children: [
            _buildInstructionCard(
              context,
              icon: Icons.bluetooth_connected_rounded,
              title: "Bluetooth Device",
              text:
                  "Connect PocketGM device.\nCols: $colRange | Rows: $rowRange",
            ),
          ],
        );
    }
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Color color,
    required bool isActive,
  }) {
    return Material(
      color: isActive ? color : color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.white38,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
