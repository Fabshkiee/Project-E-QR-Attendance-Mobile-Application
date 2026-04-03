import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:project_e_qr_app/widgets/qr_scanner_view.dart';

class StaffAuthorizationPage extends StatefulWidget {
  const StaffAuthorizationPage({super.key});

  @override
  State<StaffAuthorizationPage> createState() => _StaffAuthorizationPageState();
}

class _StaffAuthorizationPageState extends State<StaffAuthorizationPage> {
  bool isProcessing = false;

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
          'Staff Authorization',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Full-screen Scanner
          QRScannerView(
            onDetect: (result) {
              if (isProcessing) return;
              setState(() {
                isProcessing = true;
              });
              
              // Simulated verification
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  Navigator.pushNamed(context, '/success');
                }
              });
            },
          ),
        ]
      ),
    );
  }
}
