import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PowerSyncStatus extends StatelessWidget {
  const PowerSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    //online
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusActive,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke, width: 2),
      ),
      //circle icon
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.online,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Online',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              color: AppColors.online,
            ),
          ),
        ],
      ),
    );
  }

  //offline
  Widget offline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusActive,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke, width: 2),
      ),
      //circle icon
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.online,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              color: AppColors.online,
            ),
          ),
        ],
      ),
    );
  }
}
