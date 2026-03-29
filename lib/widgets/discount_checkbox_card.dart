import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class DiscountCheckboxCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;

  const DiscountCheckboxCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 71,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryAction : Colors.transparent,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.textHighlight,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textHighlight,
                      fontSize: 12,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
