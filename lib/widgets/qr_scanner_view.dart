import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme/app_colors.dart';

class QRScannerView extends StatefulWidget {
  final Function(BarcodeCapture) onDetect;
  final double overlaySize;

  const QRScannerView({
    super.key,
    required this.onDetect,
    this.overlaySize = 280,
  });

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize the animation to repeat back and forth
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(onDetect: widget.onDetect),

        Center(
          child: SizedBox(
            width: widget.overlaySize,
            height: widget.overlaySize,
            child: Stack(
              children: [
                //Scanning Animation Line
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: 50 + (_animationController.value * 185),
                      left: 38,
                      right: 38,
                      child: child!,
                    );
                  },
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAction.withValues(alpha: 1),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAction.withValues(alpha: 1),
                          AppColors.primaryAction,
                          AppColors.primaryAction.withValues(alpha: 1),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Your Corners (on top of the line)
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

  Widget _corner({required Alignment alignment}) {
    const double side = 60;
    const double thickness = 4;
    const double radius = 12;

    return ClipRect(
      child: Align(
        alignment: alignment,
        widthFactor: 0.5,
        heightFactor: 0.5,
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
