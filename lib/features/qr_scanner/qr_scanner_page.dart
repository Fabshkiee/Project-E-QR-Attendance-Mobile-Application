import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project_e_qr_app/main.dart';
import 'package:project_e_qr_app/services/attendance_remote_service.dart';
import 'package:project_e_qr_app/services/qr_validator.dart';
import 'package:project_e_qr_app/services/tts_service.dart';
import 'package:project_e_qr_app/widgets/qr_scanner_view.dart';
import 'package:project_e_qr_app/widgets/powersync_status.dart';
import 'package:project_e_qr_app/widgets/scan_success_modal.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isProcessing = false;
  bool _isOnline = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  QRValidatorResult? _scanResult;
  bool _showOverlay = false;
  Timer? _overlayTimer;

  StreamSubscription<List<ConnectivityResult>>? _connectionSub;

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  Future<void> _initConnectionStatus() async {
    final current = await Connectivity().checkConnectivity();
    if (!mounted) return;
    final nowOnline = _hasNetwork(current);
    setState(() {
      _isOnline = nowOnline;
    });

    // If already online on app start, retry any queued logs
    if (nowOnline) {
      await _retryQueuedLogs();
    }
  }

  Future<void> _retryQueuedLogs() async {
    try {
      await AttendanceRemoteService.retryQueuedLogs(db);
    } catch (_) {
      // Silently fail — will retry on next connection change
    }
  }

  @override
  void initState() {
    super.initState();
    _initConnectionStatus();

    _connectionSub = Connectivity().onConnectivityChanged.listen((results) async {
      if (!mounted) return;
      final wasOnline = _isOnline;
      final nowOnline = _hasNetwork(results);
      setState(() {
        _isOnline = nowOnline;
      });

      // When coming back online, retry any queued attendance logs
      if (!wasOnline && nowOnline) {
        await _retryQueuedLogs();
      }
    });
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _overlayTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _validateQR(String? scannedValue) async {
    try {
      final result = await QrValidator.validate(db, scannedValue);
      if (!mounted) return;

      if (result.isValid || result.message.contains('Duplicate')) {
        if (result.isValid && result.userId != null) {
          // Log attendance via the dedicated service (writes directly to Supabase)
          if (result.memberStatus == 'Active') {
            await AttendanceRemoteService.logStaffAttendance(
              db: db,
              userId: result.userId!,
              checkInTime: result.checkInTime,
            );
          } else {
            await AttendanceRemoteService.logMemberAttendance(
              db: db,
              userId: result.userId!,
              memberStatus: result.memberStatus,
              checkInTime: result.checkInTime,
            );
          }
          _audioPlayer.play(AssetSource('audio/success.mp3'));
          TtsService.playOnSuccess(result.fullName, result.memberStatus, result.message);
        }
        setState(() {
          _scanResult = result;
          _showOverlay = true;
        });

        _overlayTimer?.cancel();
        _overlayTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showOverlay = false;
            });
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
      }
      print(result.message);
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

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
            PowerSyncStatus(isOnline: _isOnline),
          ],
        ),
      ),
      //Body
      body: Stack(
        children: [
          QRScannerView(
            onDetect: (result) {
              if (isProcessing) return;
              final String? scannedValue = result.barcodes.single.rawValue;
              setState(() {
                isProcessing = true;
              });
              _validateQR(scannedValue);
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
          // Scan Success Overlay (Bottom Left)
          if (_scanResult != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              bottom: _showOverlay ? 60 : -200, // Above bottom bar/nav
              left: 24,
              child: AnimatedOpacity(
                opacity: _showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: ScanResultCard(result: _scanResult!),
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
              Navigator.pushReplacementNamed(context, '/registration');
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
