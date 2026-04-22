import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/admin_nav.dart';
import '../../widgets/common/status_badge.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  int _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.getBookings();
      final list = res['data'] as List? ?? [];
      final meta = res['meta'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _bookings = list.cast<Map<String, dynamic>>();
          _total = meta['total'] as int? ?? _bookings.length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(String id) async {
    try {
      await AdminApi.cancelBooking(id);
      _load();
    } catch (_) {}
  }

  Future<void> _refund(String id) async {
    try {
      await AdminApi.refundBooking(id);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AdminHeader(rightText: '$_total total', rightColor: AppColors.cyan),
            const AdminTopNav(currentIndex: 0),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2))
                  : RefreshIndicator(
                      color: AppColors.purple,
                      backgroundColor: AppColors.bgCard,
                      onRefresh: _load,
                      child: _bookings.isEmpty
                          ? Center(child: Text('No bookings', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _bookings.length,
                              itemBuilder: (context, i) => _bookingCard(_bookings[i]),
                            ),
                    ),
            ),
            const AdminBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> b) {
    final id = b['id'].toString();
    final listing = b['listing'] as Map<String, dynamic>?;
    final renter = b['renter'] as Map<String, dynamic>?;
    final host = b['host'] as Map<String, dynamic>?;
    final status = b['status'] as String? ?? 'pending';
    final payStatus = b['payment_status'] as String? ?? 'pending';
    final total = b['total_amount']?.toString() ?? '0';

    final statusColor = status == 'active' || status == 'completed'
        ? AppColors.success
        : status == 'cancelled' || status == 'rejected'
            ? AppColors.error
            : AppColors.warning;

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
                decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(6)),
                child: const Center(child: Text('🏠', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing?['title'] as String? ?? 'Booking',
                        style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    Text('${renter?['name'] ?? 'Renter'} → ${host?['name'] ?? 'Host'}',
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              StatusBadge(label: status, style: BadgeStyle.custom, customColor: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PKR $total', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cyan)),
              Text('Pay: $payStatus', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (status != 'cancelled' && status != 'completed')
                _actionBtn('Cancel', AppColors.error, () => _cancel(id)),
              if (payStatus == 'paid') ...[
                const SizedBox(width: 6),
                _actionBtn('Refund', AppColors.warning, () => _refund(id)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
