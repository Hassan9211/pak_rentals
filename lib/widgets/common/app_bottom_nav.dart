import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: '🏠', label: 'Home', route: '/home'),
      _NavItem(icon: '🔍', label: 'Search', route: '/browse'),
      _NavItem(icon: '+', label: '', route: null, isFab: true),
      _NavItem(icon: '❤️', label: 'Saved', route: '/saved'),
      _NavItem(icon: '👤', label: 'Profile', route: '/profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isActive = i == currentIndex;

              if (item.isFab) {
                return Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/create-listing'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.cyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('+', style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (item.route != null) Navigator.pushNamed(context, item.route!);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: isActive ? AppColors.cyan : AppColors.textMuted,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isActive)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4, height: 4,
                          decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  final String? route;
  final bool isFab;
  _NavItem({required this.icon, required this.label, required this.route, this.isFab = false});
}
