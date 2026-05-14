import 'package:flutter/material.dart';
import 'package:surveys/core/models/option.dart';
import 'package:surveys/shared/widgets/radio_tile.dart';

class SingleChoiceQuestion extends StatelessWidget {
  final String title;
  final List<Option>? op;
  final String? selectedValue;
  final Function(String) onChanged;

  const SingleChoiceQuestion({
    super.key,
    required this.title,
    required this.op,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = op ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: RadioGroup<String>(
            groupValue: selectedValue,
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: options.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppRadioTile(value: option.id, title: option.label),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
