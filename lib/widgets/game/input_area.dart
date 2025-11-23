import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/models/input_log_mode.dart';
import 'package:pocketgm/models/input_mode.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/providers/input_provider.dart';
import 'package:pocketgm/providers/settings_provider.dart';
import 'package:pocketgm/widgets/primary_button.dart';

class InputArea extends ConsumerWidget {
  const InputArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final inputMode = settings.inputMode;
    final gameState = ref.watch(gameProvider);

    final isUserTurn = gameState.sideToMove == gameState.playingAs;
    final isQuickMode = settings.inputLogMode == InputLogMode.quickMode;
    final isInputAllowed = !(isUserTurn && isQuickMode);

    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 8),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, settings),
          const SizedBox(height: 16),
          _buildContent(context, ref, inputMode, isInputAllowed, settings),
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
        DropdownButton<InputMode>(
          value: settings.inputMode,
          dropdownColor: const Color.fromARGB(255, 42, 29, 54),
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
          underline: Container(height: 1, color: white.withOpacity(0.3)),
          icon: const Icon(Icons.arrow_drop_down, color: white),
          items: const [
            DropdownMenuItem(value: InputMode.bleMode, child: Text("PocketGM")),
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
        Row(
          children: [
            Text(
              "Rotate Input",
              style: TextStyle(color: white.withOpacity(0.7), fontSize: 12),
            ),
            Switch(
              value: settings.playingAs == Side.black
                  ? settings.rotateBoardForBlack
                  : settings.rotateBoardForWhite,
              onChanged: (val) {
                if (settings.playingAs == Side.black) {
                  ref
                      .read(settingsProvider.notifier)
                      .setRotateBoardForBlack(val);
                } else {
                  ref
                      .read(settingsProvider.notifier)
                      .setRotateBoardForWhite(val);
                }
              },
              activeColor: buttonColor,
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
        (settings.playingAs == Side.black && settings.rotateBoardForBlack) ||
        (settings.playingAs == Side.white && settings.rotateBoardForWhite);
    final colRange = isFlipped ? "h-a" : "a-h";
    final rowRange = isFlipped ? "8-1" : "1-8";

    switch (mode) {
      case InputMode.interfaceMode:
        return Row(
          children: [
            Expanded(
              child: PrimaryButton(
                onPressed: isInputAllowed
                    ? () => ref.read(inputProvider.notifier).increment()
                    : () {},
                onLongPress: isInputAllowed
                    ? () => ref
                          .read(inputProvider.notifier)
                          .handleLongPressIncrement()
                    : null,
                text: "Increment",
                icon: Icons.add,
                backgroundColor: isInputAllowed
                    ? null
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                onPressed: isInputAllowed
                    ? () => ref.read(inputProvider.notifier).confirm()
                    : () {},
                onLongPress: isInputAllowed
                    ? () => ref
                          .read(inputProvider.notifier)
                          .handleLongPressConfirm()
                    : null,
                text: "Confirm",
                icon: Icons.check,
                backgroundColor: isInputAllowed
                    ? null
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          ],
        );

      case InputMode.standaloneMode:
        return _buildInstructionCard(
          context,
          icon: Icons.volume_up,
          text:
              "Use volume buttons to input moves.\nColumns: $colRange\nRows: $rowRange",
        );

      case InputMode.bleMode:
        return Column(
          children: [
            _buildInstructionCard(
              context,
              icon: Icons.bluetooth,
              text:
                  "Connect PocketGM device.\nColumns: $colRange\nRows: $rowRange",
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              onPressed: () {},
              text: "Connect Device",
              height: 48,
              backgroundColor: Colors.blue.withOpacity(0.2),
            ),
          ],
        );
    }
  }

  Widget _buildInstructionCard(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: white.withOpacity(0.7), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: white.withOpacity(0.9), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
