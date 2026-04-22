import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/admin_nav.dart';

class AdminListingsScreen extends StatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  State<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends State<AdminListingsScreen> {
  int _tab = 0; // 0=Pending, 1=Approved, 2=Rejected

  final List<Map<String, dynamic>> _pending = [
    {
      'emoji': '🏠',
      'bg': const Color(0xFF0D1F1A),
      'title': '3-Bed House – Satellite Town',
      'sub': '📍 Bahawalpur · PKR 22,000/mo · by Zara Abbasi',
    },
    {
      'emoji': '🚗',
      'bg': const Color(0xFF0D1520),
      'title': 'Toyota Corolla 2022 – Daily',
      'sub': '📍 Lahore · PKR 8,000/day · by Usman Malik',
    },
    {
      'emoji': '👗',
      'bg': const Color(0xFF1A0D14),
      'title': 'Bridal Sherwani – Premium Set',
      'sub': '📍 Karachi · PKR 20,000/event · by Fatima Bibi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(
                rightText: '12 pending', rightColor: AppColors.warning),
            const AdminTopNav(currentIndex: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab row
                    Row(
                      children: [
                        _tabBtn(0, '📋 Pending (12)', AppColors.warning),
                        const SizedBox(width: 5),
                        _tabBtn(1, '✅ Approved', AppColors.success),
                        const SizedBox(width: 5),
                        _tabBtn(2, '❌ Rejected', AppColors.error),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Pending Approval'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        children: _pending.asMap().entries.map((entry) {
                          final i = entry.key;
                          final l = entry.value;
                          final isLast = i == _pending.length - 1;
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: l['bg'] as Color,
                                        borderRadius:
                                            BorderRadius.circular(7),
                                      ),
                                      child: Center(
                                        child: Text(l['emoji'] as String,
                                            style: const TextStyle(
                                                fontSize: 20)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(l['title'] as String,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              )),
                                          Text(l['sub'] as String,
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 9,
                                                  color:
                                                      AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    _badge('PENDING', AppColors.warning),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _actionBtn('✓ Approve', AppColors.success),
                                    const SizedBox(width: 6),
                                    _actionBtn('✗ Reject', AppColors.error),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Recently Approved'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.borderLight, width: 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D1F1A),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Center(
                                  child: Text('🏠',
                                      style: TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Stunning 3 bedrooms',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      )),
                                  Text('📍 Bahawalpur · PKR 5,000/day',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 9,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            _badge('Approved', AppColors.success),
                          ],
                        ),
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

  Widget _tabBtn(int index, String label, Color color) {
    final isActive = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.08) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? color.withOpacity(0.3) : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: isActive ? color : AppColors.textMuted,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
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

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
            fontSize: 8, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _actionBtn(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
