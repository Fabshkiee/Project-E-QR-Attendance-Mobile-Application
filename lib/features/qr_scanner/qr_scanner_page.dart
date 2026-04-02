import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_e_qr_app/main.dart';
import 'package:project_e_qr_app/powersync/powersync.dart';
import 'package:project_e_qr_app/powersync/tables_reader.dart';
import 'package:project_e_qr_app/widgets/qr_scanner_view.dart';
import 'package:project_e_qr_app/widgets/powersync_status.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false;

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
          QRScannerView(
            onDetect: (result) {
              if (isProcessing) return; // Prevent multiple scans

              final String? scannedValue = result.barcodes.single.rawValue;

              setState(() {
                isProcessing = true;
              });

              () async {
                print('✅ Processing QR code: $scannedValue');

                final List<String> qrParts = scannedValue?.split(':') ?? [];
                if (qrParts.length < 4) {
                  print('Invalid QR format');
                  if (mounted) {
                    setState(() {
                      isProcessing = false;
                    });
                  }
                  return;
                }

                final String org = qrParts[0];
                final String user = qrParts[1];
                final String uid = qrParts[2];
                final String qrToken = qrParts[3];

                if (org != "PROJE") {
                  print("Invalid QR Code");
                }

                if (user == "MEM") {
                  // Step 1: Confirm that Member roles exist in users table.
                  final memberRoleRows = await db.getAll(
                    "SELECT id, short_id, role, qr_token FROM users WHERE LOWER(TRIM(role)) = 'member' LIMIT 1",
                  );

                  if (memberRoleRows.isEmpty) {
                    final roleRows = await db.getAll(
                      'SELECT DISTINCT role FROM users ORDER BY role',
                    );
                    final roles = roleRows
                        .map((row) => row['role']?.toString() ?? '(null)')
                        .join(', ');
                    print('❌ No local users with role Member found. Local roles: $roles');
                  } else {
                    // Step 2: Check if scanned uid matches a Member short_id.
                    final matchedMemberRows = await db.getAll(
                      "SELECT id, short_id, role, qr_token FROM users WHERE LOWER(TRIM(role)) = 'member' AND short_id = ? LIMIT 1",
                      [uid],
                    );

                    if (matchedMemberRows.isEmpty) {
                      print('❌ UID $uid does not match any local user with role Member');
                    } else {
                      final member = matchedMemberRows.first;
                      final localQrToken = member['qr_token']?.toString() ?? '';

                      if (localQrToken.isNotEmpty && localQrToken != qrToken) {
                        print('❌ UID matched Member but qr_token did not match for short_id=$uid');
                      } else {
                        print('✅ Matched Member: id=${member['id']}, short_id=${member['short_id']}, role=${member['role']}');
                      }
                    }
                  }
                } else if (user == "STAFF") {
                  // TODO: choose staff table
                }

                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  setState(() {
                    isProcessing = false;
                  });
                }
              }();
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
