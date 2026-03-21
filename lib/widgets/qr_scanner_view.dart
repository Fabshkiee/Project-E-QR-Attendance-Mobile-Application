import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';

class QRScannerView extends StatelessWidget {
  final Function(BarcodeCapture) onDetect;
  final double overlaySize;

  const QRScannerView({
    super.key,
    required this.onDetect,
    this.overlaySize = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Camera View
        MobileScanner(onDetect: onDetect),

        // 2. The Overlay Frame
        Center(
          child: Container(
            width: overlaySize,
            height: overlaySize,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryAction, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
