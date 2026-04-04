import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../core/theme/app_colors.dart';

class CustomAppTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final void Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  const CustomAppTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.validator,
    this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.inputFormatters,
    this.errorText,
  });

  @override
  State<CustomAppTextField> createState() => _CustomAppTextFieldState();
}

class _CustomAppTextFieldState extends State<CustomAppTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CustomAppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double sineValue =
            ((math.sin(_shakeController.value * 4 * math.pi)) * 5);
        return Transform.translate(
          offset: Offset(sineValue, 0),
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            textInputAction: widget.textInputAction,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            inputFormatters: widget.inputFormatters,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: widget.errorText, // Toggle border with error state
              hintStyle: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: AppColors.inputFieldText,
              ),
              prefixIcon: Icon(widget.icon),
              prefixIconColor: AppColors.textSubtle,
              filled: true,
              fillColor: AppColors.surfacePrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              errorStyle: const TextStyle(
                height: 0,
                fontSize: 0,
              ), // Hidden text, only show border
            ),
            onChanged: widget.onChanged,
          ),
        );
      },
    );
  }
}
