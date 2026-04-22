import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/booking.dart';
import '../../widgets/admin_nav.dart';
import '../../widgets/common/status_badge.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  int _tab = 0; // 0=All, 1=Confirmed, 2=Cancelled

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(rightText: '248 total', rightColor: AppColors.cyan),
            const AdminTopNav(currentIndex: 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab row
                    Row(
                      children: [
                        _tabBtn(0, 'All'),
                        const SizedBox(width: 6),
                        _tabBtn(1, 'Confirmed'),
                        const SizedBox(width: 6),
                        _tabBtn(2, 'Cancelled'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...SampleBookings.myBookings.map((b) => _bookingCard(b)),
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

  Widget _tabBtn(int index, String label) {
    final isActive = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cyan.withValues(alpha: 0.12) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.cyan.withValues(alpha: 0.3) : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: isActive ? AppColors.cyan : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text(b.listingEmoji, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.listingTitle,
                        style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    Text('${b.renterName} → ${b.hostName}',
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              StatusBadge(
                label: b.statusLabel,
                style: b.status == 'confirmed'
                    ? BadgeStyle.active
                    : b.status == 'cancelled'
                        ? BadgeStyle.rejected
                        : BadgeStyle.pending,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PKR ${b.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cyan)),
              Text('${b.nights} nights · ${b.paymentGateway}',
                  style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _actionBtn('View Details', AppColors.cyan),
              const SizedBox(width: 6),
              if (b.status == 'confirmed') _actionBtn('Cancel & Refund', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
