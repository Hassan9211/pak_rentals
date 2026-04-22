import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/admin_nav.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<Map<String, dynamic>> _open = [];
  List<Map<String, dynamic>> _resolved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.getReports();
      final data = res['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _open = (data['open'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _resolved = (data['resolved'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await AdminApi.updateReportStatus(id, status);
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
            AdminHeader(rightText: '${_open.length} open', rightColor: AppColors.error),
            const AdminTopNav(currentIndex: 3),
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
                            // Stats row
                            Row(
                              children: [
                                _stat('Open', '${_open.length}', AppColors.error),
                                const SizedBox(width: 6),
                                _stat('Resolved', '${_resolved.length}', AppColors.success),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_open.isNotEmpty) ...[
                              _sectionLabel('Open Reports'),
                              const SizedBox(height: 8),
                              ..._open.map((r) => _reportCard(r)),
                            ],
                            if (_resolved.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _sectionLabel('Resolved'),
                              const SizedBox(height: 8),
                              ..._resolved.take(5).map((r) => _reportCard(r, resolved: true)),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
            const AdminBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
            Text(val, style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8));

  Widget _reportCard(Map<String, dynamic> r, {bool resolved = false}) {
    final id = r['id'].toString();
    final type = (r['type'] as String? ?? 'other').replaceAll('_', ' ').toUpperCase();
    final subject = r['subject'] as String? ?? r['title'] as String? ?? 'Report';
    final desc = r['description'] as String? ?? '';
    final reporter = r['reporter'] as Map<String, dynamic>?;
    final reporterName = reporter?['name'] as String? ?? 'User';
    final status = r['status'] as String? ?? 'open';

    final typeColor = type.contains('FRAUD') ? AppColors.warning
        : type.contains('DISPUTE') ? AppColors.error
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolved ? AppColors.borderLight : AppColors.error.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(type, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, color: typeColor)),
          ),
          const SizedBox(height: 6),
          Text(subject, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(desc, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text('By: $reporterName · $status', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
          if (!resolved) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _actionBtn('✓ Resolve', AppColors.success, () => _updateStatus(id, 'resolved')),
                const SizedBox(width: 6),
                _actionBtn('Under Review', AppColors.warning, () => _updateStatus(id, 'under_review')),
                const SizedBox(width: 6),
                _actionBtn('Reject', AppColors.error, () => _updateStatus(id, 'rejected')),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
