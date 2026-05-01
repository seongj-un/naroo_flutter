import 'package:flutter/material.dart';

import '../common/naroo_widgets.dart';

class SavedProgressScreen extends StatelessWidget {
  const SavedProgressScreen({
    super.key,
    required this.startingPoint,
    required this.missionCompleted,
    required this.onHome,
    required this.onContinue,
  });

  final String? startingPoint;
  final bool missionCompleted;
  final VoidCallback onHome;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 32),
          Text(
            '마지막 위치를 저장해뒀어요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '오늘은 여기서 이어가면 돼요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          PlainPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('최근 진단', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  startingPoint ?? '함수 그래프가 나오면 막혀요',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PlainPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '다음 추천 행동',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  missionCompleted
                      ? '다음에는 식 변형부터 이어갈게요.'
                      : '함수 그래프 읽기 10분 복구를 이어갈 수 있어요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProgressLine(label: missionCompleted ? '완료한 미션 1개' : '진행 중인 미션 1개'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onContinue,
            child: Text(missionCompleted ? '학습 홈으로 가기' : '미션 이어가기'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onHome, child: const Text('학습 홈')),
        ],
      ),
    );
  }
}
