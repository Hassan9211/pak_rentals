import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/common/gradient_button.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _selectedType = 0;
  bool _submitted = false;

  final List<Map<String, dynamic>> _types = [
    {'icon': '📋', 'label': 'Booking Dispute', 'color': AppColors.error},
    {'icon': '🚫', 'label': 'Misleading Listing', 'color': AppColors.warning},
    {'icon': '⚠️', 'label': 'Fraud / Scam', 'color': AppColors.error},
    {'icon': '🔞', 'label': 'Inappropriate Content', 'color': AppColors.purple},
  ];

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
          Text('Report an Issue', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you reporting?',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...List.generate(_types.length, (i) {
            final t = _types[i];
            final isSelected = i == _selectedType;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? (t['color'] as Color).withValues(alpha: 0.08) : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? (t['color'] as Color).withValues(alpha: 0.4) : AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(t['icon'] as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(t['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? (t['color'] as Color) : AppColors.textPrimary,
                        )),
                    const Spacer(),
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? (t['color'] as Color) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? (t['color'] as Color) : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)))
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text('Describe the issue',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                hintText: 'Provide as much detail as possible...',
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'False reports may result in account suspension. Only report genuine issues.',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.warning, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            label: 'Submit Report',
            colors: [AppColors.error, const Color(0xFFCC2222)],
            onTap: () => setState(() => _submitted = true),
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
            const Text('📋', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Report Submitted', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Our team will review your report within 24-48 hours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 32),
            GradientButton(label: 'Back to Home', onTap: () => Navigator.pushNamed(context, '/home')),
          ],
        ),
      ),
    );
  }
}
