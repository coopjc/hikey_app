import 'package:flutter/material.dart';

class HikeyTextField extends StatefulWidget {
  const HikeyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.focusNode,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final FocusNode? focusNode;

  final bool obscure;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final String? errorText;

  final int? minLines;
  final int maxLines;

  @override
  State<HikeyTextField> createState() => _HikeyTextFieldState();
}

class _HikeyTextFieldState extends State<HikeyTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = !widget.obscure && widget.maxLines > 1;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscured,
      // Obscured text has to stay on a single line.
      minLines: widget.obscure ? null : widget.minLines,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        errorMaxLines: 2,
        alignLabelWithHint: isMultiline,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: _obscured ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
