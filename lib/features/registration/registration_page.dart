import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 30,
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          'Member Registration',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            SvgPicture.asset(
              'assets/images/register.svg',
              width: 64,
              height: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Registration',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your information to\nregister for Project-E gym.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: AppColors.textHighlight,
              ),
            ),
            // member's name
            _buildFieldLabel('FULL NAME'),
            _buildTextField('e.g. Alex Johnson', Icons.badge_outlined),
          ],
        ),
      ),
    );
  }
}

Widget _buildFieldLabel(String label) {
  return Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w700,
        color: AppColors.textHighlight,
      ),
    ),
  );
}

Widget _buildTextField(String hint, IconData icon) {
  return SizedBox(
    width: 360,
    height: 62,
    child: TextFormField(
      style: TextStyle(
        fontSize: 14,
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          color: AppColors.inputFieldText,
        ),
        prefixIcon: Icon(icon),
        prefixIconColor: AppColors.textSubtle,
        filled: true,
        fillColor: AppColors.surfacePrimary,
        //border color selected
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.textHighlight),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}

Widget _buildDropDown(String hint, IconData icon, List<String> items) {
  return SizedBox(
    width: 360,
    height: 62,
    child: DropdownButtonFormField<String>(
      hint: Text(
        hint,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          color: Colors.white, // FORCED WHITE
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
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        prefixIcon: Icon(icon),
        prefixIconColor: AppColors.textSubtle,
        filled: true,
        fillColor: AppColors.surfacePrimary,
        //border color selected
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      items: items
          .map(
            (String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: (String? newValue) {
        // Handle the selected value
      },
    ),
  );
}
