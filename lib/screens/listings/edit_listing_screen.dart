import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/common/gradient_button.dart';

class EditListingScreen extends StatelessWidget {
  const EditListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current listing preview
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
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1F1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('🏠', style: TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('3-Bed House – Model Town',
                                    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                Text('PKR 25,000/month',
                                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 0.5),
                            ),
                            child: Text('Active', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Title'),
                    const SizedBox(height: 8),
                    _prefilled('3-Bed House – Model Town, Bahawalpur'),
                    const SizedBox(height: 16),
                    _sectionTitle('Description'),
                    const SizedBox(height: 8),
                    _prefilledArea('Spacious 3-bedroom house in the heart of Model Town, Bahawalpur. Fully furnished with modern amenities.'),
                    const SizedBox(height: 16),
                    _sectionTitle('Price'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _prefilled('25000')),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight, width: 0.5),
                          ),
                          child: Text('/month', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Location'),
                    const SizedBox(height: 8),
                    _prefilled('Model Town, Bahawalpur'),
                    const SizedBox(height: 24),
                    // Danger zone
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Danger Zone', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
                              ),
                              child: Center(
                                child: Text('Delete Listing', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.bgElevated,
                border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
              ),
              child: GradientButton(
                label: 'Save Changes',
                onTap: () => Navigator.pop(context),
              ),
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
          Text('Edit Listing', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/availability'),
            child: Text('Availability', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  Widget _prefilled(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Text(value, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary)),
    );
  }

  Widget _prefilledArea(String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Text(value, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
    );
  }
}
