import 'package:flutter/material.dart';

import '../../domain/learning_models.dart';
import '../common/naroo_widgets.dart';

class StartingPointScreen extends StatefulWidget {
  const StartingPointScreen({
    super.key,
    required this.selectedMathAreaCode,
    required this.options,
    required this.onBack,
    required this.onSubmit,
  });

  final String? selectedMathAreaCode;
  final List<MathAreaOption> options;
  final VoidCallback onBack;
  final ValueChanged<MathAreaOption> onSubmit;

  @override
  State<StartingPointScreen> createState() => _StartingPointScreenState();
}

class _StartingPointScreenState extends State<StartingPointScreen> {
  late String? _selected = widget.selectedMathAreaCode;

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
          for (final mathArea in widget.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceRow(
                label: mathArea.name,
                description: mathArea.description,
                selected: _selected == mathArea.code,
                onTap: () => setState(() => _selected = mathArea.code),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selected == null
                ? null
                : () => widget.onSubmit(
                    widget.options.firstWhere(
                      (mathArea) => mathArea.code == _selected,
                    ),
                  ),
            child: const Text('가볍게 확인하기'),
          ),
        ],
      ),
    );
  }
}
