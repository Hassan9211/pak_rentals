import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final List<Color> colors;
  final String? photoPath; // local file path

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 32,
    this.colors = const [AppColors.cyan, AppColors.purple],
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    // If photo exists, show it
    if (photoPath != null && photoPath!.isNotEmpty) {
      final file = File(photoPath!);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3), width: 1),
        ),
        child: ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget(),
          ),
        ),
      );
    }
    return _initialsWidget();
  }

  Widget _initialsWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.dmSans(
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
