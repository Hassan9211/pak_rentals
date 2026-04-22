import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../services/user_state.dart';

class CnicVerificationScreen extends StatefulWidget {
  const CnicVerificationScreen({super.key});

  @override
  State<CnicVerificationScreen> createState() => _CnicVerificationScreenState();
}

class _CnicVerificationScreenState extends State<CnicVerificationScreen> {
  final _picker = ImagePicker();

  XFile? _frontPhoto;
  XFile? _backPhoto;

  // Expiry date fields
  int _expiryDay = 1;
  int _expiryMonth = 1;
  int _expiryYear = DateTime.now().year;

  bool _isVerifying = false;
  String? _frontError;
  String? _backError;
  String? _expiryError;

  // ── Steps: 0=upload, 1=result ──
  int _step = 0;

  Future<void> _pickPhoto(bool isFront) async {
    final status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showPermissionDialog();
      return;
    }
    if (status.isDenied) return;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              Text(isFront ? 'Upload CNIC Front' : 'Upload CNIC Back',
                  style: GoogleFonts.syne(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _sheetBtn(Icons.camera_alt_rounded, 'Take Photo', () {
                Navigator.pop(context);
                _doPickPhoto(isFront, ImageSource.camera);
              }),
              const SizedBox(height: 10),
              _sheetBtn(Icons.photo_library_rounded, 'Choose from Gallery', () {
                Navigator.pop(context);
                _doPickPhoto(isFront, ImageSource.gallery);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doPickPhoto(bool isFront, ImageSource source) async {
    try {
      final img = await _picker.pickImage(
          source: source, imageQuality: 90, maxWidth: 1200);
      if (img != null && mounted) {
        setState(() {
          if (isFront) {
            _frontPhoto = img;
            _frontError = null;
          } else {
            _backPhoto = img;
            _backError = null;
          }
        });
      }
    } catch (_) {
      _showSnack('Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}');
    }
  }

  bool _isExpired() {
    final expiry = DateTime(_expiryYear, _expiryMonth, _expiryDay);
    return expiry.isBefore(DateTime.now());
  }

  Future<void> _submit() async {
    // Validate
    bool valid = true;
    setState(() {
      _frontError = _frontPhoto == null ? 'Please upload CNIC front side' : null;
      _backError = _backPhoto == null ? 'Please upload CNIC back side' : null;
      _expiryError = null;
    });
    if (_frontPhoto == null || _backPhoto == null) return;

    // Check expiry
    if (_isExpired()) {
      setState(() => _expiryError = 'Your CNIC is expired. Please renew it first.');
      valid = false;
    }

    if (!valid) return;

    // Simulate verification process
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isVerifying = false;
      _step = 1;
    });

    // Save to UserState
    await UserState().setCnicVerified(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _step == 0 ? _buildUploadStep() : _buildResultStep(),
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
                  border: Border.all(color: AppColors.borderLight)),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text('CNIC Verification',
              style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: UserState().cnicVerified
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              UserState().cnicVerified ? '✓ Verified' : '⚠ Pending',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: UserState().cnicVerified ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🪪', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Why verify your CNIC?',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        '• Get a verified badge on your profile\n'
                        '• Build trust with hosts and renters\n'
                        '• Required for hosting listings',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.textMuted, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Front side ──
          _sectionTitle('CNIC Front Side'),
          const SizedBox(height: 4),
          Text('Upload the front of your CNIC (with your photo)',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _photoUploadBox(
            isFront: true,
            photo: _frontPhoto,
            error: _frontError,
            placeholder: '🪪',
            label: 'Front Side',
          ),
          const SizedBox(height: 20),

          // ── Back side ──
          _sectionTitle('CNIC Back Side'),
          const SizedBox(height: 4),
          Text('Upload the back of your CNIC (with expiry date)',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _photoUploadBox(
            isFront: false,
            photo: _backPhoto,
            error: _backError,
            placeholder: '🪪',
            label: 'Back Side',
          ),
          const SizedBox(height: 24),

          // ── Expiry date ──
          _sectionTitle('CNIC Expiry Date'),
          const SizedBox(height: 4),
          Text('Enter the expiry date shown on your CNIC',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          _buildExpiryPicker(),
          if (_expiryError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_expiryError!,
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ── Submit button ──
          _isVerifying
              ? Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(AppColors.cyan)),
                      ),
                      const SizedBox(width: 12),
                      Text('Verifying your CNIC...',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: AppColors.cyan, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.cyan, Color(0xFF00B8D9)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('Submit for Verification',
                          style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                    ),
                  ),
                ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              '🔒 Your data is encrypted and secure',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoUploadBox({
    required bool isFront,
    required XFile? photo,
    required String? error,
    required String placeholder,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => _pickPhoto(isFront),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: error != null
              ? AppColors.error.withValues(alpha: 0.05)
              : photo != null
                  ? AppColors.success.withValues(alpha: 0.05)
                  : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error != null
                ? AppColors.error
                : photo != null
                    ? AppColors.success
                    : AppColors.cyan.withValues(alpha: 0.3),
            width: error != null || photo != null ? 1 : 0.5,
          ),
        ),
        child: photo != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(File(photo.path), fit: BoxFit.cover),
                  ),
                  // Success overlay
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 12, color: Colors.black),
                          const SizedBox(width: 4),
                          Text('Uploaded',
                              style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  // Retake button
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Retake',
                              style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: error != null
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      color: error != null ? AppColors.error : AppColors.cyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload $label',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: error != null ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error ?? 'Camera or Gallery',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: error != null ? AppColors.error : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildExpiryPicker() {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final currentYear = DateTime.now().year;
    final years = List.generate(30, (i) => currentYear - 5 + i);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _expiryError != null ? AppColors.error : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Day
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    _dropdownBox(
                      value: _expiryDay,
                      items: List.generate(31, (i) => i + 1),
                      label: (v) => v.toString().padLeft(2, '0'),
                      onChanged: (v) => setState(() { _expiryDay = v; _expiryError = null; }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Month
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Month', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    _dropdownBox(
                      value: _expiryMonth,
                      items: List.generate(12, (i) => i + 1),
                      label: (v) => months[v - 1],
                      onChanged: (v) => setState(() { _expiryMonth = v; _expiryError = null; }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Year
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Year', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    _dropdownBox(
                      value: _expiryYear,
                      items: years,
                      label: (v) => v.toString(),
                      onChanged: (v) => setState(() { _expiryYear = v; _expiryError = null; }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Live expiry status
          Builder(builder: (_) {
            final expiry = DateTime(_expiryYear, _expiryMonth, _expiryDay);
            final expired = expiry.isBefore(DateTime.now());
            final daysLeft = expiry.difference(DateTime.now()).inDays;
            return Row(
              children: [
                Icon(
                  expired ? Icons.cancel_outlined : Icons.check_circle_outline,
                  size: 14,
                  color: expired ? AppColors.error : AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  expired
                      ? 'CNIC expired — cannot verify'
                      : daysLeft < 90
                          ? 'Expires soon ($daysLeft days left)'
                          : 'Valid CNIC ✓',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: expired
                        ? AppColors.error
                        : daysLeft < 90
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _dropdownBox<T>({
    required T value,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.bgCard,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
          items: items
              .map((v) => DropdownMenuItem<T>(value: v, child: Text(label(v))))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  // ── Result step ──
  Widget _buildResultStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated success icon
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 2),
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            Text('CNIC Verified!',
                style: GoogleFonts.syne(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Your identity has been verified successfully.\nYou now have a verified badge on your profile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textMuted, height: 1.6),
            ),
            const SizedBox(height: 20),
            // Verified badge preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text('CNIC Verified',
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF00C48C)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text('Back to Profile',
                      style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  Widget _sheetBtn(IconData icon, String label, VoidCallback onTap) {
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
                color: AppColors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.cyan, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Permission Required',
            style: GoogleFonts.syne(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text('Please enable gallery access in app settings.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () { Navigator.pop(context); openAppSettings(); },
              child: Text('Settings',
                  style: GoogleFonts.dmSans(
                      color: AppColors.cyan, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
