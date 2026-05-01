import 'package:flutter/material.dart';

import 'naroo_shell.dart';
import 'naroo_theme.dart';

class NarooApp extends StatelessWidget {
  const NarooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naroo',
      debugShowCheckedModeBanner: false,
      theme: buildNarooTheme(),
      home: const NarooShell(),
    );
  }
}
