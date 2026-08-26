import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class AppRadioTile<T> extends StatelessWidget {
  final T value;
  final String title;

  const AppRadioTile({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
      ),
      value: value,
      tileColor: Colors.transparent,
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.black;
        return Colors.black;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }
}

@Preview(name: 'Radio Tile')
Widget radioTilePreview() {
  return Column(
    children: [
      AppRadioTile<String>(value: 'option1', title: 'Option 1'),
      SizedBox(height: 8),
      AppRadioTile<String>(value: 'option2', title: 'Option 2'),
      SizedBox(height: 8),
      AppRadioTile<String>(value: 'option3', title: 'Option 3'),
    ],
  );
}
