import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PowerSyncStatus extends StatelessWidget {
  const PowerSyncStatus({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final dotColor = isOnline ? AppColors.online : AppColors.offline;
    final status = isOnline ? AppColors.statusActive : AppColors.statusInactive;
    final strokeStatus = isOnline ? AppColors.stroke : AppColors.offlineStroke;
    final text = isOnline ? 'Online' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: strokeStatus, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}
