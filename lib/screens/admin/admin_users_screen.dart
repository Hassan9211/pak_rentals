import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/admin_nav.dart';
import '../../widgets/common_widgets.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentUsers = [
      {
        'initials': 'MZ',
        'colors': [AppColors.cyan, AppColors.purple],
        'name': 'Muhammad Zohaib',
        'sub': 'zohabanwr63@gmail.com · Host',
        'badges': [
          {'label': 'Active', 'color': AppColors.success},
          {'label': 'Unverified', 'color': AppColors.warning},
        ],
      },
      {
        'initials': 'AK',
        'colors': [AppColors.cyan, AppColors.success],
        'name': 'Ahmed Khan',
        'sub': 'ahmed.k@gmail.com · Host+Renter',
        'badges': [
          {'label': 'Active', 'color': AppColors.success},
          {'label': 'CNIC ✓', 'color': AppColors.success},
        ],
      },
      {
        'initials': 'FB',
        'colors': [AppColors.pink, AppColors.purple],
        'name': 'Fatima Bibi',
        'sub': 'f.bibi92@yahoo.com · Renter',
        'badges': [
          {'label': 'Active', 'color': AppColors.success},
          {'label': 'Unverified', 'color': AppColors.warning},
        ],
      },
      {
        'initials': 'TE',
        'colors': [AppColors.purple, AppColors.pink],
        'name': 'Test Admin',
        'sub': 'admin@pakrentals.pk',
        'badges': [
          {'label': 'Admin', 'color': AppColors.purple},
        ],
      },
    ];

    final pendingUsers = [
      {
        'initials': 'ZA',
        'colors': [AppColors.warning, AppColors.pink],
        'name': 'Zara Abbasi',
        'sub': 'CNIC uploaded · Awaiting review',
      },
      {
        'initials': 'UM',
        'colors': [const Color(0xFF378ADD), AppColors.cyan],
        'name': 'Usman Malik',
        'sub': 'CNIC uploaded · Awaiting review',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(
                rightText: '1,840 users', rightColor: AppColors.cyan),
            const AdminTopNav(currentIndex: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.borderLight, width: 0.5),
                            ),
                            child: Text('🔍 Search users...',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: AppColors.textMuted)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.purple.withOpacity(0.3),
                                width: 0.5),
                          ),
                          child: Text('Filter',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10, color: AppColors.purple)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Recent Users'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        children: recentUsers.asMap().entries.map((entry) {
                          final i = entry.key;
                          final u = entry.value;
                          final isLast = i == recentUsers.length - 1;
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderLight,
                                          width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                UserAvatar(
                                  initials: u['initials'] as String,
                                  size: 32,
                                  colors: (u['colors'] as List)
                                      .cast<Color>(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(u['name'] as String,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          )),
                                      Text(u['sub'] as String,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 9,
                                              color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: (u['badges']
                                          as List<Map<String, dynamic>>)
                                      .map((b) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 3),
                                            child: StatusBadge(
                                              label: b['label'] as String,
                                              color: b['color'] as Color,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _sectionLabel('Unverified Users'),
                        const SizedBox(width: 6),
                        Text('(3 pending CNIC)',
                            style: GoogleFonts.dmSans(
                                fontSize: 9, color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        children: pendingUsers.asMap().entries.map((entry) {
                          final i = entry.key;
                          final u = entry.value;
                          final isLast = i == pendingUsers.length - 1;
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderLight,
                                          width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                UserAvatar(
                                  initials: u['initials'] as String,
                                  size: 32,
                                  colors: (u['colors'] as List)
                                      .cast<Color>(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(u['name'] as String,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          )),
                                      Text(u['sub'] as String,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 9,
                                              color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _actionBtn('Verify', AppColors.success),
                                    const SizedBox(width: 5),
                                    _actionBtn('Reject', AppColors.error),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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

  Widget _actionBtn(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
            fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
