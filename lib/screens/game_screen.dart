import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    return AppScaffold(
      title: "Playing as ${gameState.playingAs.name}",
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      body: Column(),
    );
  }
}
