import 'package:flutter/material.dart';

import '../../domain/diagnostic_concept_copy.dart';
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
    required this.onTrustFeedbackSelected,
    required this.selectedTrustFeedbackChoice,
    required this.isSubmittingTrustFeedback,
    this.trustFeedbackMessage,
  });

  final DiagnosticResult result;
  final List<WeakLink> weakLinks;
  final VoidCallback onStartRecovery;
  final VoidCallback onSaveForLater;
  final ValueChanged<DiagnosticResultTrustFeedbackChoice>
  onTrustFeedbackSelected;
  final DiagnosticResultTrustFeedbackChoice? selectedTrustFeedbackChoice;
  final bool isSubmittingTrustFeedback;
  final String? trustFeedbackMessage;

  @override
  Widget build(BuildContext context) {
    final trustPromptText = '이 시작 위치가 지금 나한테 맞는 편이었나요?';

    return NarooPage(
      child: ListView(
        children: [
          const BrandHeader(),
          const SizedBox(height: 32),
          Text(
            '전체가 무너진 게 아니에요. 여기부터 다시 연결하면 돼요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '지금은 가장 먼저 다시 연결할 한 지점만 잡으면 충분해요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text('약한 연결', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final weakLink in weakLinks) ...[
            WeakLinkRow(title: weakLink.title, body: weakLink.body),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          Text('빠른 요약', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
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
          PlainPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('첫 복구 미션', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  diagnosticMissionTitleFor(
                    result.primaryRecoveryConcept,
                    fallbackTitle: result.nextMissionTitle,
                  ),
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
          const SizedBox(height: 12),
          PlainPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trustPromptText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (selectedTrustFeedbackChoice == null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('꽤 맞아요'),
                        selected: false,
                        onSelected: isSubmittingTrustFeedback
                            ? null
                            : (_) => onTrustFeedbackSelected(
                                DiagnosticResultTrustFeedbackChoice.feelsRight,
                              ),
                      ),
                      ChoiceChip(
                        label: const Text('애매해요'),
                        selected: false,
                        onSelected: isSubmittingTrustFeedback
                            ? null
                            : (_) => onTrustFeedbackSelected(
                                DiagnosticResultTrustFeedbackChoice.unsure,
                              ),
                      ),
                    ],
                  ),
                  if (isSubmittingTrustFeedback) ...[
                    const SizedBox(height: 12),
                    Text(
                      '기록하는 중...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ] else ...[
                  Text(switch (selectedTrustFeedbackChoice!) {
                    DiagnosticResultTrustFeedbackChoice.feelsRight =>
                      '답해줘서 고마워요. 이 시작 위치가 맞았다는 기록을 남겨둘게요.',
                    DiagnosticResultTrustFeedbackChoice.unsure =>
                      '답해줘서 고마워요. 이 결과가 애매했다는 기록을 남겨둘게요.',
                  }, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (trustFeedbackMessage case final message?) ...[
                  const SizedBox(height: 12),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
