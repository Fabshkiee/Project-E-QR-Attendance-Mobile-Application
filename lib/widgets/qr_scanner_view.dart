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
          child: SizedBox(
            width: overlaySize,
            height: overlaySize,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _corner(alignment: Alignment.topLeft),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: _corner(alignment: Alignment.topRight),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _corner(alignment: Alignment.bottomLeft),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _corner(alignment: Alignment.bottomRight),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //helper to make a corner piece
  Widget _corner({required Alignment alignment}) {
    const double side = 60; // size of the corner area
    const double thickness = 4;
    const double radius = 12;

    return ClipRect(
      child: Align(
        alignment: alignment,
        widthFactor: 0.5, // only show half the width
        heightFactor: 0.5, // only show half the height
        child: Container(
          width: side * 2,
          height: side * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius * 2),
            border: Border.all(
              color: AppColors.primaryAction,
              width: thickness,
            ),
          ),
        ),
      ),
    );
  }
}
