import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

// ── APP LOGO ──
class AppLogo extends StatelessWidget {
  final double fontSize;
  const AppLogo({super.key, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Pak',
            style: GoogleFonts.syne(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: 'Rentals',
            style: GoogleFonts.syne(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.cyan,
            ),
          ),
        ],
      ),
    );
  }
}

// ── BOTTOM NAV BAR ──
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.isAdmin = false,
  });

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
          child: isAdmin ? _adminNav(context) : _userNav(context),
        ),
      ),
    );
  }

  Widget _userNav(BuildContext context) {
    final items = [
      _NavItem(icon: '🏠', label: 'Home', route: '/home'),
      _NavItem(icon: '🔍', label: 'Search', route: '/search'),
      _NavItem(icon: '+', label: '', route: null, isFab: true),
      _NavItem(icon: '❤️', label: 'Saved', route: '/saved'),
      _NavItem(icon: '👤', label: 'Profile', route: '/profile'),
    ];
    return _buildNav(context, items);
  }

  Widget _adminNav(BuildContext context) {
    final items = [
      _NavItem(icon: '🏠', label: 'Home', route: '/home'),
      _NavItem(icon: '👥', label: 'Admin', route: '/admin/analytics'),
      _NavItem(icon: '⚙', label: '', route: null, isFab: true, isAdmin: true),
      _NavItem(icon: '🚩', label: 'Reports', route: '/admin/reports'),
      _NavItem(icon: '👤', label: 'Profile', route: '/profile'),
    ];
    return _buildNav(context, items);
  }

  Widget _buildNav(BuildContext context, List<_NavItem> items) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isActive = i == currentIndex;
        final activeColor = isAdmin ? AppColors.purple : AppColors.cyan;

        if (item.isFab) {
          return Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  item.isAdmin ? '/admin/analytics' : '/create-listing',
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.isAdmin ? AppColors.purple : AppColors.cyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (item.isAdmin ? AppColors.purple : AppColors.cyan)
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      item.icon,
                      style: TextStyle(
                        fontSize: item.isAdmin ? 16 : 22,
                        color: item.isAdmin ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (item.route != null) {
                Navigator.pushNamed(context, item.route!);
              }
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
                    color: isActive ? activeColor : AppColors.textMuted,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  final String? route;
  final bool isFab;
  final bool isAdmin;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isFab = false,
    this.isAdmin = false,
  });
}

// ── BACK BUTTON ──
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── AVATAR ──
class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final List<Color> colors;
  final String? photoPath;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 32,
    this.colors = const [AppColors.cyan, AppColors.purple],
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath != null && photoPath!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3), width: 1),
        ),
        child: ClipOval(
          child: Image.file(
            dart_io.File(photoPath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials(),
          ),
        ),
      );
    }
    return _initials();
  }

  Widget _initials() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.dmSans(
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}


class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── SECTION HEADER ──
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.cyan,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── CARD CONTAINER ──
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor ?? AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

// ── PRIMARY BUTTON ──
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color ?? AppColors.cyan,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// ── OUTLINE BUTTON ──
class OutlineButton2 extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const OutlineButton2({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cyan.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.cyan,
            ),
          ),
        ),
      ),
    );
  }
}
