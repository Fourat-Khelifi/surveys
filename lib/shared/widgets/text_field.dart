import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:surveys/core/constants/colors.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final int? maxLength;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final bool obscureText;
  final bool isMultiline;

  /// Lets the platform password manager fill the field. Without these, iOS and
  /// Android offer nothing and every sign-in is typed by hand.
  final Iterable<String>? autofillHints;

  /// What the keyboard's action key does — `next` to move on, `done` to submit.
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  /// Adds a show/hide control to an obscured field. Typing a password blind on
  /// a phone keyboard is the most common reason a sign-in fails twice.
  final bool showObscureToggle;

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
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.showObscureToggle = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late bool _obscured = widget.obscureText;

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
    final isMultiline = !widget.obscureText && (widget.isMultiline || maxLength > 40);

    final counterText = Text(
      '${_controller.text.length}/$maxLength',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border, width: 2),
    );

    return Stack(
      children: [
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          maxLength: maxLength,
          maxLines: isMultiline ? null : 1,
          minLines: isMultiline ? 3 : null,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: _obscured,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: "",
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.fromLTRB(
              12,
              12,
              widget.obscureText && widget.showObscureToggle ? 48 : 12,
              isMultiline ? 28 : 12,
            ),
            enabledBorder: border,
            focusedBorder: focusedBorder,
            suffixIcon: widget.obscureText && widget.showObscureToggle
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                  )
                : null,
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
