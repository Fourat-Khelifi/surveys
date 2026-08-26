import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/models/option.dart';
import 'package:surveys/shared/widgets/radio_tile.dart';

class SingleChoiceQuestion extends StatelessWidget {
  final String title;
  final String? description;
  final List<Option>? op;
  final String? selectedValue;
  final Function(String) onChanged;

  const SingleChoiceQuestion({
    super.key,
    required this.title,
    this.description,
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSubtle,
            ),
          ),
        ],

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
