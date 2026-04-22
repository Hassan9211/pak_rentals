import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppLogo extends StatelessWidget {
  final double fontSize;
  final Color? accentColor;

  const AppLogo({super.key, this.fontSize = 18, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Pak',
            style: GoogleFonts.syne(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: 'Rentals',
            style: GoogleFonts.syne(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: accentColor ?? AppColors.cyan,
            ),
          ),
        ],
      ),
    );
  }
}
