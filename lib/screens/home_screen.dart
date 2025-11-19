import 'package:flutter/material.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/widgets/primary_button.dart';
import 'package:pocketgm/widgets/select_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedColor = 'white';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
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
                        setState(() {
                          _selectedColor = 'white';
                        });
                      },
                      isWhite: true,
                      isSelected: _selectedColor == 'white',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SelectButton(
                      onPressed: () {
                        setState(() {
                          _selectedColor = 'black';
                        });
                      },
                      isWhite: false,
                      isSelected: _selectedColor == 'black',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              PrimaryButton(text: "Play a new match", onPressed: () {}),
              Spacer(),
              PrimaryButton(text: "Options", onPressed: () {}),
              SizedBox(height: 16),
              PrimaryButton(text: "Documentation", onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
