import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/message.dart';
import '../../widgets/common/user_avatar.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                itemCount: SampleMessages.conversations.length,
                itemBuilder: (context, i) {
                  final c = SampleMessages.conversations[i];
                  return _buildConversationItem(context, c);
                },
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('3 unread', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, Conversation c) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chat'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.unreadCount > 0 ? AppColors.bgElevated : AppColors.bg,
          border: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            UserAvatar(initials: c.otherUserInitials, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.otherUserName,
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (c.relatedListingTitle != null)
                    Text('Re: ${c.relatedListingTitle}',
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan)),
                  const SizedBox(height: 2),
                  Text(c.lastMessage,
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(c.lastMessageAt),
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                if (c.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${c.unreadCount}',
                          style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} hr';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days';
  }
}
