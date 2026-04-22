import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/common/gradient_button.dart';

class SubmitReviewScreen extends StatefulWidget {
  const SubmitReviewScreen({super.key});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  int _rating = 0;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _submitted ? _buildSuccess() : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text('Leave a Review', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listing card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF0D1F1A), borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('🏠', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3-Bed House – Model Town', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    Text('May 8 – May 14, 2026', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text('How was your experience?', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 20),
          // Star rating
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      i < _rating ? '⭐' : '☆',
                      style: TextStyle(
                        fontSize: 36,
                        color: i < _rating ? AppColors.warning : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (_rating > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'][_rating],
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Text('Your Review', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: TextField(
              maxLines: 5,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Share your experience with this listing...',
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Submit Review',
            onTap: _rating > 0 ? () => setState(() => _submitted = true) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Review Submitted!', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Thank you for your feedback. It helps other renters make better decisions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 32),
            GradientButton(label: 'Back to Dashboard', onTap: () => Navigator.pushNamed(context, '/dashboard')),
          ],
        ),
      ),
    );
  }
}
