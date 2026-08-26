import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/models/question.dart';
import 'package:surveys/shared/widgets/slider.dart';

class SliderQuestionWidget extends StatelessWidget {
  final Question question;
  final double value;
  final ValueChanged<double> onChanged;

  const SliderQuestionWidget({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (question.description != null && question.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            question.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSubtle,
            ),
          ),
        ],
        const SizedBox(height: 36),

        // Slider
        AppSlider(
          value: value,
          onChanged: onChanged,
          min: question.min ?? 0,
          max: question.max ?? 100,
          divisions: question.divisions ?? 10,
          label: value.round().toString(),
          showLabels: false,
        ),
      ],
    );
  }
}
