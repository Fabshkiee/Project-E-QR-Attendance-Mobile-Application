import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class CustomAppTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final void Function(String?)? onChanged; // For text fields that update the widget
  final List<TextInputFormatter>? inputFormatters; // as-you-type validation 

  const CustomAppTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.validator,
    this.textInputAction,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: TextFormField(
        controller: controller,
        validator: validator,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
            color: AppColors.inputFieldText,
          ),
          prefixIcon: Icon(icon),
          prefixIconColor: AppColors.textSubtle,
          filled: true,
          fillColor: AppColors.surfacePrimary,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.textHighlight),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
