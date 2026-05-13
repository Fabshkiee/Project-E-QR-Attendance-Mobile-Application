import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project_e_qr_app/core/theme/app_colors.dart';
import 'package:project_e_qr_app/services/qr_validator.dart';
import 'package:intl/intl.dart';

class ScanResultCard extends StatelessWidget {
  final QRValidatorResult result;

  const ScanResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    String displayStatus = result.memberStatus.toLowerCase();
    int? daysUntil;

    if (result.validUntil != null) {
      final now = DateTime.now();
      final validDate = DateTime(
        result.validUntil!.year,
        result.validUntil!.month,
        result.validUntil!.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      daysUntil = validDate.difference(today).inDays;

      if (displayStatus == 'active' && daysUntil <= 3 && daysUntil >= 0) {
        displayStatus = 'expiring';
      } else if (daysUntil < 0) {
        displayStatus = 'expired';
      }
    }

    Color statusColor;
    String statusText;

    if (!result.isValid) {
      statusColor = AppColors.offline;
      statusText = result.message;
    } else {
      switch (displayStatus) {
        case 'active':
          statusColor = AppColors.online;
          statusText = 'Active';
          break;
        case 'expiring':
          statusColor = AppColors.warning;
          statusText = 'Expiring';
          break;
        case 'expired':
        default:
          statusColor = AppColors.offline;
          statusText = displayStatus == 'expired' ? 'Expired' : 'Inactive';
          break;
      }
    }

    String formattedValidUntil = '';
    if (result.validUntil != null) {
      formattedValidUntil = DateFormat('MMM d, yyyy').format(result.validUntil!);
    }

    String formattedCheckIn = '';
    if (result.checkInTime.isNotEmpty) {
      final dt = DateTime.tryParse(result.checkInTime)?.toLocal();
      if (dt != null) {
        formattedCheckIn = DateFormat('h:mm a').format(dt);
      }
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Status Dot + Name
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.fullName.isEmpty ? 'Unknown User' : result.fullName,
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Text
                Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Details Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        result.isValid ? 'Signed In' : 'Last Check-in',
                        formattedCheckIn.isEmpty ? '--:--' : formattedCheckIn,
                      ),
                      if (result.validUntil != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow('Valid Until', formattedValidUntil),
                      ],
                      if (!result.isValid && result.message.contains('Duplicate')) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Wait Time',
                          '5 seconds',
                          valueColor: AppColors.warning,
                        ),
                      ] else if (displayStatus == 'expiring' && daysUntil != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Notice',
                          daysUntil == 0 ? 'Today' : '$daysUntil days left',
                          valueColor: AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 11,
            color: AppColors.textSubtle,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 11,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


