import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../services/booking_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/booking_steps.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  late DateTime _displayMonth;

  // Tracks which date user is currently picking
  bool _pickingCheckIn = true; // true = next tap sets check-in, false = sets check-out

  @override
  void initState() {
    super.initState();
    final bs = BookingState();
    final now = DateTime.now();
    _checkIn = bs.checkIn ?? now;
    _checkOut = bs.checkOut ?? now.add(const Duration(days: 7));
    _displayMonth = DateTime(_checkIn.year, _checkIn.month);
    BookingState().setDates(_checkIn, _checkOut);
  }

  void _selectDate(DateTime tapped) {
    setState(() {
      if (_pickingCheckIn) {
        // First tap — set check-in, auto set check-out to +1 day
        _checkIn = tapped;
        _checkOut = tapped.add(const Duration(days: 1));
        _pickingCheckIn = false; // next tap = check-out
      } else {
        // Second tap — set check-out
        if (tapped.isAfter(_checkIn)) {
          _checkOut = tapped;
          _pickingCheckIn = true; // reset — next tap starts fresh
        } else {
          // Tapped before check-in → restart from this date
          _checkIn = tapped;
          _checkOut = tapped.add(const Duration(days: 1));
          _pickingCheckIn = false;
        }
      }
    });
    BookingState().setDates(_checkIn, _checkOut);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookingState(),
      builder: (context, _) {
        final bs = BookingState();
        final listing = bs.listing;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColors.bgElevated,
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          listing?.title ?? 'Select Dates',
                          style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const BookingSteps(currentStep: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Listing mini card
                        if (listing != null) _buildListingCard(listing),
                        const SizedBox(height: 14),
                        Text('Choose your dates',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        _buildDateRow(bs),
                        const SizedBox(height: 12),
                        _buildCalendar(),
                        const SizedBox(height: 12),
                        _buildPaySummary(bs),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Continue to Payment',
                          onTap: () => Navigator.pushNamed(context, '/payment'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: listing.bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(listing.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('📍 ${listing.location}',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            'PKR ${listing.price}${listing.priceUnit}',
            style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cyan),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BookingState bs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                _pickingCheckIn
                    ? 'Tap a date to set Check-in'
                    : 'Now tap a date to set Check-out',
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _pickingCheckIn = true),
                child: _dateBox(
                  'Check-in',
                  _formatDateFull(_checkIn),
                  isActive: _pickingCheckIn,
                  isSelected: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _pickingCheckIn = false),
                child: _dateBox(
                  'Check-out',
                  _formatDateFull(_checkOut),
                  isActive: !_pickingCheckIn,
                  isSelected: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '${bs.nights} ${bs.unitLabel} · ${bs.fmt(bs.pricePerUnit)}${bs.priceUnitLabel}',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _dateBox(String label, String value,
      {bool isActive = false, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.cyan.withValues(alpha: 0.08)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.cyan : AppColors.borderLight,
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: isActive ? AppColors.cyan : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final headers = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun
    final today = DateTime.now();
    final canGoPrev = DateTime(_displayMonth.year, _displayMonth.month)
        .isAfter(DateTime(today.year, today.month));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        children: [
          // ── Month navigation ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: canGoPrev
                    ? () => setState(() => _displayMonth =
                        DateTime(_displayMonth.year, _displayMonth.month - 1))
                    : null,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: canGoPrev
                        ? AppColors.bgInput
                        : AppColors.bgInput.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight, width: 0.5),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: canGoPrev ? AppColors.textSecondary : AppColors.textMuted.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    _monthName(_displayMonth.month),
                    style: GoogleFonts.syne(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    '${_displayMonth.year}',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month + 1)),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight, width: 0.5),
                  ),
                  child: const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Day headers ──
          Row(
            children: headers
                .map((h) => Expanded(
                      child: Center(
                        child: Text(h,
                            style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // ── Day grid ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 2,
              childAspectRatio: 1.1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              // Empty cells before first day
              if (index < startWeekday) return const SizedBox();

              final day = index - startWeekday + 1;
              final date =
                  DateTime(_displayMonth.year, _displayMonth.month, day);
              final isCheckIn = _isSameDay(date, _checkIn);
              final isCheckOut = _isSameDay(date, _checkOut);
              final isInRange =
                  date.isAfter(_checkIn) && date.isBefore(_checkOut);
              final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
              final isToday = _isSameDay(date, today);

              Color? bg;
              Color textColor = isPast
                  ? AppColors.textMuted.withValues(alpha: 0.25)
                  : AppColors.textPrimary;
              BorderRadius radius = BorderRadius.circular(6);

              if (isCheckIn) {
                bg = AppColors.cyan;
                textColor = Colors.black;
                radius = const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                );
              } else if (isCheckOut) {
                bg = AppColors.cyan;
                textColor = Colors.black;
                radius = const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                );
              } else if (isInRange) {
                bg = AppColors.cyan.withValues(alpha: 0.15);
                textColor = AppColors.cyan;
                radius = BorderRadius.zero;
              }

              return GestureDetector(
                onTap: isPast ? null : () => _selectDate(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: radius,
                    border: isToday && !isCheckIn && !isCheckOut && !isInRange
                        ? Border.all(color: AppColors.cyan.withValues(alpha: 0.5), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: (isCheckIn || isCheckOut)
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                      if (isToday && !isCheckIn && !isCheckOut)
                        Container(
                          width: 4, height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Legend ──
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.cyan, 'Check-in / out'),
              const SizedBox(width: 16),
              _legendDot(AppColors.cyan.withValues(alpha: 0.3), 'Selected range'),
              const SizedBox(width: 16),
              _legendDot(AppColors.cyan.withValues(alpha: 0.5), 'Today', isDot: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, {bool isDot = false}) {
    return Row(
      children: [
        Container(
          width: isDot ? 8 : 12,
          height: isDot ? 8 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: isDot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isDot ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildPaySummary(BookingState bs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        children: [
          _payRow(
            '${bs.fmt(bs.pricePerUnit)} × ${bs.nights} ${bs.unitLabel}',
            bs.fmt(bs.baseAmount),
          ),
          const SizedBox(height: 4),
          _payRow(
            'Platform fee (${AppConstants.platformCommissionPercent.toInt()}%)',
            bs.fmt(bs.platformFee),
          ),
          if (bs.weeklyDiscount > 0) ...[
            const SizedBox(height: 4),
            _payRow(
              'Weekly discount (6%)',
              '-${bs.fmt(bs.weeklyDiscount)}',
              valueColor: AppColors.cyan,
              labelColor: AppColors.cyan,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: AppColors.borderLight, height: 1),
          ),
          _payRow(
            'Total',
            bs.fmt(bs.total),
            labelColor: AppColors.textPrimary,
            valueColor: AppColors.textPrimary,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _payRow(String label, String value,
      {Color labelColor = AppColors.textMuted,
      Color? valueColor,
      bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                color: labelColor,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                color: valueColor ?? labelColor,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateFull(DateTime d) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _monthName(int m) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return months[m - 1];
  }
}
