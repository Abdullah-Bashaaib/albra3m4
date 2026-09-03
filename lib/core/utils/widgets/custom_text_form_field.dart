import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../constants/app_font.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    required this.label,
    this.obscureText = false,
    this.autoFocus = false,
    this.enabled = true,
    this.hintText,
    this.icon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  final String label;
  final bool obscureText;
  final bool autoFocus;
  final bool enabled;
  final String? hintText;
  final IconData? icon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final bool isPasswordField = widget.obscureText;

    return TextFormField(
      
      controller: widget.controller,
      focusNode: widget.focusNode,
      textDirection: TextDirection.rtl,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: _obscureText,
      autofocus: widget.autoFocus,
      enabled: widget.enabled,
      maxLines: isPasswordField ? 1 : widget.maxLines,
      minLines: widget.minLines,
      style: TextStyle(
        color: widget.enabled ? Colors.black87 : Colors.grey,
        fontFamily: AppFont.primary,
      ),
      decoration: InputDecoration(
        
        labelText: widget.label,
        hintText: widget.hintText,
        labelStyle: TextStyle(
          color: AppColors.primary.withValues(alpha: 0.8),
          fontFamily: AppFont.primary,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: AppFont.primary,
        ),
        filled: true,
        fillColor: widget.enabled ? Colors.transparent : Colors.grey.shade100,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.primary)
            : null,
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
                tooltip: _obscureText
                    ? 'إظهار كلمة المرور'
                    : 'إخفاء كلمة المرور',
              )
            : widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }
}
