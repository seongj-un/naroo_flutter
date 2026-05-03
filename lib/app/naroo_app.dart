import 'package:flutter/material.dart';

import 'naroo_dependencies.dart';
import 'naroo_shell.dart';
import 'naroo_theme.dart';

class NarooApp extends StatelessWidget {
  NarooApp({super.key, NarooDependencies? dependencies})
    : dependencies = dependencies ?? NarooDependencies.real();

  final NarooDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naroo',
      debugShowCheckedModeBanner: false,
      theme: buildNarooTheme(),
      home: NarooShell(dependencies: dependencies),
    );
  }
}
