import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project_e_qr_app/main.dart';
import '../core/theme/app_colors.dart';

class QRScannerView extends StatefulWidget {
  final Function(BarcodeCapture) onDetect;
  final double overlaySize;
  final String? routeName;

  const QRScannerView({
    super.key,
    required this.onDetect,
    this.overlaySize = 280,
    this.routeName,
  });

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _animationController;
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _controller = MobileScannerController(
      facing: CameraFacing.back,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    // Stop the camera when navigating to a new page to release resources
    try {
      _controller.stop();
    } catch (_) {}
  }

  @override
  void didPopNext() {
    // Dispose the old controller and create a fresh one so the MobileScanner
    // widget fully reinitializes its native camera preview (fixes white screen).
    _controller.dispose();
    setState(() {
      _controller = MobileScannerController(facing: _currentFacing);
    });
  }

  void _switchCamera() {
    _controller.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _switchCamera,
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: widget.onDetect,
          ),

          Center(
            child: SizedBox(
              width: widget.overlaySize,
              height: widget.overlaySize,
              child: Stack(
                children: [
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
      ),
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