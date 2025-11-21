import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/models/input_mode.dart';
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
    return AppScaffold(
      backgroundColor: white,
      body: ListView(
        children: [
          // Input Mode
          ListTile(
            title: Text(
              'Input Mode',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          RadioListTile<InputMode>(
            title: Text('Quick-Mode'),
            subtitle: Text(
              'Only log opponent moves (assumes you follow suggestions)',
            ),
            value: InputMode.quickMode,
            groupValue: settings.inputMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(settingsProvider.notifier).setInputMode(mode);
              }
            },
          ),

          RadioListTile<InputMode>(
            title: Text('Full-Mode'),
            subtitle: Text('Log both your moves and opponent moves'),
            value: InputMode.fullMode,
            groupValue: settings.inputMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(settingsProvider.notifier).setInputMode(mode);
              }
            },
          ),
        ],
      ),
    );
  }
}
