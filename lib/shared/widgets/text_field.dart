import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final int? maxLength;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final bool obscureText;
  final bool isMultiline;

  const AppTextField({
    super.key,
    required this.hint,
    this.maxLength,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.showCounter = true,
    this.obscureText = false,
    this.isMultiline = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxLength = widget.maxLength ?? 20;
    final isMultiline = widget.isMultiline || maxLength > 40;

    final counterText = Text(
      '${_controller.text.length}/$maxLength',
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 2),
    );

    return Stack(
      children: [
        TextFormField(
          controller: _controller,
          maxLength: maxLength,
          maxLines: isMultiline ? null : 1,
          minLines: isMultiline ? 3 : null,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: "",
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              isMultiline ? 28 : 12,
            ),
            enabledBorder: border,
            focusedBorder: focusedBorder,
          ),
        ),

        if (widget.showCounter)
          Positioned(
            bottom: isMultiline ? 8 : 16,
            right: 12,
            child: isMultiline ? counterText : Center(child: counterText),
          ),
      ],
    );
  }
}

@Preview(name: 'Text field single-line')
Widget textFieldSingleLinePreview() {
  return const AppTextField(hint: 'Enter text');
}

@Preview(name: 'Text field multi-line')
Widget textFieldMultiLinePreview() {
  return const AppTextField(hint: 'Enter text', isMultiline: true);
}
