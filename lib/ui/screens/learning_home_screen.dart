import 'package:flutter/material.dart';

import '../common/naroo_widgets.dart';

class LearningHomeScreen extends StatelessWidget {
  const LearningHomeScreen({
    super.key,
    required this.nickname,
    required this.emailVerified,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.showSavedProgressShortcut,
    required this.onPrimaryAction,
    required this.onSavedProgress,
  });

  final String nickname;
  final bool emailVerified;
  final String title;
  final String body;
  final String buttonLabel;
  final bool showSavedProgressShortcut;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSavedProgress;

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 32),
          Text(
            '$nickname님, 오늘은 한 가지 위치만 찾으면 돼요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ActionPanel(
            title: title,
            body: body,
            buttonLabel: buttonLabel,
            onPressed: onPrimaryAction,
          ),
          if (showSavedProgressShortcut) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onSavedProgress,
                child: const Text('저장된 기록 보기'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ProgressLine(
            label: emailVerified ? '다음 행동을 찾았어요' : '인증 후 다음 행동을 찾을게요',
          ),
        ],
      ),
    );
  }
}
