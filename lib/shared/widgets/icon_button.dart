import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/enums.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;
  final ButtonType type;
  final double size; // height and width

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = 48, // default to match normal button
  });

  @override
  Widget build(BuildContext context) {
    final baseShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    final buttonStyle = switch (type) {
      ButtonType.primary =>
        ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.black,
          shape: baseShape,
          minimumSize: Size.zero,
          fixedSize: Size(size, size), // make square
          padding: EdgeInsets.zero, // inner padding handled by size
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ButtonType.secondary =>
        ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
          shape: baseShape,
          minimumSize: Size.zero,
          fixedSize: Size(size, size),
          padding: EdgeInsets.zero,
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ButtonType.outlined =>
        OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          shape: baseShape,
          side: const BorderSide(color: Colors.black),
          fixedSize: Size(size, size),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ButtonType.text =>
        TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          shape: baseShape,
          fixedSize: Size(size, size),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ).copyWith(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
    };

    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Icon(icon.icon, size: size * 0.5, color: icon.color),
    );
  }
}

@Preview(name: 'Primary Icon Button')
Widget primaryIconButtonPreview() {
  return AppIconButton(
    icon: Icon(Icons.favorite),
    type: ButtonType.primary,
    onPressed: () {},
  );
}

@Preview(name: 'Secondary Icon Button')
Widget secondaryIconButtonPreview() {
  return AppIconButton(
    icon: Icon(Icons.favorite),
    type: ButtonType.secondary,
    onPressed: () {},
  );
}

@Preview(name: 'Outlined Icon Button')
Widget outlinedIconButtonPreview() {
  return AppIconButton(
    icon: Icon(Icons.favorite),
    type: ButtonType.outlined,
    onPressed: () {},
  );
}
