import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 共通の入力フィールドウィジェット
class InputField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool autofocus;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;

  const InputField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          autofocus: autofocus,
          maxLines: maxLines,
          enabled: enabled,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding,
          ),
        ),
      ],
    );
  }
}

/// パスワード入力フィールド（表示/非表示切り替え付き）
class PasswordInputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;

  const PasswordInputField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    required this.controller,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      label: widget.label,
      hintText: widget.hintText,
      errorText: widget.errorText,
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: _togglePasswordVisibility,
      ),
    );
  }
}
