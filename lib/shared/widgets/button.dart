import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/motion.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/shared/widgets/pressable.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool enabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;

    final baseStyle = _getButtonStyle();
    final style = enabled
        ? baseStyle
        : baseStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(AppColors.disabled),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          );

    // AppPressable supplies the press feedback; the ElevatedButton keeps its
    // own splash disabled (see _getButtonStyle) so the two don't compete.
    return AppPressable(
      onPressed: effectiveOnPressed,
      scale: 0.97,
      child: IgnorePointer(
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          style: style,
          // Swapping the label crossfades rather than snapping, so
          // "Sign In" -> "Signing in..." doesn't flicker the layout.
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.quick),
            switchInCurve: AppMotion.enter,
            child: Text(
              text,
              key: ValueKey(text),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
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
