import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Change Profile Photo',
                  style: GoogleFonts.syne(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _sheetBtn(Icons.camera_alt_rounded, 'Take Photo', 'Use camera', () {
                Navigator.pop(context);
                _doPickPhoto(ImageSource.camera);
              }),
              const SizedBox(height: 10),
              _sheetBtn(Icons.photo_library_rounded, 'Choose from Gallery', 'Pick existing photo', () {
                Navigator.pop(context);
                _doPickPhoto(ImageSource.gallery);
              }),
              if (UserState().profilePhotoPath.isNotEmpty) ...[
                const SizedBox(height: 10),
                _sheetBtn(Icons.delete_outline, 'Remove Photo', 'Use initials instead', () {
                  Navigator.pop(context);
                  UserState().updateProfilePhoto('');
                }, color: AppColors.error),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doPickPhoto(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;
    final status = await permission.request();

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Permission Required',
              style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          content: Text('Please enable access in app settings.',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textSecondary))),
            TextButton(onPressed: () { Navigator.pop(context); openAppSettings(); },
                child: Text('Settings', style: GoogleFonts.dmSans(color: AppColors.cyan, fontWeight: FontWeight.w600))),
          ],
        ),
      );
      return;
    }
    if (status.isDenied) return;

    try {
      final img = await _picker.pickImage(
          source: source, imageQuality: 85, maxWidth: 600);
      if (img != null && mounted) {
        await UserState().updateProfilePhoto(img.path);
      }
    } catch (_) {}
  }

  Widget _sheetBtn(IconData icon, String label, String sub, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? AppColors.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: c, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(sub, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserState(),
      builder: (context, _) {
        final user = UserState();
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTop(user),
                        _buildBody(context, user),
                      ],
                    ),
                  ),
                ),
                AppBottomNav(currentIndex: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTop(UserState user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgElevated, AppColors.bgCard],
        ),
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Column(
        children: [
          // ── Tappable avatar with camera icon ──
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              children: [
                // Photo or initials
                user.profilePhotoPath.isNotEmpty
                    ? Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4), width: 2),
                        ),
                        child: ClipOval(
                          child: Image.file(
                            File(user.profilePhotoPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                UserAvatar(initials: user.initials, size: 72),
                          ),
                        ),
                      )
                    : UserAvatar(initials: user.initials, size: 72),
                // Camera badge
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgCard, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 12, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(user.name,
              style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          if (user.email.isNotEmpty)
            Text(user.email, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          if (user.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(user.phone, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _badge(user.roleLabel, AppColors.purple),
              _badge(
                user.cnicVerified ? '✓ CNIC Verified' : '⚠ CNIC Pending',
                user.cnicVerified ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Member since ${user.joinDateLabel}',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBody(BuildContext context, UserState user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card([
            _row(context, icon: '📋', label: 'My Bookings', value: user.bookingsLabel, route: '/dashboard'),
            _row(context, icon: '❤️', label: 'Wishlist', value: user.savedLabel, route: '/saved'),
            _row(context, icon: '💬', label: 'Messages', value: user.messagesLabel,
                valueColor: user.unreadMessages > 0 ? AppColors.cyan : null, route: '/inbox'),
            _row(context, icon: '⭐', label: 'Reviews', value: user.reviewsLabel, isLast: true),
          ]),
          const SizedBox(height: 12),
          _card([
            _row(context, icon: '👤', label: 'Edit Profile', value: user.firstName, route: '/edit-profile'),
            _row(context, icon: '🪪', label: 'CNIC Verification',
                value: user.cnicVerified ? 'Verified' : 'Pending',
                valueColor: user.cnicVerified ? AppColors.success : AppColors.warning,
                route: '/cnic-verification'),
            _row(context, icon: '💳', label: 'Payment Methods', value: user.paymentLabel,
                valueColor: user.paymentMethod.isEmpty ? AppColors.warning : null,
                route: '/payment-methods'),
            _row(context, icon: '🌐', label: 'Language', value: user.language,
                route: '/language', isLast: true),
          ]),
          const SizedBox(height: 12),
          _card([
            _notifRow(user),
            _row(context, icon: '🔒', label: 'Privacy & Security', value: '', isLast: true,
                route: '/privacy-security'),
          ]),
          const SizedBox(height: 12),
          // ── Admin Panel — only visible to admin role ──
          if (user.isAdmin) ...[
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/admin/analytics'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: AppColors.purple, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Panel',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.purple)),
                          Text('Manage users, listings & reports',
                              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.purple, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('🚪', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text('Sign Out',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(user.name, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(children: rows),
      );

  Widget _row(BuildContext context, {
    required String icon,
    required String label,
    required String value,
    Color? valueColor,
    String? route,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap ?? (route != null ? () => Navigator.pushNamed(context, route) : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary))),
            if (value.isNotEmpty)
              Text(value, style: GoogleFonts.dmSans(fontSize: 12, color: valueColor ?? AppColors.textMuted)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF2A2E3A)),
          ],
        ),
      ),
    );
  }

  Widget _notifRow(UserState user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 10),
          Expanded(child: Text('Notifications', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary))),
          GestureDetector(
            onTap: () => UserState().toggleNotifications(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 24,
              decoration: BoxDecoration(
                color: user.notificationsEnabled ? AppColors.cyan : AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: user.notificationsEnabled ? AppColors.cyan : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: user.notificationsEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18, height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: user.notificationsEnabled ? Colors.black : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCnicDialog(BuildContext context, UserState user) {
    if (user.cnicVerified) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('CNIC already verified ✓', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('CNIC Verification',
            style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text('Upload your CNIC to get verified. Verified users get more bookings and trust from hosts.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Later', style: GoogleFonts.dmSans(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () { UserState().setCnicVerified(true); Navigator.pop(context); },
            child: Text('Mark Verified', style: GoogleFonts.dmSans(color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Sign Out?',
            style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text('You will be returned to the splash screen.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              UserState().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            child: Text('Sign Out', style: GoogleFonts.dmSans(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
