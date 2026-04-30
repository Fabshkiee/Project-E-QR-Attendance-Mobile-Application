import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomAppDropDown extends StatelessWidget {
  final String hintText;
  final IconData icon;
  /// Currently supports only string keys for dropdown values.
  /// Convert this to `CustomAppDropDown<T>` when other key/value types are needed.
  final Map<String, String> items;
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CustomAppDropDown({
    super.key,
    required this.hintText,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: DropdownButtonFormField<String>(
        value: value,
        validator: validator,
        hint: Text(
          hintText,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        iconEnabledColor: Colors.white,
        dropdownColor: AppColors.surfacePrimary,
        decoration: InputDecoration(
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
            borderSide: BorderSide.none,
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
        items: items.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
