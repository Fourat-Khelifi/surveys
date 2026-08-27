import 'package:flutter/material.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showCloseButton;

  const CustomAppBar({super.key, this.showCloseButton = true});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    // Pull the status bar (clock / battery / signal) inset so the bar's black
    // background runs the full height of the screen edge while the content
    // stays vertically centered within the usable area below it.
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 0),
      height: widget.preferredSize.height + statusBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showCloseButton)
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
}
