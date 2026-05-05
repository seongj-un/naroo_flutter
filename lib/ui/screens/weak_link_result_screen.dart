import 'package:flutter/material.dart';

import '../../domain/diagnostic_models.dart';
import '../../domain/learning_models.dart';
import '../common/naroo_widgets.dart';

class WeakLinkResultScreen extends StatelessWidget {
  const WeakLinkResultScreen({
    super.key,
    required this.result,
    required this.weakLinks,
    required this.onStartRecovery,
    required this.onSaveForLater,
  });

  final DiagnosticResult result;
  final List<WeakLink> weakLinks;
  final VoidCallback onStartRecovery;
  final VoidCallback onSaveForLater;

  @override
  Widget build(BuildContext context) {
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
              StatPill(label: '전체', value: '${result.totalQuestionCount}'),
              StatPill(label: '연결됨', value: '${result.correctCount}'),
              StatPill(label: '다시 볼 곳', value: '${result.wrongCount}'),
              StatPill(label: '모름', value: '${result.unknownCount}'),
            ],
          ),
          const SizedBox(height: 24),
          Text('약한 연결', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final weakLink in weakLinks) ...[
            WeakLinkRow(title: weakLink.title, body: weakLink.body),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
          PlainPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('첫 복구 미션', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  result.nextMissionTitle ?? '첫 10분 회복 미션',
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
