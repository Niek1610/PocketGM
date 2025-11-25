// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pocketgm/constants/colors.dart';

class SelectButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final double width;
  final double height;
  final bool isWhite;
  final bool isSelected;

  const SelectButton({
    super.key,
    required this.onPressed,
    this.text,
    this.width = double.infinity,
    this.height = 60,
    this.isWhite = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isSelected
              ? (isWhite ? white : black.withOpacity(.50))
              : (isWhite ? white.withOpacity(.25) : black.withOpacity(.25)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: isSelected
                ? BorderSide(
                    color: isWhite
                        ? const Color.fromARGB(255, 167, 167, 167)
                        : const Color.fromARGB(255, 26, 26, 26),
                    width: 3,
                  )
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: text != null
            ? Text(
                text!,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: isWhite ? black : white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                String.fromCharCode(0x265A),
                style: TextStyle(
                  fontSize: 40,
                  color: isWhite ? white : black,
                  shadows: [
                    Shadow(
                      offset: const Offset(-1.5, -1.5),
                      color: isWhite ? black : white,
                    ),
                    Shadow(
                      offset: const Offset(1.5, -1.5),
                      color: isWhite ? black : white,
                    ),
                    Shadow(
                      offset: const Offset(1.5, 1.5),
                      color: isWhite ? black : white,
                    ),
                    Shadow(
                      offset: const Offset(-1.5, 1.5),
                      color: isWhite ? black : white,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
