import 'package:flutter/material.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showCloseButton;

  const CustomAppBar({super.key, this.showCloseButton = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 48),

          const Expanded(
            child: Center(
              child: AppWordmark(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
