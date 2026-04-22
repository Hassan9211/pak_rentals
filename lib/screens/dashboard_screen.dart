import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHero(),
                    _buildSection(context),
                  ],
                ),
              ),
            ),
            AppBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = UserState();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppLogo(),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
                ),
                child: const Center(
                    child: Text('🔔', style: TextStyle(fontSize: 15))),
              ),
              const SizedBox(width: 8),
              UserAvatar(initials: user.initials),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final user = UserState();
    final stats = [
      {'label': 'Total Earnings', 'val': '78.5K', 'sub': '+12% this month'},
      {'label': 'Active Listings', 'val': '4', 'sub': '1 pending review'},
      {'label': 'Bookings', 'val': '23', 'sub': '3 upcoming'},
      {'label': 'Reviews', 'val': '4.8 ⭐', 'sub': '18 total'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgElevated, AppColors.bgCard],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,',
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.textMuted)),
          Text(
            user.name,
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: stats
                .map((s) => Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['label']!,
                              style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  color: AppColors.textMuted)),
                          Text(
                            s['val']!,
                            style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(s['sub']!,
                              style: GoogleFonts.dmSans(
                                  fontSize: 8,
                                  color: AppColors.cyan)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    final listings = [
      {
        'emoji': '🏠',
        'bg': const Color(0xFF0D1F1A),
        'title': '3-Bed House – Model Town',
        'price': 'PKR 25,000/month',
        'status': 'Active',
        'statusColor': AppColors.success,
      },
      {
        'emoji': '🏍️',
        'bg': const Color(0xFF0D1520),
        'title': 'Honda CD-70 Daily Rent',
        'price': 'PKR 800/day',
        'status': 'Booked',
        'statusColor': AppColors.cyan,
      },
      {
        'emoji': '👗',
        'bg': const Color(0xFF1A0D14),
        'title': 'Bridal Lehenga Full Set',
        'price': 'PKR 15,000/event',
        'status': 'Active',
        'statusColor': AppColors.success,
      },
      {
        'emoji': '🏢',
        'bg': const Color(0xFF141826),
        'title': '1-Bed Room – Near Uni',
        'price': 'PKR 8,000/month',
        'status': 'Pending',
        'statusColor': AppColors.warning,
      },
    ];

    final months = ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'];
    final heights = [30.0, 38.0, 25.0, 44.0, 35.0, 50.0];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'My Listings', action: 'Manage all'),
          const SizedBox(height: 10),
          ...listings.map((l) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.borderLight, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: l['bg'] as Color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(l['emoji'] as String,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l['title'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              )),
                          Text(l['price'] as String,
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: l['status'] as String,
                      color: l['statusColor'] as Color,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          // Earnings chart
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly earnings (PKR 000s)',
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(6, (i) {
                      final isLast = i == 5;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Container(
                                height: heights[i],
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isLast
                                      ? AppColors.cyan
                                      : AppColors.cyan.withOpacity(0.25),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(2),
                                  ),
                                  border: isLast
                                      ? null
                                      : const Border(
                                          top: BorderSide(
                                              color: AppColors.cyan,
                                              width: 1.5)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(months[i],
                                style: GoogleFonts.dmSans(
                                    fontSize: 8,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
