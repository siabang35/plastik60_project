import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      onTap: onTap,
      autofocus: autofocus,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
