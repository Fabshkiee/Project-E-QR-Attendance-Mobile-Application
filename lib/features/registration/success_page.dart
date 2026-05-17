import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  /// Route arguments passed from StaffAuthorizationPage after
  /// MemberRegistrationService.registerNewUser() populated:
  /// - short_id, qr_token, valid_until, started_date, id
  Map<String, dynamic>? _memberData;

  /// Password toggle (optional — kept for completeness)
  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _memberData ??=
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  // ── Derived getters ─────────────────────────────────────────────────────────

  /// e.g. "L5568" → displayed as "L5568"
  String get _formattedMemberId {
    final id = _memberData?['short_id'] ?? '';
    return id.isEmpty ? '—' : id;
  }

  /// e.g. "L0842AX" + "a1b2c3" → "PROJE:MEM:L0842AX:a1b2c3"
  String get _qrData {
    final shortId = _memberData?['short_id'] ?? '';
    final token  = _memberData?['qr_token']  ?? '';
    return 'PROJE:MEM:$shortId:$token';
  }

  /// e.g. "2024-12-15T10:30:00.000Z" → "15 Dec, 2024"
  String get _formattedValidUntil {
    final raw = _memberData?['valid_until'];
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw.toString());
      return DateFormat('dd MMM, y').format(dt);
    } catch (_) {
      return '—';
    }
  }

  String get _fullName => _memberData?['full_name'] ?? 'Unknown';
  String? get _coachId => _memberData?['coach_id'] as String?;
  String get _coachLabel =>
      (_coachId?.isNotEmpty ?? false) ? 'Coach $_coachId' : 'No Coach';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ── Green Checkmark Circle ──
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),

                // ── Title ──
                const Text(
                  'Member Registered\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Member Name ──
                Text(
                  _fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    color: AppColors.textHighlight,
                  ),
                ),
                const SizedBox(height: 28),

                // ── QR Code with Scanner Frame ──
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    children: [
                      // QR code container (centered)
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 148,
                            gapless: false,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),

                      // Scanner corner brackets (red)
                      // Top-left
                      Positioned(
                        top: 4,
                        left: 4,
                        child: _buildCorner(top: true, left: true),
                      ),
                      // Top-right
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _buildCorner(top: true, left: false),
                      ),
                      // Bottom-left
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: _buildCorner(top: false, left: true),
                      ),
                      // Bottom-right
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: _buildCorner(top: false, left: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Instruction text ──
                const Text(
                  'Please take a picture of your information',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    color: AppColors.textHighlight,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Membership Details Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            color: AppColors.primaryAction,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MEMBERSHIP DETAILS',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Member ID
                      _buildDetailRow(
                        icon: Icons.fingerprint,
                        label: 'Member ID',
                        value: _formattedMemberId,
                      ),
                      _buildDivider(),

                      // Password
                      _buildPasswordRow(),
                      _buildDivider(),

                      // Valid Until
                      _buildDetailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Valid Until',
                        value: _formattedValidUntil,
                      ),
                      _buildDivider(),

                      // Status
                      _buildStatusRow(),
                      _buildDivider(),

                      // Coach
                      _buildDetailRow(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Coach',
                        value: _coachLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Return to Scanner Button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAction,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Return to Scanner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Scanner corner bracket widget ──
  Widget _buildCorner({required bool top, required bool left}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _CornerPainter(
          color: AppColors.primaryAction,
          top: top,
          left: left,
          strokeWidth: 3.5,
          length: 24,
          radius: 8,
        ),
      ),
    );
  }

  // ── Detail row ──
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSubtle, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              color: AppColors.textHighlight,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Password row with toggle ──
  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.textSubtle, size: 18),
          const SizedBox(width: 12),
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              color: AppColors.textHighlight,
            ),
          ),
          const Spacer(),
          Text(
            _obscurePassword ? '••••••••' : 'Pass1234',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSubtle,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status row with Active badge ──
  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: AppColors.textSubtle,
            size: 18,
          ),
          const SizedBox(width: 12),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              color: AppColors.textHighlight,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusActive,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.stroke, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    color: AppColors.online,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Divider ──
  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 1,
      thickness: 1,
    );
  }
}

// ── Custom painter for scanner corner brackets ──
class _CornerPainter extends CustomPainter {
  final Color color;
  final bool top;
  final bool left;
  final double strokeWidth;
  final double length;
  final double radius;

  _CornerPainter({
    required this.color,
    required this.top,
    required this.left,
    required this.strokeWidth,
    required this.length,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (top && left) {
      // Top-left corner
      path.moveTo(0, length);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(length, 0);
    } else if (top && !left) {
      // Top-right corner
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, length);
    } else if (!top && left) {
      // Bottom-left corner
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(length, size.height);
    } else {
      // Bottom-right corner
      path.moveTo(size.width, size.height - length);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );
      path.lineTo(size.width - length, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
