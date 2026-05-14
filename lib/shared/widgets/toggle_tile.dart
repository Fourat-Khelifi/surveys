import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.atomictangerine : Colors.transparent,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
