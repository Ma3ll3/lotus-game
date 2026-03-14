import 'package:flutter/material.dart';
import '../theme.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintStyle: TextStyle(
            color: context.colors.secondary,
            fontSize: context.texts.bodyMedium.fontSize),
        errorStyle: TextStyle(
            color: context.colors.error, fontSize: context.texts.body.fontSize),
        prefixIcon: Icon(icon),
        labelText: label,
        labelStyle: TextStyle(
            color: context.colors.onPrimary,
            fontSize: context.texts.body.fontSize),
        hintText: hint,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.secondary),
        ),
      ),
    );
  }
}
