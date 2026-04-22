import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {
      'icon': '✅',
      'iconBg': AppColors.success,
      'title': 'Booking Confirmed',
      'body': 'Your booking for 3-Bed House – Model Town has been confirmed.',
      'time': '2 min ago',
      'unread': true,
    },
    {
      'icon': '💳',
      'iconBg': AppColors.cyan,
      'title': 'Payment Received',
      'body': 'PKR 8,740 received via JazzCash for booking #PKR-2026-00847.',
      'time': '10 min ago',
      'unread': true,
    },
    {
      'icon': '💬',
      'iconBg': AppColors.purple,
      'title': 'New Message',
      'body': 'Ahmed Khan: Yes, parking is available for 2 cars...',
      'time': '1 hr ago',
      'unread': true,
    },
    {
      'icon': '⭐',
      'iconBg': AppColors.warning,
      'title': 'New Review',
      'body': 'Usman Malik left a 5-star review on your listing.',
      'time': '3 hrs ago',
      'unread': false,
    },
    {
      'icon': '🏠',
      'iconBg': AppColors.bgInput,
      'title': 'Listing Approved',
      'body': 'Your listing "Bridal Lehenga Full Set" has been approved.',
      'time': 'Yesterday',
      'unread': false,
    },
    {
      'icon': '🚩',
      'iconBg': AppColors.error,
      'title': 'Report Update',
      'body': 'Your report #rep1 has been reviewed by admin.',
      'time': '2 days ago',
      'unread': false,
    },
  ];

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
                itemCount: _notifications.length,
                itemBuilder: (context, i) => _buildItem(_notifications[i]),
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
          Text('Notifications', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Text('Mark all read', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.cyan)),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> n) {
    final unread = n['unread'] as bool;
    return Container(
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
              color: (n['iconBg'] as Color).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: (n['iconBg'] as Color).withValues(alpha: 0.3), width: 0.5),
            ),
            child: Center(child: Text(n['icon'] as String, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(n['title'] as String,
                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(n['time'] as String,
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(n['body'] as String,
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}
