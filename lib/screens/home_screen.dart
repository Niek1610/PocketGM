import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/providers/game_provider.dart';
import 'package:pocketgm/widgets/primary_button.dart';
import 'package:pocketgm/widgets/select_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final playingAs = gameState.playingAs;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.08,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/chess_background.png'),
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 64,
                bottom: 64,
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 64),
                    child: Text(
                      'PocketGM',
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge!.copyWith(color: white),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    textAlign: TextAlign.center,
                    "een technisch prototype dat real-time schaakanalyse mogelijk maakt tijdens over-the-board partijen.",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: white),
                  ),
                  SizedBox(height: 64),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Play as:",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: white),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SelectButton(
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .setColor(Side.white);
                          },
                          isWhite: true,
                          isSelected: playingAs == Side.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SelectButton(
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .setColor(Side.black);
                          },
                          isWhite: false,
                          isSelected: playingAs == Side.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  PrimaryButton(
                    text: "Play a new match",
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {},
                  ),
                  Spacer(),
                  PrimaryButton(
                    text: "Options",
                    icon: Icons.settings_outlined,
                    onPressed: () {},
                  ),
                  SizedBox(height: 16),
                  PrimaryButton(
                    text: "Documentation",
                    icon: Icons.article_outlined,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
