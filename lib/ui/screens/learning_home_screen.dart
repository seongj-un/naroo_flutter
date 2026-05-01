import 'package:flutter/material.dart';

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
