import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:project_e_qr_app/main.dart';
import 'package:project_e_qr_app/services/login_validator.dart';
import 'package:project_e_qr_app/widgets/custom_text_field.dart';
import 'package:project_e_qr_app/widgets/form_label.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSaveLogin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      // TODO: Proceed with registration logic
      debugPrint('Full Name: ${_usernameController.text}');
      debugPrint('Nickname: ${_passwordController.text}');

      _validateCreds(_usernameController.text, _passwordController.text);
    }
  }

  Future<void> _validateCreds(String? username, String? pass) async {
    try {
      final result = await LoginValidator.validate(db, username, pass);
      print(result.message);

      if (result.isValid) {
        // Navigate to the QR Scanner page
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
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
        title: const Text(
          'Login',
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
                    'assets/images/login.svg',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your information to\nlogin to your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      color: AppColors.textHighlight,
                    ),
                  ),

                  const FormLabel(label: 'USERNAME'),
                  CustomAppTextField(
                    controller: _usernameController,
                    hintText: 'e.g. UseKey',
                    icon: Icons.person_2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter staff username';
                      }
                      return null;
                    },
                  ),

                  const FormLabel(label: 'PASSWORD'),
                  CustomAppTextField(
                    controller: _passwordController,
                    hintText: 'e.g. ••••••••',
                    icon: Icons.lock,
                    //   obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      _usernameController,
                      _passwordController,
                    ]),
                    builder: (context, child) {
                      final isValid =
                          _usernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty;
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
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: NoSplash.splashFactory,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent, // optional
                    ),
                    child: CheckboxListTile(
                      title: const Text(
                        'Save Login Information',
                        style: TextStyle(
                          color: Colors.white60,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      value: _isSaveLogin,
                      onChanged: (value) {
                        setState(() {
                          _isSaveLogin = value ?? false;
                        });
                      },
                      tileColor: Colors.transparent,
                      activeColor: Colors.black,
                    ),
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
