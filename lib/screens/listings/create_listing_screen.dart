import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../models/category.dart';
import '../../services/listing_state.dart';
import '../../services/user_state.dart';
import '../../widgets/common/gradient_button.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  int _step = 0;
  int _selectedCat = 0;
  String _priceUnit = '/day';

  // Step 0 controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Step 1 controllers
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _minPeriodCtrl = TextEditingController();

  // Step 0 errors
  String? _titleError;
  String? _locationError;

  // Step 1 errors
  String? _priceError;

  // Photos
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxPhotos = 8;

  // Step 2 errors
  String? _photoError;

  final List<String> _priceUnits = ['/day', '/week', '/month', '/event'];

  // Selected amenities
  final Set<String> _selectedAmenities = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _minPeriodCtrl.dispose();
    super.dispose();
  }

  // ── Validation ──
  bool _validateStep0() {
    bool valid = true;
    setState(() {
      _titleError = _titleCtrl.text.trim().isEmpty
          ? 'Listing title is required'
          : _titleCtrl.text.trim().length < 5
              ? 'Title must be at least 5 characters'
              : null;
      _locationError = _locationCtrl.text.trim().isEmpty
          ? 'Location is required'
          : null;
    });
    if (_titleError != null || _locationError != null) valid = false;
    return valid;
  }

  bool _validateStep1() {
    bool valid = true;
    setState(() {
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      _priceError = _priceCtrl.text.trim().isEmpty
          ? 'Price is required'
          : price <= 0
              ? 'Enter a valid price greater than 0'
              : null;
    });
    if (_priceError != null) valid = false;
    return valid;
  }

  bool _validateStep2() {
    setState(() {
      _photoError = _photos.isEmpty ? 'Please add at least 1 photo' : null;
    });
    return _photos.isNotEmpty;
  }

  void _onContinue() {
    if (_step == 0 && !_validateStep0()) return;
    if (_step == 1 && !_validateStep1()) return;
    if (_step == 2) {
      if (!_validateStep2()) return;
      _submitListing();
      return;
    }
    setState(() => _step++);
  }

  void _submitListing() {
    final category = SampleCategories.all[_selectedCat].name;
    final user = UserState();

    ListingState().addListing(
      title: _titleCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      price: _priceCtrl.text.trim(),
      priceUnit: _priceUnit,
      category: category,
      hostName: user.name,
      hostInitials: user.initials,
      description: _descCtrl.text.trim(),
      amenities: _selectedAmenities.toList(),
      firstPhotoPath: _photos.isNotEmpty ? _photos.first.path : null,
    );

    _showSnack('Listing submitted for review! ✅');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= _maxPhotos) {
      _showSnack('Maximum $_maxPhotos photos allowed');
      return;
    }

    // Request permission first
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // Android 13+ uses READ_MEDIA_IMAGES, older uses READ_EXTERNAL_STORAGE
      permission = Permission.photos;
    }

    final status = await permission.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      if (status.isPermanentlyDenied) {
        _showPermissionDialog(source == ImageSource.camera ? 'Camera' : 'Gallery');
      } else {
        _showSnack(source == ImageSource.camera
            ? 'Camera permission denied'
            : 'Gallery permission denied');
      }
      return;
    }

    try {
      final XFile? img = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (img != null && mounted) {
        setState(() => _photos.add(img));
        setState(() => _photoError = null);
      }
    } catch (e) {
      if (mounted) _showSnack('Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}. Check app permissions.');
    }
  }

  Future<void> _pickMultiple() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) {
      _showSnack('Maximum $_maxPhotos photos allowed');
      return;
    }

    final status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (status.isPermanentlyDenied) {
        _showPermissionDialog('Gallery');
      } else {
        _showSnack('Gallery permission denied');
      }
      return;
    }

    try {
      final List<XFile> imgs = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (imgs.isNotEmpty && mounted) {
        setState(() {
          _photos.addAll(imgs.take(remaining));
          _photoError = null;
        });
      }
    } catch (e) {
      if (mounted) _showSnack('Could not open gallery. Check app permissions.');
    }
  }

  void _showPermissionDialog(String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('$type Permission Required',
            style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text(
          '$type access is permanently denied. Please enable it in app settings.',
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
              openAppSettings();
            },
            child: Text('Open Settings', style: GoogleFonts.dmSans(color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  void _reorderPhoto(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, item);
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showPickerSheet() {
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
              Text('Add Photo',
                  style: GoogleFonts.syne(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _sheetOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                sub: 'Use camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _sheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                sub: 'Select one photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              _sheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Select Multiple',
                sub: 'Pick up to ${_maxPhotos - _photos.length} photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickMultiple();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.cyan, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(sub,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: [
                  _buildStep0(),
                  _buildStep1(),
                  _buildStep2(),
                ][_step],
              ),
            ),
            _buildFooter(),
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
              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text('Create Listing', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          Text('Step ${_step + 1}/3', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Details', 'Pricing', 'Photos'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.bgElevated,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          // Even indices = step circles, odd indices = connector lines
          if (index.isOdd) {
            // Connector line between steps
            final stepIndex = index ~/ 2;
            final isDone = stepIndex < _step;
            return Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isDone ? AppColors.success : AppColors.borderLight,
              ),
            );
          }

          final i = index ~/ 2;
          final isDone = i < _step;
          final isActive = i == _step;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.success
                      : isActive
                          ? AppColors.cyan
                          : AppColors.bgInput,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? AppColors.success
                        : isActive
                            ? AppColors.cyan
                            : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 13, color: Colors.black)
                      : Text(
                          '${i + 1}',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.black : AppColors.textMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: isActive
                      ? AppColors.cyan
                      : isDone
                          ? AppColors.success
                          : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Category'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.4,
          children: SampleCategories.all.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final isSelected = i == _selectedCat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = i),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cyan.withValues(alpha: 0.12) : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.cyan.withValues(alpha: 0.4) : AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(cat.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: isSelected ? AppColors.cyan : AppColors.textSecondary,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Listing Title'),
        const SizedBox(height: 8),
        _controlledField(
          controller: _titleCtrl,
          hint: 'e.g. 3-Bed House – Model Town',
          error: _titleError,
          onChanged: (_) => setState(() => _titleError = null),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Description'),
        const SizedBox(height: 8),
        _textArea(controller: _descCtrl, hint: 'Describe your listing in detail...'),
        const SizedBox(height: 16),
        _sectionTitle('Location'),
        const SizedBox(height: 8),
        _controlledField(
          controller: _locationCtrl,
          hint: 'e.g. Model Town, Bahawalpur',
          icon: '📍',
          error: _locationError,
          onChanged: (_) => setState(() => _locationError = null),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Rental Price'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _priceError != null
                          ? AppColors.error.withValues(alpha: 0.05)
                          : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _priceError != null ? AppColors.error : AppColors.borderLight,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('PKR', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() => _priceError = null),
                            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_priceError != null) ...[
                    const SizedBox(height: 4),
                    Text(_priceError!,
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _priceUnit,
                  dropdownColor: AppColors.bgCard,
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
                  items: _priceUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _priceUnit = v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Security Deposit (optional)'),
        const SizedBox(height: 8),
        _controlledField(controller: _depositCtrl, hint: 'PKR 0', icon: '🔒'),
        const SizedBox(height: 16),
        _sectionTitle('Minimum Rental Period'),
        const SizedBox(height: 8),
        _controlledField(controller: _minPeriodCtrl, hint: 'e.g. 1 day, 1 week'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Row(
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PakRentals charges a 10% platform fee on each booking. You receive 90% of the rental price.',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.cyan, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final amenityList = [
      '🛏️ Beds', '🚿 Baths', '🅿️ Parking', '⚡ Generator',
      '❄️ AC', '📶 WiFi', '🔒 Security', '🚗 Garage',
      '🛁 Bathtub', '🍳 Kitchen', '🧺 Laundry', '🐾 Pet friendly',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Photos section ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Photos'),
            Text(
              '${_photos.length}/$_maxPhotos',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: _photos.length >= _maxPhotos
                    ? AppColors.warning
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'First photo will be the cover. Long-press to reorder.',
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),

        // Photo grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Existing photos
            ..._photos.asMap().entries.map((entry) {
              final i = entry.key;
              final photo = entry.value;
              final cellSize = (MediaQuery.of(context).size.width - 56) / 3;
              return SizedBox(
                width: cellSize,
                height: cellSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photo.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Cover badge
                    if (i == 0)
                      Positioned(
                        top: 4, left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyan,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Cover',
                              style: GoogleFonts.dmSans(
                                  fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black)),
                        ),
                      ),
                    // Remove button
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                    // Set as cover button (for non-first photos)
                    if (i > 0)
                      Positioned(
                        bottom: 4, left: 4,
                        child: GestureDetector(
                          onTap: () => _reorderPhoto(i, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Set cover',
                                style: GoogleFonts.dmSans(
                                    fontSize: 8, color: Colors.white)),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            // Add photo button (only if under limit)
            if (_photos.length < _maxPhotos)
              GestureDetector(
                onTap: _showPickerSheet,
                child: Builder(builder: (context) {
                  final cellSize = (MediaQuery.of(context).size.width - 56) / 3;
                  return Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_rounded,
                            color: AppColors.cyan, size: 26),
                        const SizedBox(height: 6),
                        Text('Add Photo',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.cyan)),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),

        // Empty state hint
        if (_photos.isEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _photoError != null
                  ? AppColors.error.withValues(alpha: 0.05)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _photoError != null ? AppColors.error : AppColors.borderLight,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                const Text('🖼️', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text('No photos added yet',
                    style: GoogleFonts.dmSans(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: _photoError != null ? AppColors.error : AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  _photoError ?? 'Listings with photos get 3x more bookings',
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _photoError != null ? AppColors.error : AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Amenities section ──
        _sectionTitle('Amenities / Features'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenityList.map((a) {
            final isSelected = _selectedAmenities.contains(a);
            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedAmenities.remove(a);
                } else {
                  _selectedAmenities.add(a);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cyan.withValues(alpha: 0.12)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.cyan.withValues(alpha: 0.4)
                        : AppColors.borderLight,
                    width: isSelected ? 1 : 0.5,
                  ),
                ),
                child: Text(
                  a,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isSelected ? AppColors.cyan : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (_selectedAmenities.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${_selectedAmenities.length} selected',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.cyan),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _step--),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, width: 0.5),
                  ),
                  child: Center(
                    child: Text('Back', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GradientButton(
              label: _step < 2 ? 'Continue' : 'Submit for Review',
              onTap: _onContinue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      );

  // Controlled field with error support
  Widget _controlledField({
    required TextEditingController controller,
    required String hint,
    String? icon,
    String? error,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: error != null ? AppColors.error.withValues(alpha: 0.05) : AppColors.bgInput,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: error != null ? AppColors.error : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: icon == null ? 14 : 0,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error)),
        ],
      ],
    );
  }

  // Legacy plain field kept for reference — currently unused
  // ignore: unused_element
  Widget _textField({required String hint, String? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          Expanded(
            child: TextField(
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: icon == null ? 14 : 0,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textArea({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
