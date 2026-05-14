import 'package:flutter/material.dart';
import 'package:surveys/core/models/option.dart';
import 'package:surveys/shared/widgets/toggle_tile.dart';

class MultiChoiceQuestion extends StatelessWidget {
  final String title;
  final List<Option>? op;
  final Set<String> selectedValues;
  final Function(Set<String>) onChanged;

  const MultiChoiceQuestion({
    super.key,
    required this.title,
    required this.op,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = op ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final optionId = option.id;
              final optionLabel = option.label;
              final isActive = selectedValues.contains(optionId);

              return AppToggleTile<String>(
                value: optionId,
                title: optionLabel,
                isActive: isActive,
                onTap: () {
                  final newSelected = Set<String>.from(selectedValues);
                  if (isActive) {
                    newSelected.remove(optionId);
                  } else {
                    newSelected.add(optionId);
                  }
                  onChanged(newSelected);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
