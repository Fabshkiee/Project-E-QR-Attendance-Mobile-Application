import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Header
      appBar: AppBar(
        toolbarHeight: 90.0,
        backgroundColor: AppColors.surfacePrimary,
        foregroundColor: AppColors.textPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/proje_logo.svg',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Project-E Fitness',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Teko',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  'Reception Scanner',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      //Body
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Found barcode: ${barcode.rawValue}');
              }
            },
          ),
          //Overlay
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryAction, width: 2),
              ),
            ),
          ),
        ],
      ),
      //Register button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/registration');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
