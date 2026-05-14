import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: X icon
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),

          // Center: logo
          Expanded(
            child: Center(
              child: Image.network(
                "https://placehold.co/600x400/png",
                height: 24, // adjust as needed
              ),
            ),
          ),

          // Right: three dots icon
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              // your action
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48); // super thin
}
