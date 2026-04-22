import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class BookingSteps extends StatelessWidget {
  final int currentStep; // 0=Dates, 1=Review, 2=Payment, 3=Confirm

  const BookingSteps({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Dates', 'Review', 'Payment', 'Confirm'];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          final color = (isDone || isActive) ? AppColors.cyan : AppColors.textMuted;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: (isDone || isActive)
                        ? AppColors.cyan
                        : AppColors.borderLight,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: color,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
