import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/admin_nav.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'type': 'BOOKING DISPUTE',
        'typeColor': AppColors.error,
        'title': 'Renter claims host cancelled last minute',
        'meta':
            'Reported by Ahmed Khan · Listing: 3-Bed House Model Town · Apr 18',
        'actions': ['✓ Resolve', '⚠ Escalate', 'View Chat'],
      },
      {
        'type': 'FRAUD ALERT',
        'typeColor': AppColors.warning,
        'title': 'Suspicious payment activity on booking #PKR-248',
        'meta': 'Auto-flagged by system · Usman Malik · Apr 19',
        'actions': ['✓ Clear', '⛔ Suspend User'],
      },
      {
        'type': 'LISTING REPORT',
        'typeColor': AppColors.error,
        'title': 'Misleading photos — property looks different',
        'meta':
            'Reported by Fatima Bibi · Listing: Bridal Lehenga Set · Apr 17',
        'actions': ['✓ Dismiss', '✗ Remove Listing'],
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(
                rightText: '5 open', rightColor: AppColors.error),
            const AdminTopNav(currentIndex: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI row
                    Row(
                      children: [
                        _kpi('Open', '5', AppColors.error),
                        const SizedBox(width: 6),
                        _kpi('Resolved', '28', AppColors.textPrimary),
                        const SizedBox(width: 6),
                        _kpi('Avg. Time', '2.4d', AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Open Disputes'),
                    const SizedBox(height: 8),
                    ...reports.map((r) => _reportCard(r)),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '2 more reports · Tap to load',
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AdminBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: label == 'Open'
                ? AppColors.error.withOpacity(0.2)
                : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 9, color: AppColors.textMuted)),
            Text(
              val,
              style: GoogleFonts.syne(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
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

  Widget _reportCard(Map<String, dynamic> r) {
    final typeColor = r['typeColor'] as Color;
    final actions = r['actions'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.error.withOpacity(0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              r['type'] as String,
              style: GoogleFonts.dmSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: typeColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r['title'] as String,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            r['meta'] as String,
            style: GoogleFonts.dmSans(
                fontSize: 9, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: actions.map((a) {
              Color color;
              if (a.contains('Resolve') || a.contains('Clear') ||
                  a.contains('Dismiss') || a.contains('Approve')) {
                color = AppColors.success;
              } else if (a.contains('Reject') || a.contains('Suspend') ||
                  a.contains('Remove') || a.contains('Escalate')) {
                color = AppColors.error;
              } else {
                color = AppColors.textSecondary;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: color.withOpacity(0.25), width: 0.5),
                  ),
                  child: Text(
                    a,
                    style: GoogleFonts.dmSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
