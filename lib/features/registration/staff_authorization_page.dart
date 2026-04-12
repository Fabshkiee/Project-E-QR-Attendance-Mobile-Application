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

          // Content Overlay
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Icon Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: AppColors.primaryAction,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title and Subtitle
                    const Text(
                      'Staff Authorization',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan your staff QR code to authorize\nnew member registration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Global Verification Overlay
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryAction,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Verifying...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
