import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_e_qr_app/widgets/custom_text_field.dart';
import 'package:project_e_qr_app/widgets/custom_dropdown.dart';
import 'package:project_e_qr_app/widgets/form_label.dart';
import 'package:project_e_qr_app/widgets/discount_checkbox_card.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();

  late final ValueNotifier<String?> _selectedMembership;
  late final ValueNotifier<String?> _selectedDuration;
  bool _isDiscountSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedMembership = ValueNotifier<String?>(null);
    _selectedDuration = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _selectedMembership.dispose();
    _selectedDuration.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    double pricePerMonth = 0;

    switch (_selectedMembership.value) {
      case "Basic":
        pricePerMonth = _isDiscountSelected ? 700 : 900;
        break;
      case "Supervision":
        pricePerMonth = _isDiscountSelected ? 1200 : 1500;
        break;
      case "Coaching":
        pricePerMonth = _isDiscountSelected ? 2500 : 3000;
        break;
      default:
        return 0;
    }

    switch (_selectedDuration.value) {
      case "1 Month":
        pricePerMonth = pricePerMonth * 1;
        break;
      case "3 Months":
        pricePerMonth = pricePerMonth * 3;
        break;
      case "6 Months":
        pricePerMonth = pricePerMonth * 6;
        break;
      case "1 Year":
        pricePerMonth = pricePerMonth * 12;
        break;
      default:
        return 0;
    }
    return pricePerMonth;
  }

  void _handleContinue() {
    if (_fullNameController.text.isNotEmpty &&
        _selectedMembership.value != null &&
        _selectedDuration.value != null) {
      // TODO: Proceed with registration logic
      debugPrint('Full Name: ${_fullNameController.text}');
      debugPrint('Nickname: ${_nicknameController.text}');
      debugPrint('Membership: ${_selectedMembership.value}');
      debugPrint('Duration: ${_selectedDuration.value}');
    }
  }

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
            onPressed: () => Navigator.pop(context),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SvgPicture.asset(
                    'assets/images/register.svg',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Registration',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your information to\nregister for Project-E gym.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      color: AppColors.textHighlight,
                    ),
                  ),

                  const FormLabel(label: 'FULL NAME'),
                  CustomAppTextField(
                    controller: _fullNameController,
                    hintText: 'e.g. Alex Johnson',
                    icon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),

                  const FormLabel(label: 'NICKNAME (OPTIONAL)'),
                  CustomAppTextField(
                    controller: _nicknameController,
                    hintText: 'e.g. Lex',
                    icon: Icons.alternate_email,
                  ),

                  const FormLabel(label: 'MEMBERSHIP'),
                  CustomAppDropDown(
                    hintText: 'Select Membership',
                    icon: Icons.fitness_center,
                    items: const ["Basic", "Supervision", "Coaching"],
                    value: _selectedMembership.value,
                    onChanged: (val) =>
                        setState(() => _selectedMembership.value = val),
                    validator: (value) =>
                        value == null ? 'Please select membership' : null,
                  ),

                  const FormLabel(label: 'DURATION'),
                  CustomAppDropDown(
                    hintText: 'Select Duration',
                    icon: Icons.calendar_month,
                    items: const ["1 Month", "3 Months", "6 Months", "1 Year"],
                    value: _selectedDuration.value,
                    onChanged: (val) =>
                        setState(() => _selectedDuration.value = val),
                    validator: (value) =>
                        value == null ? 'Please select duration' : null,
                  ),

                  const SizedBox(height: 20),
                  DiscountCheckboxCard(
                    isSelected: _isDiscountSelected,
                    onTap: () => setState(
                      () => _isDiscountSelected = !_isDiscountSelected,
                    ),
                    title: 'Student/Senior/PWD',
                    subtitle: 'Please show your ID to the Staff',
                  ),

                  const SizedBox(height: 20),
                  // Total Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePrimary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            color: AppColors.textHighlight,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₱${_calculateTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
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
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      _fullNameController,
                      _selectedMembership,
                      _selectedDuration,
                    ]),
                    builder: (context, child) {
                      final isValid =
                          _fullNameController.text.isNotEmpty &&
                          _selectedMembership.value != null &&
                          _selectedDuration.value != null;
                      return SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: isValid ? _handleContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? AppColors.primaryAction
                                : AppColors.surfacePrimary.withValues(
                                    alpha: 0.8,
                                  ),
                            disabledBackgroundColor: AppColors.surfacePrimary
                                .withValues(alpha: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: isValid ? 5 : 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
