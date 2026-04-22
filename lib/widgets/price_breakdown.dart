import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../widgets/common/glass_card.dart';

class PriceBreakdown extends StatelessWidget {
  final double baseRate;
  final String baseRateUnit; // e.g. '/day', '/month'
  final int quantity; // days / months
  final double platformFeePercent;
  final double? deliveryFee;
  final double? discount;
  final String? discountLabel;

  const PriceBreakdown({
    super.key,
    required this.baseRate,
    required this.baseRateUnit,
    required this.quantity,
    this.platformFeePercent = 10.0,
    this.deliveryFee,
    this.discount,
    this.discountLabel,
  });

  double get _base => baseRate * quantity;
  double get _fee => _base * (platformFeePercent / 100);
  double get _total => _base + _fee + (deliveryFee ?? 0) - (discount ?? 0);

  String _fmt(double v) => 'PKR ${v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _row(
            '${_fmt(baseRate)} × $quantity ${baseRateUnit.replaceAll('/', '')}',
            _fmt(_base),
          ),
          const SizedBox(height: 4),
          _row(
            'Platform fee (${platformFeePercent.toInt()}%)',
            _fmt(_fee),
          ),
          if (deliveryFee != null && deliveryFee! > 0) ...[
            const SizedBox(height: 4),
            _row('Delivery fee', _fmt(deliveryFee!)),
          ],
          if (discount != null && discount! > 0) ...[
            const SizedBox(height: 4),
            _row(
              discountLabel ?? 'Discount',
              '-${_fmt(discount!)}',
              valueColor: AppColors.cyan,
              labelColor: AppColors.cyan,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.borderLight, height: 1),
          ),
          _row(
            'Total',
            _fmt(_total),
            bold: true,
            labelColor: AppColors.textPrimary,
            valueColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    Color labelColor = AppColors.textMuted,
    Color valueColor = AppColors.textMuted,
    bool bold = false,
  }) {
    final style = GoogleFonts.dmSans(
      fontSize: 12,
      color: labelColor,
      fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: valueColor)),
      ],
    );
  }
}
