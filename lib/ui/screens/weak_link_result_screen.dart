import 'package:flutter/material.dart';

import '../../data/mock_learning_content.dart';
import '../../domain/diagnostic_models.dart';
import '../common/naroo_widgets.dart';

class WeakLinkResultScreen extends StatelessWidget {
  const WeakLinkResultScreen({
    super.key,
    required this.answers,
    required this.onStartRecovery,
    required this.onSaveForLater,
  });

  final Map<String, DiagnosticAnswer> answers;
  final VoidCallback onStartRecovery;
  final VoidCallback onSaveForLater;

  @override
  Widget build(BuildContext context) {
    final correctCount = diagnosticQuestions.where((question) {
      final answer = answers[question.id];
      return answer?.answerId == question.correctAnswerId;
    }).length;
    final unknownCount = answers.values
        .where((answer) => answer.isUnknown)
        .length;
    final wrongCount = answers.length - correctCount - unknownCount;

    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 32),
          Text(
            '전체가 무너진 게 아니에요. 여기부터 다시 연결하면 돼요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatPill(label: '전체', value: '${diagnosticQuestions.length}'),
              StatPill(label: '연결됨', value: '$correctCount'),
              StatPill(label: '다시 볼 곳', value: '$wrongCount'),
              StatPill(label: '모름', value: '$unknownCount'),
            ],
          ),
          const SizedBox(height: 24),
          Text('약한 연결', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const WeakLinkRow(
            title: '기울기 감각',
            body: 'x가 변할 때 y가 얼마나 같이 움직이는지부터 다시 보면 부담이 적어요.',
          ),
          const SizedBox(height: 8),
          const WeakLinkRow(
            title: '식과 그래프 연결',
            body: '식의 숫자가 그래프에서 어디에 보이는지 연결하는 연습이 필요해요.',
          ),
          const SizedBox(height: 8),
          const WeakLinkRow(
            title: '그래프 읽기',
            body: '그래프 모양을 보고 증가와 감소를 말로 바꾸는 연습부터 시작해요.',
          ),
          const SizedBox(height: 24),
          PlainPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('첫 복구 미션', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '함수 그래프 읽기 10분 복구',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onStartRecovery,
            child: const Text('첫 10분 복습 시작'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSaveForLater,
            child: const Text('결과 저장하고 나중에 하기'),
          ),
        ],
      ),
    );
  }
}
