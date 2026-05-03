import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_e_qr_app/widgets/custom_text_field.dart';
import 'package:project_e_qr_app/widgets/custom_dropdown.dart';
import 'package:project_e_qr_app/widgets/form_label.dart';
import 'package:project_e_qr_app/widgets/discount_checkbox_card.dart';
import 'package:project_e_qr_app/models/membership_type.dart';
import 'package:project_e_qr_app/services/membership_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _selectedDuration = TextEditingController();
  String? _durationError;

  // Getters
  String get _parsedFullName => _fullNameController.text.trim();
  String get _parsedNickname => _nicknameController.text.trim();
  String get _parsedStringDuration => _selectedDuration.text;
  int get _parsedIntDuration => int.tryParse(_selectedDuration.text) ?? 0;

  late final ValueNotifier<String?> _selectedMembershipId;
  final List<MembershipType> _membershipTypes = [];
  late Map<String, MembershipType> _membershipMap;
  bool _isDiscountSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedMembershipId = ValueNotifier<String?>(null);
    _loadMembershipTypes();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _selectedMembershipId.dispose();
    _selectedDuration.dispose();
    super.dispose();
  }

  Future<void> _loadMembershipTypes() async {
    final memberships = await MembershipService.fetchMembershipTypes();
    if (!mounted) return;

    setState(() {
      _membershipTypes.clear();
      _membershipTypes.addAll(memberships);
      _membershipMap = {for (final m in memberships) m.id: m};
    });
  }

  double _calculateTotal() {
    final duration = _parsedIntDuration;
    if (duration <= 0) {
      return 0.0;
    }

    final selectedMembershipId = _selectedMembershipId.value;
    if (selectedMembershipId == null) {
      return 0.0;
    }

    final selectedMembership = _membershipMap[selectedMembershipId];
    if (selectedMembership == null) {
      return 0.0;
    }

    final pricePerMonth =
        _isDiscountSelected ? selectedMembership.studentFee : selectedMembership.monthlyFee;

    return pricePerMonth * duration;
  }

  void _handleContinue() {
    if (_parsedFullName.isNotEmpty &&
        _selectedMembershipId.value != null &&
        _parsedStringDuration.isNotEmpty) {
      Navigator.pushNamed(context, '/staff_auth');

      Map<String, dynamic> packagedUser = _packageRegistrationData();
      debugPrint('''
      [USER DATA PACKAGED]:
      FULL NAME: ${packagedUser['full_name']}
      NICKNAME: ${packagedUser['nickname']}
      SELECTED MEMBERSHIP: ${packagedUser['membership_type_id']}
      STARTED: ${packagedUser['started_date']}
      VALID UNTIL: ${packagedUser['valid_until']}
      ''');
    }
  }

  Map<String, dynamic> _packageRegistrationData() {
    Map<String, dynamic> registrationFields = {};

    registrationFields['full_name'] = _parsedFullName;
    registrationFields['nickname'] = _parsedNickname;
    registrationFields['membership_type_id'] = _selectedMembershipId.value;
    
    DateTime today = DateTime.now();
    final durationMonths = _parsedIntDuration;
    DateTime until = DateTime(
      today.year, 
      today.month + durationMonths, 
      today.day, 
      today.hour, 
      today.minute
    );
    registrationFields['started_date'] = today;
    registrationFields['valid_until'] = until;

    return registrationFields;
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                  ),

                  const FormLabel(label: 'MEMBERSHIP'),
                  CustomAppDropDown(
                    hintText: 'Select Membership',
                    icon: Icons.fitness_center,
                    items: {
                      for (final membership in _membershipTypes)
                        membership.id: membership.name,
                    },
                    value: _selectedMembershipId.value,
                    onChanged: (val) =>
                        setState(() => _selectedMembershipId.value = val),
                    validator: (value) =>
                        value == null ? 'Please select membership' : null,
                  ),

                  FormLabel(label: 'DURATION', error: _durationError),
                  CustomAppTextField(
                    controller: _selectedDuration,
                    hintText: 'Months (e.g., 1)',
                    icon: Icons.calendar_month,
                    keyboardType: TextInputType.number,
                    errorText: _durationError,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty) return newValue;
                        final int? value = int.tryParse(newValue.text);

                        if (value != null && value > 12) {
                          // Trigger error state in next frame to avoid build conflicts
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_durationError == null) {
                              setState(() {
                                _durationError = 'Supports up to 12 months';
                              });
                              // Clear error after 2 seconds
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() {
                                    _durationError = null;
                                  });
                                }
                              });
                            }
                          });
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ],
                    onChanged: (value) {
                      if (_durationError != null &&
                          value != null &&
                          int.tryParse(value)! <= 12) {
                        setState(() {
                          _durationError = null;
                        });
                      }
                      setState(() {});
                    },
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
                      _selectedMembershipId,
                      _selectedDuration,
                    ]),
                    builder: (context, child) {
                      final isValid =
                          _parsedFullName.isNotEmpty &&
                          _selectedMembershipId.value != null &&
                          _parsedStringDuration.isNotEmpty;
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
