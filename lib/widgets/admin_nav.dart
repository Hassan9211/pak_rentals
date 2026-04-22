import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class AdminTopNav extends StatelessWidget {
  final int currentIndex;

  const AdminTopNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': '📊', 'label': 'Analytics', 'route': '/admin/analytics'},
      {'icon': '👥', 'label': 'Users', 'route': '/admin/users'},
      {'icon': '🏠', 'label': 'Listings', 'route': '/admin/listings'},
      {'icon': '🚩', 'label': 'Reports', 'route': '/admin/reports'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final tab = entry.value;
          final isActive = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isActive) {
                  Navigator.pushReplacementNamed(
                      context, tab['route']!);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.purple.withOpacity(0.06)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppColors.purple
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  '${tab['icon']} ${tab['label']}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: isActive
                        ? AppColors.purple
                        : AppColors.textMuted,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  final String rightText;
  final Color rightColor;

  const AdminHeader({
    super.key,
    required this.rightText,
    this.rightColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(
          bottom: BorderSide(
              color: AppColors.purple.withOpacity(0.2), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Pak',
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'Rentals',
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.purple.withOpacity(0.4), width: 0.5),
            ),
            child: Text(
              'ADMIN',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.purple,
              ),
            ),
          ),
          const Spacer(),
          Text(
            rightText,
            style: GoogleFonts.dmSans(
                fontSize: 10, color: rightColor),
          ),
        ],
      ),
    );
  }
}

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              _navItem(context, '🏠', 'Home', 0, '/home'),
              _navItem(context, '👥', 'Admin', 1, '/admin/analytics'),
              _fabItem(context),
              _navItem(context, '🚩', 'Reports', 3, '/admin/reports'),
              _navItem(context, '👤', 'Profile', 4, '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String icon, String label,
      int index, String route) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: isActive ? AppColors.purple : AppColors.textMuted,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fabItem(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.purple,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('⚙', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
