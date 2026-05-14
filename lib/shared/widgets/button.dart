import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/enums.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _getButtonStyle(),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    final baseStyle = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return switch (type) {
      ButtonType.primary =>
        ElevatedButton.styleFrom(
          backgroundColor: AppColors.atomictangerine,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: baseStyle,
          fixedSize: const Size.fromHeight(48),
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ButtonType.secondary =>
        ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightcyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: baseStyle,
          fixedSize: const Size.fromHeight(48),
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ButtonType.outlined =>
        ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          padding: const EdgeInsets.symmetric(vertical: 14),
          fixedSize: const Size.fromHeight(48),
          shape: baseStyle,
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ButtonType.text =>
        ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: baseStyle,
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
    };
  }
}

@Preview(name: 'Primary button')
Widget primaryButtonPreview() {
  return AppButton(text: 'Submit', type: ButtonType.primary, onPressed: () {});
}

@Preview(name: 'Secondary button')
Widget secondaryButtonPreview() {
  return AppButton(
    text: 'Submit',
    type: ButtonType.secondary,
    onPressed: () {},
  );
}

@Preview(name: 'Outlined button')
Widget outlinedButtonPreview() {
  return AppButton(text: 'Submit', type: ButtonType.outlined, onPressed: () {});
}
