import 'package:flutter/material.dart';

import '../common/naroo_widgets.dart';

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
