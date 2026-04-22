import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  const BarChartData({required this.label, required this.value, this.color});
}

class SimpleBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final double height;
  final Color? barColor;
  final Color? highlightColor;
  final int? highlightIndex;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 60,
    this.barColor,
    this.highlightColor,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height + 20, // extra for labels
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          final isHighlight = i == (highlightIndex ?? data.length - 1);
          final barH = maxVal > 0 ? (d.value / maxVal) * height : 0.0;
          final color = d.color ??
              (isHighlight
                  ? (highlightColor ?? AppColors.cyan)
                  : (barColor ?? AppColors.cyan).withValues(alpha: 0.3));

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: barH,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    border: isHighlight && d.color == null
                        ? null
                        : Border(
                            top: BorderSide(
                              color: isHighlight
                                  ? (highlightColor ?? AppColors.cyan)
                                  : (barColor ?? AppColors.cyan),
                              width: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d.label,
                  style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
