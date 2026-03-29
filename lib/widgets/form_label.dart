import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FormLabel extends StatelessWidget {
  final String label;

  const FormLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
          color: AppColors.textHighlight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
