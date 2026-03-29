import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _isSelected = false;

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
      body: SingleChildScrollView(
        child: Center(
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
              // Nickname
              _buildFieldLabel('NICKNAME (OPTIONAL)'),
              _buildTextField('e.g. Lex', Icons.alternate_email),
              // Membership
              _buildFieldLabel('MEMBERSHIP'),
              _buildDropDown('Select Membership', Icons.fitness_center, [
                "Basic",
                "Supervision",
                "Coaching",
              ]),
              // Duration
              _buildFieldLabel('DURATION'),
              _buildDropDown('Select Duration', Icons.calendar_month, [
                "1 Month",
                "3 Months",
                "6 Months",
                "1 Year",
              ]),
              const SizedBox(height: 20),
              _buildDiscountCheckbox(_isSelected, () {
                setState(() {
                  _isSelected = !_isSelected;
                });
              }),
              const SizedBox(height: 20),
              // Total Amount Card
              Container(
                width: 360,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfacePrimary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        color: AppColors.textHighlight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //TODO: Implement total amount calculation
                    const Text(
                      '₱'
                      '0.00',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Final amount shown based on selected membership and duration.',
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              //TODO: Implement disabled state if required fields have no input
              SizedBox(
                width: 360,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAction,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
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

Widget _buildDiscountCheckbox(bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 360,
      height: 71,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // checkbox/indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryAction : Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.textHighlight,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student/Senior/PWD',
                  style: TextStyle(
                    // Swaps text color for contrast
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
                Text(
                  'Please show your ID to the Staff',
                  style: TextStyle(
                    color: AppColors.textHighlight,
                    fontSize: 12,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
