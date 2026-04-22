import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/admin_nav.dart';
import '../../widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
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
      final res = await AdminApi.getUsers();
      final list = res['data'] as List? ?? [];
      final meta = res['meta'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _users = list.cast<Map<String, dynamic>>();
          _total = meta['total'] as int? ?? _users.length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleVerify(String userId) async {
    try {
      await AdminApi.toggleVerify(userId);
      _load();
    } catch (_) {}
  }

  Future<void> _toggleSuspend(String userId) async {
    try {
      await AdminApi.toggleSuspend(userId);
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
            AdminHeader(rightText: '$_total users', rightColor: AppColors.cyan),
            const AdminTopNav(currentIndex: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2))
                  : RefreshIndicator(
                      color: AppColors.purple,
                      backgroundColor: AppColors.bgCard,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _users.length,
                        itemBuilder: (context, i) => _userCard(_users[i]),
                      ),
                    ),
            ),
            const AdminBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final name = u['name'] as String? ?? 'User';
    final email = u['email'] as String? ?? '';
    final verified = u['verified_at'] != null;
    final roles = (u['roles'] as List?)?.map((r) => r['name'] as String? ?? '').toList() ?? ['user'];
    final role = roles.isNotEmpty ? roles.first : 'user';
    final initials = name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    final id = u['id'].toString();

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
          UserAvatar(initials: initials, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(email, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                Text(role, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.purple)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: verified ? 'Verified' : 'Unverified',
                color: verified ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _actionBtn(verified ? 'Unverify' : 'Verify',
                      verified ? AppColors.warning : AppColors.success,
                      () => _toggleVerify(id)),
                  const SizedBox(width: 4),
                  _actionBtn('Suspend', AppColors.error, () => _toggleSuspend(id)),
                ],
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
