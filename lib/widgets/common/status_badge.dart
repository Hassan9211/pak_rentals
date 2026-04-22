import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

enum BadgeStyle { active, pending, rejected, booked, verified, admin, custom }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStyle style;
  final Color? customColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.style = BadgeStyle.active,
    this.customColor,
  });

  /// Convenience constructors
  const StatusBadge.active({super.key, required this.label})
      : style = BadgeStyle.active,
        customColor = null;

  const StatusBadge.pending({super.key, required this.label})
      : style = BadgeStyle.pending,
        customColor = null;

  const StatusBadge.rejected({super.key, required this.label})
      : style = BadgeStyle.rejected,
        customColor = null;

  Color get _color {
    if (customColor != null) return customColor!;
    switch (style) {
      case BadgeStyle.active:
        return AppColors.success;
      case BadgeStyle.pending:
        return AppColors.warning;
      case BadgeStyle.rejected:
        return AppColors.error;
      case BadgeStyle.booked:
        return AppColors.cyan;
      case BadgeStyle.verified:
        return AppColors.success;
      case BadgeStyle.admin:
        return AppColors.purple;
      case BadgeStyle.custom:
        return AppColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
