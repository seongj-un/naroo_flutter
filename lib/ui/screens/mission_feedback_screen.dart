import 'package:flutter/material.dart';

import '../common/naroo_widgets.dart';

class MissionFeedbackScreen extends StatelessWidget {
  const MissionFeedbackScreen({
    super.key,
    required this.onHome,
    required this.onSavedProgress,
  });

  final VoidCallback onHome;
  final VoidCallback onSavedProgress;

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 48),
          Text(
            '오늘은 여기까지만 해도 충분해요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '함수 그래프 읽기 미션을 완료했어요. 다음에는 식 변형부터 이어갈게요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
