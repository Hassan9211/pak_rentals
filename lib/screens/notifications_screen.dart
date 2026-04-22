import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await NotificationsApi.getAll();
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final List<Map<String, dynamic>> all = [];

      // Booking requests (for hosts)
      for (final b in (data['booking_requests'] as List? ?? [])) {
        final m = b as Map<String, dynamic>;
        all.add({
          'icon': '📋',
          'iconBg': AppColors.warning,
          'title': 'Booking Request',
          'body': '${m['renter']?['name'] ?? 'Someone'} wants to book "${m['listing']?['title'] ?? 'your listing'}"',
          'time': _formatTime(m['created_at'] as String?),
          'unread': m['status'] == 'pending',
          'route': '/dashboard',
        });
      }

      // Payment alerts (for renters)
      for (final b in (data['payment_alerts'] as List? ?? [])) {
        final m = b as Map<String, dynamic>;
        all.add({
          'icon': '💳',
          'iconBg': AppColors.cyan,
          'title': 'Payment Required',
          'body': 'Your booking for "${m['listing']?['title'] ?? 'listing'}" is approved. Pay now.',
          'time': _formatTime(m['created_at'] as String?),
          'unread': true,
          'route': '/booking',
        });
      }

      // Unread messages
      for (final msg in (data['unread_messages'] as List? ?? [])) {
        final m = msg as Map<String, dynamic>;
        all.add({
          'icon': '💬',
          'iconBg': AppColors.purple,
          'title': 'New Message',
          'body': '${m['sender']?['name'] ?? 'Someone'}: ${m['message'] ?? ''}',
          'time': _formatTime(m['created_at'] as String?),
          'unread': true,
          'route': '/chat',
        });
      }

      // Open reports
      for (final r in (data['open_reports'] as List? ?? [])) {
        final m = r as Map<String, dynamic>;
        all.add({
          'icon': '🚩',
          'iconBg': AppColors.error,
          'title': 'Report Update',
          'body': 'Your report "${m['subject'] ?? ''}" is ${m['status'] ?? 'open'}.',
          'time': _formatTime(m['created_at'] as String?),
          'unread': m['status'] == 'open',
          'route': '/profile',
        });
      }

      if (mounted) setState(() { _items = all; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => n['unread'] == true).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, unreadCount),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _items.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.cyan,
                          backgroundColor: AppColors.bgCard,
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, i) => _buildItem(context, _items[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text('Notifications', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => setState(() {
                for (final n in _items) n['unread'] = false;
              }),
              child: Text('Mark all read', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.cyan)),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> n) {
    final unread = n['unread'] as bool? ?? false;
    final iconBg = n['iconBg'] as Color? ?? AppColors.bgInput;
    final route = n['route'] as String?;

    return GestureDetector(
      onTap: () {
        setState(() => n['unread'] = false);
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: unread ? AppColors.bgElevated : AppColors.bg,
          border: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: iconBg.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Center(child: Text(n['icon'] as String? ?? '🔔', style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(n['title'] as String? ?? '',
                            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ),
                      Text(n['time'] as String? ?? '',
                          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n['body'] as String? ?? '',
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No notifications', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('You\'re all caught up!', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) { return ''; }
  }
}
