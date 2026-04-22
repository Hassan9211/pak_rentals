import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/admin_nav.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kpis = [
      {
        'label': 'Platform Revenue',
        'val': '56K',
        'trend': '↑ 18% vs Mar',
        'up': true,
        'color': AppColors.purple,
      },
      {
        'label': 'Total Bookings',
        'val': '248',
        'trend': '↑ 31 new',
        'up': true,
        'color': AppColors.cyan,
      },
      {
        'label': 'Active Users',
        'val': '1,840',
        'trend': '↑ 340 new',
        'up': true,
        'color': AppColors.textPrimary,
      },
      {
        'label': 'Pending Review',
        'val': '12',
        'trend': 'Needs action',
        'up': null,
        'color': AppColors.warning,
      },
    ];

    final months = ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'];
    final heights = [18.0, 26.0, 20.0, 32.0, 28.0, 44.0];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(rightText: 'Apr 2026'),
            const AdminTopNav(currentIndex: 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 2.0,
                      children: kpis
                          .map((k) => Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 0.5),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(k['label'] as String,
                                        style: GoogleFonts.dmSans(
                                            fontSize: 9,
                                            color: AppColors.textMuted)),
                                    Text(
                                      k['val'] as String,
                                      style: GoogleFonts.syne(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: k['color'] as Color,
                                      ),
                                    ),
                                    Text(
                                      k['trend'] as String,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 8,
                                        color: k['up'] == null
                                            ? AppColors.textMuted
                                            : (k['up'] as bool)
                                                ? AppColors.success
                                                : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Monthly Revenue (PKR 000s)'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(6, (i) {
                            final isLast = i == 5;
                            final isFeb = i == 3;
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
                                            ? AppColors.purple
                                                .withOpacity(0.5)
                                            : isFeb
                                                ? AppColors.cyan
                                                    .withOpacity(0.3)
                                                : AppColors.purple
                                                    .withOpacity(0.3),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(2),
                                        ),
                                        border: Border(
                                          top: BorderSide(
                                            color: isLast
                                                ? AppColors.purple
                                                : isFeb
                                                    ? AppColors.cyan
                                                    : AppColors.purple,
                                            width: 1.5,
                                          ),
                                        ),
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
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Quick Actions'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          _quickAction(
                            context,
                            '📋',
                            const Color(0xFF1A1408),
                            'Pending Listings',
                            '12 awaiting approval',
                            '12',
                            AppColors.warning,
                            '/admin/listings',
                          ),
                          _quickAction(
                            context,
                            '🚩',
                            const Color(0xFF1A0808),
                            'Open Reports',
                            '5 disputes need review',
                            '5',
                            AppColors.error,
                            '/admin/reports',
                          ),
                          _quickAction(
                            context,
                            '💳',
                            const Color(0xFF0D1520),
                            'Pending Payouts',
                            'PKR 124,500 to process',
                            '3',
                            AppColors.cyan,
                            null,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AdminBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    String emoji,
    Color bgColor,
    String title,
    String sub,
    String badge,
    Color badgeColor,
    String? route, {
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                      color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      )),
                  Text(sub,
                      style: GoogleFonts.dmSans(
                          fontSize: 9, color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: badgeColor.withOpacity(0.25), width: 0.5),
              ),
              child: Text(
                badge,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
