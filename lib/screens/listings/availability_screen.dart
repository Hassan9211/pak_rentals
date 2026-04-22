import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/common/gradient_button.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  // 0=available, 1=blocked, 2=booked
  final Map<int, int> _dayStatus = {3: 1, 4: 1, 5: 2, 6: 2, 7: 2};

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend(),
                    const SizedBox(height: 16),
                    _buildCalendar(),
                    const SizedBox(height: 20),
                    _buildBlockSection(),
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
              child: GradientButton(label: 'Save Availability', onTap: () => Navigator.pop(context)),
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
          Text('Manage Availability', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(AppColors.success, 'Available'),
        const SizedBox(width: 16),
        _legendItem(AppColors.textMuted, 'Blocked'),
        const SizedBox(width: 16),
        _legendItem(AppColors.cyan, 'Booked'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCalendar() {
    final headers = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final days = List.generate(31, (i) => i + 1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              Text('May 2026', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              ...headers.map((h) => Center(
                    child: Text(h, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  )),
              // 5 empty cells (May starts on Friday)
              ...List.generate(5, (_) => const SizedBox()),
              ...days.map((d) {
                final status = _dayStatus[d] ?? 0;
                Color bg = Colors.transparent;
                Color textColor = AppColors.textPrimary;
                if (status == 1) { bg = AppColors.textMuted.withValues(alpha: 0.2); textColor = AppColors.textMuted; }
                if (status == 2) { bg = AppColors.cyan.withValues(alpha: 0.15); textColor = AppColors.cyan; }

                return GestureDetector(
                  onTap: () {
                    if (status != 2) {
                      setState(() => _dayStatus[d] = status == 0 ? 1 : 0);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text('$d', style: GoogleFonts.dmSans(fontSize: 10, color: textColor)),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Block a Date Range', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _dateBox('From', 'May 20, 2026')),
            const SizedBox(width: 10),
            Expanded(child: _dateBox('To', 'May 25, 2026')),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Center(
              child: Text('Block These Dates', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
