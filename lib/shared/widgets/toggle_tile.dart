import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/motion.dart';
import 'package:surveys/shared/widgets/pressable.dart';

class AppToggleTile<T> extends StatelessWidget {
  final T value;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const AppToggleTile({
    super.key,
    required this.value,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.quick),
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.atomictangerine : Colors.transparent,
          // The border thickens as well as filling, so selection still reads
          // without relying on colour alone.
          border: Border.all(color: Colors.black, width: isActive ? 2 : 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppMotion.of(context, AppMotion.quick),
          curve: AppMotion.standard,
          style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
              .copyWith(
                color: Colors.black,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
          child: Text(title),
        ),
      ),
    );
  }
}

@Preview(name: "Toggle Tile")
Widget toggleTilePreview() {
  return Column(
    children: [
      AppToggleTile<String>(
        value: 'option1',
        title: 'Option 1',
        isActive: false,
        onTap: () {},
      ),
      const SizedBox(height: 8),
      AppToggleTile<String>(
        value: 'option2',
        title: 'Option 2',
        isActive: true,
        onTap: () {},
      ),
    ],
  );
}
