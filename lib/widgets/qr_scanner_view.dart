import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme/app_colors.dart';

class ScannerProvider {
  static final ScannerProvider _instance = ScannerProvider._internal();
  factory ScannerProvider() => _instance;
  ScannerProvider._internal();

  MobileScannerController? _controller;
  int _activeCount = 0;
  bool _isInitialized = false;

  MobileScannerController get controller {
    if (_controller == null) {
      _controller = MobileScannerController(
        facing: CameraFacing.back,
        autoStart: false,
      );
    }
    return _controller!;
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _controller ??= MobileScannerController(
      facing: CameraFacing.back,
      autoStart: false,
    );
    _isInitialized = true;
  }

  Future<void> start() async {
    _activeCount++;
    if (_activeCount == 1) {
      await _ensureInitialized();
      try {
        await _controller!.start();
      } catch (e) {
        // Already running or not initialized yet
      }
    }
  }

  Future<void> stop() async {
    if (_activeCount <= 0) return;
    _activeCount--;
    if (_activeCount == 0 && _controller != null) {
      try {
        await _controller!.stop();
      } catch (e) {
        // Already stopped
      }
    }
  }

  void switchCamera() {
    _controller?.switchCamera();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _activeCount = 0;
  }
}

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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScannerProvider _scannerProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerProvider = ScannerProvider();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerProvider.start();
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    _scannerProvider.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerProvider.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _scannerProvider.stop();
    } else if (state == AppLifecycleState.resumed) {
      _scannerProvider.start();
    }
  }

  void _switchCamera() {
    _scannerProvider.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _switchCamera,
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerProvider.controller,
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