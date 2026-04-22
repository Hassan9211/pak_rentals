import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/admin_nav.dart';

class AdminListingsScreen extends StatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  State<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends State<AdminListingsScreen> {
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _moderated = [];
  int _tab = 0; // 0=Pending, 1=Approved/Rejected
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.getListings();
      final data = res['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _pending = (data['pending'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _moderated = (data['moderated'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await AdminApi.approveListing(id);
      _load();
    } catch (_) {}
  }

  Future<void> _reject(String id) async {
    try {
      await AdminApi.rejectListing(id);
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _pending : _moderated;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AdminHeader(rightText: '${_pending.length} pending', rightColor: AppColors.warning),
            const AdminTopNav(currentIndex: 2),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _tabBtn(0, '📋 Pending (${_pending.length})', AppColors.warning),
                              const SizedBox(width: 6),
                              _tabBtn(1, '✅ Reviewed', AppColors.success),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.purple,
                            backgroundColor: AppColors.bgCard,
                            onRefresh: _load,
                            child: list.isEmpty
                                ? Center(child: Text('No listings', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    itemCount: list.length,
                                    itemBuilder: (context, i) => _listingCard(list[i]),
                                  ),
                          ),
                        ),
                      ],
                    ),
            ),
            const AdminBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(int index, String label, Color color) {
    final isActive = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.08) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isActive ? color.withValues(alpha: 0.3) : AppColors.borderLight, width: 0.5),
          ),
          child: Center(child: Text(label,
              style: GoogleFonts.dmSans(fontSize: 10, color: isActive ? color : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal))),
        ),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> l) {
    final id = l['id'].toString();
    final title = l['title'] as String? ?? 'Listing';
    final host = l['host'] as Map<String, dynamic>?;
    final hostName = host?['name'] as String? ?? 'Host';
    final city = l['location_city'] as String? ?? '';
    final price = l['price_per_day']?.toString() ?? '0';
    final status = l['status'] as String? ?? 'pending';
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(7)),
                child: const Center(child: Text('🏠', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    Text('📍 $city · PKR $price/day · by $hostName',
                        style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPending ? AppColors.warning : status == 'approved' ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status.toUpperCase(),
                    style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700,
                        color: isPending ? AppColors.warning : status == 'approved' ? AppColors.success : AppColors.error)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionBtn('✓ Approve', AppColors.success, () => _approve(id)),
                const SizedBox(width: 6),
                _actionBtn('✗ Reject', AppColors.error, () => _reject(id)),
              ],
            ),
          ],
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
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
