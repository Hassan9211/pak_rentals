import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/admin_nav.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.getStats();
      final data = res['data'] as Map<String, dynamic>? ?? res;
      if (mounted) setState(() { _stats = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _stats ?? {};
    final revenue = s['revenue_this_month'] ?? s['paid_revenue'] ?? 0;
    final bookings = s['total_bookings'] ?? 0;
    final users = s['verified_users'] ?? s['new_users_this_month'] ?? 0;
    final pending = s['pending_listings'] ?? 0;
    final growth = s['revenue_growth'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(rightText: 'Analytics'),
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
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 2.0,
                              children: [
                                _kpi('Platform Revenue', 'PKR ${_fmt(revenue)}',
                                    trend: growth != 0 ? '${growth > 0 ? '↑' : '↓'} ${growth.abs()}% vs last month' : null,
                                    up: growth >= 0, color: AppColors.purple),
                                _kpi('Total Bookings', '$bookings',
                                    trend: 'All time', color: AppColors.cyan),
                                _kpi('Verified Users', '$users',
                                    trend: 'Verified', color: AppColors.textPrimary),
                                _kpi('Pending Listings', '$pending',
                                    trend: pending > 0 ? 'Needs action' : 'All clear',
                                    up: pending == 0, color: AppColors.warning),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _sectionLabel('Quick Actions'),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight, width: 0.5),
                              ),
                              child: Column(
                                children: [
                                  _quickAction(context, '📋', 'Pending Listings', '$pending awaiting approval',
                                      AppColors.warning, '/admin/listings'),
                                  _quickAction(context, '👥', 'Manage Users', 'Verify & manage accounts',
                                      AppColors.cyan, '/admin/users'),
                                  _quickAction(context, '💳', 'Payouts', 'View payment records',
                                      AppColors.success, '/admin/payouts', isLast: true),
                                ],
                              ),
                            ),
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

  Widget _kpi(String label, String val, {String? trend, bool? up, Color color = AppColors.textPrimary}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
          Text(val, style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          if (trend != null)
            Text(trend, style: GoogleFonts.dmSans(fontSize: 8,
                color: up == null ? AppColors.textMuted : up ? AppColors.success : AppColors.error)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8));

  Widget _quickAction(BuildContext context, String icon, String title, String sub, Color color, String route, {bool isLast = false}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic v) {
    final n = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}
