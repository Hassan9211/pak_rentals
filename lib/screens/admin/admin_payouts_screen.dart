import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/admin_nav.dart';
import '../../widgets/common/status_badge.dart';

class AdminPayoutsScreen extends StatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  State<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends State<AdminPayoutsScreen> {
  List<Map<String, dynamic>> _payments = [];
  double _pendingTotal = 0;
  double _paidTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.getPayouts();
      final list = (res['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      double pending = 0, paid = 0;
      for (final p in list) {
        final amount = (p['amount'] as num?)?.toDouble() ?? 0;
        if (p['status'] == 'pending') pending += amount;
        if (p['status'] == 'success' || p['status'] == 'completed') paid += amount;
      }
      if (mounted) {
        setState(() {
          _payments = list;
          _pendingTotal = pending;
          _paidTotal = paid;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(double v) {
    if (v >= 1000000) return 'PKR ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'PKR ${(v / 1000).toStringAsFixed(1)}K';
    return 'PKR ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AdminHeader(
              rightText: _loading ? 'Loading...' : '${_fmt(_pendingTotal)} pending',
              rightColor: AppColors.warning,
            ),
            const AdminTopNav(currentIndex: 0),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2))
                  : RefreshIndicator(
                      color: AppColors.purple,
                      backgroundColor: AppColors.bgCard,
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _summaryCard('Pending', _fmt(_pendingTotal), AppColors.warning),
                                const SizedBox(width: 8),
                                _summaryCard('Paid Out', _fmt(_paidTotal), AppColors.success),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _sectionLabel('Payment Records'),
                            const SizedBox(height: 8),
                            if (_payments.isEmpty)
                              Center(child: Text('No payment records', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)))
                            else
                              ..._payments.map((p) => _paymentCard(p)),
                          ],
                        ),
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

  Widget _sectionLabel(String label) => Text(label.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8));

  Widget _paymentCard(Map<String, dynamic> p) {
    final gateway = p['gateway'] as String? ?? 'bank-transfer';
    final amount = (p['amount'] as num?)?.toDouble() ?? 0;
    final status = p['status'] as String? ?? 'pending';
    final bookingId = p['booking_id']?.toString() ?? '';
    final booking = p['booking'] as Map<String, dynamic>?;
    final listingTitle = booking?['listing']?['title'] as String?;

    final gatewayColor = gateway == 'jazzcash'
        ? const Color(0xFFE24B4A)
        : gateway == 'easypaisa'
            ? const Color(0xFF639922)
            : AppColors.cyan;
    final gatewayInitials = gateway == 'jazzcash' ? 'JC' : gateway == 'easypaisa' ? 'EP' : 'BT';

    final statusStyle = status == 'success' || status == 'completed'
        ? BadgeStyle.active
        : status == 'pending'
            ? BadgeStyle.pending
            : BadgeStyle.rejected;

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
              color: gatewayColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(gatewayInitials,
                style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: gatewayColor))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gateway.toUpperCase(),
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(listingTitle ?? 'Booking: $bookingId',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('PKR ${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cyan)),
              const SizedBox(height: 3),
              StatusBadge(label: status, style: statusStyle),
            ],
          ),
        ],
      ),
    );
  }
}
