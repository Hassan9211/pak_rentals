import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final bool? trendUp;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.trendUp,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    Color trendColor = AppColors.textMuted;
    if (trendUp == true) trendColor = AppColors.success;
    if (trendUp == false) trendColor = AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 2),
            Text(
              trend!,
              style: GoogleFonts.dmSans(fontSize: 9, color: trendColor),
            ),
          ],
        ],
      ),
    );
  }
}
