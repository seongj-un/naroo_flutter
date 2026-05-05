import 'package:flutter/material.dart';

import '../common/naroo_widgets.dart';

class MissionFeedbackScreen extends StatelessWidget {
  const MissionFeedbackScreen({
    super.key,
    required this.title,
    required this.message,
    required this.onHome,
    required this.onSavedProgress,
  });

  final String title;
  final String message;
  final VoidCallback onHome;
  final VoidCallback onSavedProgress;

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 48),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          const ProgressLine(label: '10분 미션 완료'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onHome, child: const Text('학습 홈으로 돌아가기')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSavedProgress,
            child: const Text('저장된 기록 보기'),
          ),
        ],
      ),
    );
  }
}
