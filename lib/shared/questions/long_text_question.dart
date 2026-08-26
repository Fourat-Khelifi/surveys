import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/models/question.dart';
import 'package:surveys/shared/widgets/text_field.dart';

class LongTextQuestionWidget extends StatelessWidget {
  final Question question;
  final TextEditingController controller;

  const LongTextQuestionWidget({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: Theme.of(context).textTheme.titleLarge,
          softWrap: true,
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
        const SizedBox(height: 12),
        AppTextField(
          hint: "Type your answer here",
          maxLength: question.maxLength,
          controller: controller,
        ),
      ],
    );
  }
}
