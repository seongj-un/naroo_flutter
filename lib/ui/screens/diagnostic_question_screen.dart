import 'package:flutter/material.dart';

import '../../domain/diagnostic_models.dart';
import '../common/naroo_widgets.dart';

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
