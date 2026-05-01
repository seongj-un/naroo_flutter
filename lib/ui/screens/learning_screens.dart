import 'package:flutter/material.dart';

import '../../data/mock_learning_content.dart';
import '../../domain/diagnostic_models.dart';
import '../common/naroo_widgets.dart';

class LearningHomeScreen extends StatelessWidget {
  const LearningHomeScreen({
    super.key,
    required this.nickname,
    required this.emailVerified,
    required this.startingPoint,
    required this.hasDiagnosticResult,
    required this.missionCompleted,
    required this.onVerifyEmail,
    required this.onStartDiagnostic,
    required this.onResumeResult,
    required this.onSavedProgress,
  });

  final String nickname;
  final bool emailVerified;
  final String? startingPoint;
  final bool hasDiagnosticResult;
  final bool missionCompleted;
  final VoidCallback onVerifyEmail;
  final VoidCallback onStartDiagnostic;
  final VoidCallback onResumeResult;
  final VoidCallback onSavedProgress;

  @override
  Widget build(BuildContext context) {
    final hasStartingPoint = startingPoint != null;
    final title = !emailVerified
        ? '이메일 확인이 필요해요'
        : missionCompleted
        ? '마지막 위치를 저장해뒀어요'
        : hasDiagnosticResult
        ? '첫 복습을 이어갈 수 있어요'
        : hasStartingPoint
        ? '확인 질문을 시작할 수 있어요'
        : '첫 진단을 시작할 수 있어요';
    final body = !emailVerified
        ? '기록을 안전하게 저장한 뒤 시작 위치를 이어갈 수 있어요.'
        : missionCompleted
        ? '오늘은 여기서 이어가면 돼요. 다음에는 식과 그래프 연결을 한 번 더 확인할게요.'
        : hasDiagnosticResult
        ? '결과를 저장해뒀어요. 부담이 가장 적은 첫 10분 복습부터 시작할 수 있어요.'
        : hasStartingPoint
        ? '$startingPoint 쪽에서 가볍게 확인해 볼게요. 아직 점수는 만들지 않아요.'
        : '아직 첫 기록이 없어요. 요즘 가장 막히는 곳부터 가볍게 확인해 볼게요.';
    final buttonLabel = !emailVerified
        ? '이메일 인증하기'
        : missionCompleted
        ? '저장된 기록 보기'
        : hasDiagnosticResult
        ? '첫 10분 복습 시작'
        : hasStartingPoint
        ? '확인 질문 시작'
        : '시작 위치 고르기';
    final onPressed = !emailVerified
        ? onVerifyEmail
        : missionCompleted
        ? onSavedProgress
        : hasDiagnosticResult
        ? onResumeResult
        : onStartDiagnostic;

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
            onPressed: onPressed,
          ),
          const SizedBox(height: 16),
          ProgressLine(
            label: emailVerified ? '다음 행동을 찾았어요' : '인증 후 다음 행동을 찾을게요',
          ),
        ],
      ),
    );
  }
}

class StartingPointScreen extends StatefulWidget {
  const StartingPointScreen({
    super.key,
    required this.selectedStartingPoint,
    required this.onBack,
    required this.onSubmit,
  });

  final String? selectedStartingPoint;
  final VoidCallback onBack;
  final ValueChanged<String> onSubmit;

  @override
  State<StartingPointScreen> createState() => _StartingPointScreenState();
}

class _StartingPointScreenState extends State<StartingPointScreen> {
  late String? _selected = widget.selectedStartingPoint;

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: ListView(
        children: [
          TopBar(onBack: widget.onBack),
          const SizedBox(height: 24),
          Text(
            '요즘 수학에서 어디가 제일 막히나요?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '정확히 몰라도 괜찮아요. 지금 가장 가까운 문장을 고르면 돼요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final startingPoint in startingPointOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceRow(
                label: startingPoint,
                selected: _selected == startingPoint,
                onTap: () => setState(() => _selected = startingPoint),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selected == null
                ? null
                : () => widget.onSubmit(_selected!),
            child: const Text('가볍게 확인하기'),
          ),
        ],
      ),
    );
  }
}

class DiagnosticQuestionScreen extends StatefulWidget {
  const DiagnosticQuestionScreen({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onBack,
    required this.onSubmit,
  });

  final DiagnosticQuestion question;
  final int questionIndex;
  final int totalQuestions;
  final VoidCallback onBack;
  final void Function(DiagnosticQuestion question, String? answerId) onSubmit;

  @override
  State<DiagnosticQuestionScreen> createState() =>
      _DiagnosticQuestionScreenState();
}

class _DiagnosticQuestionScreenState extends State<DiagnosticQuestionScreen> {
  String? _selectedAnswerId;
  bool _selectedUnknown = false;

  bool get _canSubmit => _selectedAnswerId != null || _selectedUnknown;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return NarooPage(
      child: ListView(
        children: [
          TopBar(onBack: widget.onBack),
          const SizedBox(height: 16),
          Semantics(
            label: '진단 진행도',
            child: Text(
              '${widget.questionIndex + 1} / ${widget.totalQuestions}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.concept,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          PlainPanel(
            child: Text(
              question.prompt,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          for (final choice in question.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceRow(
                label: choice.label,
                selected: _selectedAnswerId == choice.id,
                onTap: () {
                  setState(() {
                    _selectedAnswerId = choice.id;
                    _selectedUnknown = false;
                  });
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ChoiceRow(
              label: '잘 모르겠어요',
              selected: _selectedUnknown,
              onTap: () {
                setState(() {
                  _selectedAnswerId = null;
                  _selectedUnknown = true;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '모름을 골라도 괜찮아요. 위치를 찾는 중이에요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _canSubmit
                ? () => widget.onSubmit(question, _selectedAnswerId)
                : null,
            child: Text(
              widget.questionIndex == widget.totalQuestions - 1
                  ? '결과 보기'
                  : '다음 문항',
            ),
          ),
        ],
      ),
    );
  }
}

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

class RecoveryMissionScreen extends StatefulWidget {
  const RecoveryMissionScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  State<RecoveryMissionScreen> createState() => _RecoveryMissionScreenState();
}

class _RecoveryMissionScreenState extends State<RecoveryMissionScreen> {
  final _answerController = TextEditingController();
  bool _hintVisible = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NarooPage(
      child: ListView(
        children: [
          TopBar(onBack: widget.onBack),
          const SizedBox(height: 24),
          Text(
            '함수 그래프 읽기 10분 복구',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('예상 시간 10분', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          PlainPanel(
            child: Text(
              '그래프를 볼 때는 먼저 x값이 오른쪽으로 움직일수록 y값이 위로 가는지, 아래로 가는지 확인해요.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          Text('작은 도전', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'x가 1에서 3으로 갈 때 y가 2에서 6으로 갔다면, y는 얼마나 변했나요?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _hintVisible = true),
            child: const Text('힌트 보기'),
          ),
          if (_hintVisible) ...[
            const SizedBox(height: 12),
            PlainPanel(
              child: Text(
                '첫 단서는 x값이 커질 때 y가 어떻게 움직이는지예요.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
          const SizedBox(height: 16),
          NarooTextField(
            controller: _answerController,
            label: '내 답 적기',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
          Text(
            '아직 정답을 볼 필요는 없어요. 먼저 방향만 잡아볼게요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onSubmit,
            child: const Text('미션 제출하기'),
          ),
        ],
      ),
    );
  }
}

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
