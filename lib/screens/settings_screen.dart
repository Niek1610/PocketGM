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

          RadioListTile<InputLogMode>(
            title: Text('Quick-Mode'),
            subtitle: Text(
              'Only log opponent moves (assumes you follow suggestions)',
            ),
            value: InputLogMode.quickMode,
            groupValue: settings.inputLogMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(settingsProvider.notifier).setInputLogMode(mode);
              }
            },
          ),

          RadioListTile<InputLogMode>(
            title: Text('Full-Mode'),
            subtitle: Text('Log both your moves and opponent moves'),
            value: InputLogMode.fullMode,
            groupValue: settings.inputLogMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(settingsProvider.notifier).setInputLogMode(mode);
              }
            },
          ),
        ],
      ),
    );
  }
}
