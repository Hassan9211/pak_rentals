import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/user_state.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // ── Privacy toggles ──
  bool _profileVisible = true;
  bool _showPhone = false;
  bool _showEmail = false;
  bool _locationSharing = true;
  bool _activityStatus = true;

  // ── Security toggles ──
  bool _twoFactor = false;
  bool _loginAlerts = true;
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('PRIVACY'),
                    const SizedBox(height: 8),
                    _card([
                      _toggleRow(
                        icon: '👁️',
                        label: 'Public Profile',
                        sub: 'Others can see your profile',
                        value: _profileVisible,
                        onChanged: (v) => setState(() => _profileVisible = v),
                      ),
                      _toggleRow(
                        icon: '📱',
                        label: 'Show Phone Number',
                        sub: 'Visible to hosts & renters',
                        value: _showPhone,
                        onChanged: (v) => setState(() => _showPhone = v),
                      ),
                      _toggleRow(
                        icon: '📧',
                        label: 'Show Email Address',
                        sub: 'Visible on your profile',
                        value: _showEmail,
                        onChanged: (v) => setState(() => _showEmail = v),
                      ),
                      _toggleRow(
                        icon: '📍',
                        label: 'Location Sharing',
                        sub: 'Used for nearby listings',
                        value: _locationSharing,
                        onChanged: (v) => setState(() => _locationSharing = v),
                      ),
                      _toggleRow(
                        icon: '🟢',
                        label: 'Activity Status',
                        sub: 'Show when you\'re online',
                        value: _activityStatus,
                        onChanged: (v) => setState(() => _activityStatus = v),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionLabel('SECURITY'),
                    const SizedBox(height: 8),
                    _card([
                      _toggleRow(
                        icon: '🔐',
                        label: 'Two-Factor Authentication',
                        sub: 'Extra security via SMS',
                        value: _twoFactor,
                        onChanged: (v) {
                          setState(() => _twoFactor = v);
                          if (v) _show2FADialog();
                        },
                      ),
                      _toggleRow(
                        icon: '🔔',
                        label: 'Login Alerts',
                        sub: 'Notify on new sign-in',
                        value: _loginAlerts,
                        onChanged: (v) => setState(() => _loginAlerts = v),
                      ),
                      _toggleRow(
                        icon: '👆',
                        label: 'Biometric Login',
                        sub: 'Fingerprint / Face ID',
                        value: _biometric,
                        onChanged: (v) => setState(() => _biometric = v),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionLabel('ACCOUNT'),
                    const SizedBox(height: 8),
                    _card([
                      _actionRow(
                        icon: '🔑',
                        label: 'Change Password',
                        sub: 'Update your password',
                        onTap: () => _showChangePasswordDialog(),
                      ),
                      _actionRow(
                        icon: '📋',
                        label: 'Active Sessions',
                        sub: '1 device currently active',
                        onTap: () => _showSessionsDialog(),
                      ),
                      _actionRow(
                        icon: '📥',
                        label: 'Download My Data',
                        sub: 'Get a copy of your data',
                        onTap: () => _showSnack('Your data export will be emailed to you.'),
                      ),
                      _actionRow(
                        icon: '🗑️',
                        label: 'Delete Account',
                        sub: 'Permanently remove your account',
                        onTap: () => _showDeleteDialog(),
                        isDestructive: true,
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    // Last updated info
                    Center(
                      child: Text(
                        'Privacy Policy last updated: Jan 2025',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: () => _showSnack('Opening Privacy Policy...'),
                        child: Text(
                          'View Privacy Policy →',
                          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan),
                        ),
                      ),
                    ),
                  ],
                ),
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
          Text('Privacy & Security',
              style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: GoogleFonts.dmSans(
            fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8),
      );

  Widget _card(List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(children: rows),
      );

  Widget _toggleRow({
    required String icon,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(sub,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          // Animated toggle
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.cyan : AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value ? AppColors.cyan : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18, height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: value ? Colors.black : AppColors.textMuted,
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

  Widget _actionRow({
    required String icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isLast = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w500, color: color)),
                  Text(sub,
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16,
                color: isDestructive ? AppColors.error.withValues(alpha: 0.5) : const Color(0xFF2A2E3A)),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Enable 2FA',
            style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A verification code will be sent to:',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                UserState().phone.isNotEmpty ? UserState().phone : 'No phone number set',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _twoFactor = false);
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('2FA enabled via SMS ✓');
            },
            child: Text('Enable', style: GoogleFonts.dmSans(color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Change Password',
            style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(oldCtrl, 'Current password', obscure: true),
            const SizedBox(height: 10),
            _dialogField(newCtrl, 'New password', obscure: true),
            const SizedBox(height: 10),
            _dialogField(confirmCtrl, 'Confirm new password', obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (newCtrl.text.length < 8) {
                _showSnack('Password must be at least 8 characters');
                return;
              }
              if (newCtrl.text != confirmCtrl.text) {
                _showSnack('Passwords do not match');
                return;
              }
              Navigator.pop(context);
              _showSnack('Password changed successfully ✓');
            },
            child: Text('Update', style: GoogleFonts.dmSans(color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSessionsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Active Sessions',
            style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sessionTile('📱 This Device', 'Android · Bahawalpur', 'Active now', isCurrent: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _sessionTile(String device, String info, String time, {bool isCurrent = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? AppColors.success.withValues(alpha: 0.3) : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(device.split(' ').first, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.substring(device.indexOf(' ') + 1),
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(info, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(time,
                style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Delete Account?',
            style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
        content: Text(
          'This will permanently delete your account, listings, and all data. This action cannot be undone.',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              UserState().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            child: Text('Delete', style: GoogleFonts.dmSans(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        isDense: true,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }
}
