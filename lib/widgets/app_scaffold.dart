import 'package:flutter/material.dart';
import 'package:pocketgm/constants/colors..dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        foregroundColor: white,
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              )
            : null,
        actions: actions,
      ),
      body: body,
    );
  }
}
