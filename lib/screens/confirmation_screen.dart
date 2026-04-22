import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/booking_state.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bs = BookingState();
    final listing = bs.listing;

    // Generate a booking ID
    final bookingId =
        'PKR-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTop(bs),
              _buildBookingCard(bs, listing, bookingId),
              const SizedBox(height: 12),
              _buildActionRow(context),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'A confirmation SMS has been sent to your number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop(BookingState bs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgElevated, Color(0xFF071520)],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            'Booking Confirmed!',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your payment of ${bs.fmt(bs.total)} was received',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingState bs, listing, String bookingId) {
    final checkInStr = listing != null ? _fmtDate(bs.checkIn) : '—';
    final checkOutStr = listing != null ? _fmtDate(bs.checkOut) : '—';
    final nightsLabel = '${bs.nights} ${bs.unitLabel}';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        children: [
          // Head — listing info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: listing?.bgColor ?? AppColors.bgCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      listing?.emoji ?? '🏠',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing?.title ?? 'Listing',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$checkInStr – $checkOutStr · $nightsLabel',
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body — booking details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _ccRow('Host', listing?.hostName ?? '—'),
                const SizedBox(height: 5),
                _ccRow('Location', listing?.location ?? '—'),
                const SizedBox(height: 5),
                _ccRow('Paid via', bs.paymentMethod),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: AppColors.borderLight, height: 1),
                ),
                // Price breakdown
                _ccRow(
                  '${bs.fmt(bs.pricePerUnit)} × ${bs.nights} ${bs.unitLabel}',
                  bs.fmt(bs.baseAmount),
                  valueColor: AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                _ccRow(
                  'Platform fee (10%)',
                  bs.fmt(bs.platformFee),
                  valueColor: AppColors.textSecondary,
                ),
                if (bs.weeklyDiscount > 0) ...[
                  const SizedBox(height: 4),
                  _ccRow(
                    'Weekly discount',
                    '-${bs.fmt(bs.weeklyDiscount)}',
                    valueColor: AppColors.cyan,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: AppColors.borderLight, height: 1),
                ),
                _ccRow(
                  'Total paid',
                  bs.fmt(bs.total),
                  valueColor: AppColors.cyan,
                  bold: true,
                ),
              ],
            ),
          ),

          // Booking ID
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
            ),
            child: Text(
              'Booking ID: $bookingId',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ccRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11, color: AppColors.textMuted)),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final listing = BookingState().listing;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/chat'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    'Message ${listing?.hostName.split(' ').first ?? 'Host'}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (_) => false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}
