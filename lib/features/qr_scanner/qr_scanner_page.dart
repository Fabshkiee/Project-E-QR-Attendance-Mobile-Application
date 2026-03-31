import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_e_qr_app/widgets/qr_scanner_view.dart';
import 'package:project_e_qr_app/widgets/powersync_status.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
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
                  'PROJECT-E FITNESS',
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
                    color: AppColors.textHighlight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 30),
            //Status Pill (For PowerSync)
            PowerSyncStatus(),
          ],
        ),
      ),
      //Body
      body: Stack(
        children: [
          //Camera View
          QRScannerView(
            onDetect: (result) {
              final List<Barcode> barcodes = result.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Found barcode: ${barcode.rawValue}');
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 88, left: 32),
            child: Text(
              'Scan Your QR\nCode',
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          //sub text
          Padding(
            padding: const EdgeInsets.only(top: 549, left: 32),
            child: Text(
              'Place the QR code in the frame above',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500,
                color: AppColors.textSubtle,
              ),
            ),
          ),
        ],
      ),
      //Register button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAction.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryAction, AppColors.primaryAction],
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/registration');
            },
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 32),
          ),
        ),
      ),
    );
  }
}
