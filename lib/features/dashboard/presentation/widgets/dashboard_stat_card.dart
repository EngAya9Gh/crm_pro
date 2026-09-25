import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLarge;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorScheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColorScheme.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: isLarge ? 28 : 22),
                ),
                Icon(
                  Icons.trending_up,
                  color: AppColorScheme.success.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  value,
                  style: isLarge
                      ? AppTypography.displayLarge.copyWith(height: 1, fontStyle: FontStyle.normal)
                      : AppTypography.titleLarge.copyWith(height: 1, fontStyle: FontStyle.normal),
                ),
                const SizedBox(height: 8),
                AppText(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColorScheme.textMuted,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
