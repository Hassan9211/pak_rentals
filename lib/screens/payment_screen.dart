import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/booking_state.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/booking_steps.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _agreed = false;

  final List<Map<String, dynamic>> _methods = [
    {'id': 'JazzCash', 'logo': 'JC', 'color': const Color(0xFFE24B4A), 'sub': 'Mobile wallet · Instant'},
    {'id': 'EasyPaisa', 'logo': 'EP', 'color': const Color(0xFF639922), 'sub': 'Mobile wallet · Instant'},
    {'id': 'Bank Transfer', 'logo': 'BT', 'color': const Color(0xFF185FA5), 'sub': '1-2 business days'},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select user's saved payment method if set
    final saved = UserState().paymentMethod;
    if (saved.isNotEmpty) {
      BookingState().setPaymentMethod(saved);
    }
    // Pre-fill phone from user profile
    BookingState().setPaymentPhone(UserState().phone);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookingState(),
      builder: (context, _) {
        final bs = BookingState();
        final selectedMethod = bs.paymentMethod;
        final isBankTransfer = selectedMethod == 'Bank Transfer';

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
                      Text('Choose Payment',
                          style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                const BookingSteps(currentStep: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount header
                        Text(
                          'Pay ${bs.fmt(bs.total)}',
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${bs.nights} ${bs.unitLabel} · ${bs.listing?.title ?? ''}',
                          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),

                        // Payment methods
                        ..._methods.map((m) {
                          final isSelected = selectedMethod == m['id'];
                          return GestureDetector(
                            onTap: () => BookingState().setPaymentMethod(m['id'] as String),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.cyan.withValues(alpha: 0.05)
                                    : AppColors.bgCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.cyan.withValues(alpha: 0.4)
                                      : AppColors.borderLight,
                                  width: isSelected ? 1 : 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 24,
                                    decoration: BoxDecoration(
                                      color: m['color'] as Color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(m['logo'] as String,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['id'] as String,
                                            style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary)),
                                        Text(m['sub'] as String,
                                            style: GoogleFonts.dmSans(
                                                fontSize: 10, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  _RadioCircle(isSelected: isSelected),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 4),

                        // Phone / account field — only for wallet methods
                        if (!isBankTransfer)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight, width: 0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$selectedMethod Mobile Number',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.borderLight, width: 0.5),
                                  ),
                                  child: Text(
                                    bs.paymentPhone.isNotEmpty
                                        ? bs.paymentPhone
                                        : '03XX-XXXXXXX',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: bs.paymentPhone.isNotEmpty
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isBankTransfer)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight, width: 0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bank Account Details',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                _bankRow('Bank', 'HBL / Meezan Bank'),
                                _bankRow('Account', 'PK36HABB0000123456789012'),
                                _bankRow('Title', 'Pak Rentals Pvt Ltd'),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Price breakdown summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight, width: 0.5),
                          ),
                          child: Column(
                            children: [
                              _summaryRow(
                                '${bs.fmt(bs.pricePerUnit)} × ${bs.nights} ${bs.unitLabel}',
                                bs.fmt(bs.baseAmount),
                              ),
                              const SizedBox(height: 4),
                              _summaryRow(
                                'Platform fee (10%)',
                                bs.fmt(bs.platformFee),
                              ),
                              if (bs.weeklyDiscount > 0) ...[
                                const SizedBox(height: 4),
                                _summaryRow(
                                  'Weekly discount',
                                  '-${bs.fmt(bs.weeklyDiscount)}',
                                  valueColor: AppColors.cyan,
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Divider(color: AppColors.borderLight, height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total to pay',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  Text(bs.fmt(bs.total),
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.cyan)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Terms
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 16, height: 16,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: _agreed
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: _agreed ? AppColors.success : AppColors.borderLight,
                                    width: 0.5,
                                  ),
                                ),
                                child: _agreed
                                    ? const Center(
                                        child: Text('✓',
                                            style: TextStyle(
                                                fontSize: 10, color: AppColors.success)))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'I agree to Pak Rentals terms and cancellation policy',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11, color: AppColors.textMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Pay button — shows selected method + amount
                        PrimaryButton(
                          label: isBankTransfer
                              ? 'Confirm Bank Transfer · ${bs.fmt(bs.total)}'
                              : 'Pay ${bs.fmt(bs.total)} via $selectedMethod',
                          onTap: _agreed
                              ? () => Navigator.pushNamed(context, '/confirmation')
                              : null,
                        ),

                        if (!_agreed) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text('Please agree to terms to continue',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11, color: AppColors.error)),
                          ),
                        ],
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

  Widget _bankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                color: valueColor ?? AppColors.textMuted)),
      ],
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;
  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.cyan : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.cyan : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}
