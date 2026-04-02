import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_e_qr_app/main.dart';
import 'package:project_e_qr_app/powersync/powersync.dart';
import 'package:project_e_qr_app/powersync/tables_reader.dart';
import 'package:project_e_qr_app/widgets/qr_scanner_view.dart';
import 'package:project_e_qr_app/widgets/powersync_status.dart';

final MobileScannerController controller = MobileScannerController(
  formats: [BarcodeFormat.qrCode],
);

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false;
  String? lastScannedValue;

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
          MobileScanner(
            controller: controller,
            onDetect: (result) {
              if (isProcessing) return; // Prevent multiple scans

              final List<Barcode> barcodes = result.barcodes;
              final String? scannedValue = barcodes.single.rawValue;

              setState(() async {
                isProcessing = true;
                //  lastScannedValue = barcodes.isNotEmpty ? barcodes.first.rawValue : null;

                // Process the QR code
                print('✅ Processing QR code: $scannedValue');

                // TODO: Add your validation logic here

                String? qrSplitter = scannedValue;
                List<String> qrParts = qrSplitter?.split(':') ?? [];
                String? org = qrParts[0]; // e.g PROJE
                String? user = qrParts[1]; // e.g MEM or STAFF
                String? uid = qrParts[2]; // e.g staff or number ID
                String? qrToken = qrParts[3]; // qr token

                // First Pass
                if (org != "PROJE") {
                  print("Invalid QR Code");
                }

                // Second Pass
                if (user == "MEM") {
                  // TODO: choose members table
                  await openDatabase();

                  if (uid.isEmpty) {
                    print("Invalid UID in QR Code");
                  } else {
                    final rows = await db.getAll(
                      'SELECT * FROM members WHERE id = ?',
                      [uid],
                    );

                    if (rows.isNotEmpty) {
                      print('✅ Found member: ${rows.first['id']}');
                    } else {
                      print('❌ No member found for uid: $uid');
                    }
                  }
                } else if (user == "STAFF") {
                  // TODO: choose staff table
                }

                // Reset after processing (isScanned = false)
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      isProcessing = false;
                    });
                  }
                });
              });
            },
          ),
          //Camera View
          QRScannerView(onDetect: (capture) {}),
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
