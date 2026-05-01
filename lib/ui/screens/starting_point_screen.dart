import 'package:flutter/material.dart';

import '../../data/mock_learning_content.dart';
import '../common/naroo_widgets.dart';

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
