import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/core/models/question.dart';
import 'package:surveys/shared/widgets/text_field.dart';

class ShortTextQuestionWidget extends StatelessWidget {
  final Question question;
  final TextEditingController controller;
  final ShortTextInputType inputType;

  const ShortTextQuestionWidget({
    super.key,
    required this.question,
    required this.controller,
    this.inputType = ShortTextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;
    List<TextInputFormatter>? inputFormatters;

    switch (inputType) {
      case ShortTextInputType.number:
        keyboardType = TextInputType.number;
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case ShortTextInputType.decimal:
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ];
        break;
      case ShortTextInputType.email:
        keyboardType = TextInputType.emailAddress;
        inputFormatters = null;
        break;
      case ShortTextInputType.phone:
        keyboardType = TextInputType.phone;
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case ShortTextInputType.text:
        keyboardType = TextInputType.text;
        inputFormatters = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          softWrap: true,
        ),
        const SizedBox(height: 12),
        AppTextField(
          hint: "Type your answer here",
          maxLength: question.maxLength,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}
