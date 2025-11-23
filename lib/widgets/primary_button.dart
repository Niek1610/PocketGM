import 'package:flutter/material.dart';
import 'package:pocketgm/constants/colors..dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final String text;
  final IconData? icon;
  final double width;
  final double height;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    required this.text,
    this.icon,
    this.width = double.infinity,
    this.height = 60,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: white.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
