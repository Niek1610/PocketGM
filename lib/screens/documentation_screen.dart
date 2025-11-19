import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors..dart';
import 'package:pocketgm/widgets/app_scaffold.dart';

class DocumentationScreen extends ConsumerStatefulWidget {
  const DocumentationScreen({super.key});

  @override
  ConsumerState<DocumentationScreen> createState() =>
      _DocumentationScreenState();
}

class _DocumentationScreenState extends ConsumerState<DocumentationScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(backgroundColor: white, body: Container());
  }
}
