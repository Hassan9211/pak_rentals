import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../widgets/common/user_avatar.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Map<String, dynamic>> _conversations = [];
  int _unreadTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await MessagesApi.getConversations();
      final list = (res['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final unread = list.fold<int>(0, (sum, c) => sum + ((c['unread_count'] as int?) ?? 0));
      if (mounted) {
        setState(() {
          _conversations = list;
          _unreadTotal = unread;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _contactName(Map<String, dynamic> c) =>
      c['contact']?['name'] as String? ?? 'User';

  String _contactInitials(Map<String, dynamic> c) {
    final name = _contactName(c);
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _conversations.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.cyan,
                          backgroundColor: AppColors.bgCard,
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, i) => _buildItem(context, _conversations[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Text('Inbox', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          if (_unreadTotal > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$_unreadTotal unread',
                  style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> c) {
    final unread = (c['unread_count'] as int?) ?? 0;
    final lastMsg = c['last_message'] as String? ?? '';
    final listingTitle = c['listing']?['title'] as String?;
    final timeStr = _formatTime(c['last_message_at'] as String?);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chat'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: unread > 0 ? AppColors.bgElevated : AppColors.bg,
          border: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            UserAvatar(initials: _contactInitials(c), size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_contactName(c),
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary)),
                  if (listingTitle != null)
                    Text('Re: $listingTitle', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan)),
                  const SizedBox(height: 2),
                  Text(lastMsg,
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                if (unread > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                    child: Center(child: Text('$unread',
                        style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black))),
                  ),
                ],
              ],
            ),
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
          const Text('💬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No messages yet', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Message a host from any listing', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays}d';
    } catch (_) {
      return '';
    }
  }
}
