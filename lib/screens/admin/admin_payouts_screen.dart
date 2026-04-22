import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/payment.dart';
import '../../widgets/admin_nav.dart';
import '../../widgets/common/status_badge.dart';

class AdminPayoutsScreen extends StatelessWidget {
  const AdminPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(rightText: 'PKR 124,500 pending', rightColor: AppColors.warning),
            const AdminTopNav(currentIndex: 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary cards
                    Row(
                      children: [
                        _summaryCard('Pending', 'PKR 124,500', AppColors.warning),
                        const SizedBox(width: 8),
                        _summaryCard('Paid Out', 'PKR 890K', AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Payment Records'),
                    const SizedBox(height: 8),
                    ...SamplePayments.records.map((p) => _paymentCard(p)),
                  ],
                ),
              ),
            ),
            const AdminBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
      );

  Widget _paymentCard(Payment p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _gatewayColor(p.gateway).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(_gatewayInitials(p.gateway),
                  style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: _gatewayColor(p.gateway))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.gatewayLabel, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text('Booking: ${p.bookingId}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('PKR ${p.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cyan)),
              const SizedBox(height: 3),
              StatusBadge(
                label: p.statusLabel,
                style: p.status == 'completed'
                    ? BadgeStyle.active
                    : p.status == 'pending'
                        ? BadgeStyle.pending
                        : BadgeStyle.rejected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _gatewayColor(String g) {
    switch (g) {
      case 'jazzcash': return const Color(0xFFE24B4A);
      case 'easypaisa': return const Color(0xFF639922);
      default: return AppColors.cyan;
    }
  }

  String _gatewayInitials(String g) {
    switch (g) {
      case 'jazzcash': return 'JC';
      case 'easypaisa': return 'EP';
      default: return 'BT';
    }
  }
}
