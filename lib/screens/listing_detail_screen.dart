import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../services/booking_state.dart';
import '../widgets/common_widgets.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _imgIndex = 0;
  bool _isSaved = false;

  // Category → emoji background color map
  static const Map<String, Color> _catBg = {
    'Properties': Color(0xFF0D1F1A),
    'Vehicles': Color(0xFF0D1520),
    'Shadi Wear': Color(0xFF1A0D14),
    'Electronics': Color(0xFF0D1428),
    'Furniture': Color(0xFF141826),
    'Others': Color(0xFF141826),
  };

  // Category → amenity suggestions
  static const Map<String, List<String>> _catAmenities = {
    'Properties': ['🛏️ Bedrooms', '🚿 Bathrooms', '🅿️ Parking', '⚡ Generator', '❄️ AC', '📶 WiFi'],
    'Vehicles': ['⛽ Fuel included', '🔑 Self-drive', '👨‍✈️ With driver', '🛡️ Insured'],
    'Shadi Wear': ['👗 Full set', '🧵 Tailored', '💄 Accessories', '📦 Delivery available'],
    'Electronics': ['🔌 Charger included', '📦 Box included', '🛡️ Warranty'],
    'Furniture': ['🚚 Delivery', '🔧 Assembly', '📦 Packaging'],
    'Others': ['📦 Available', '✅ Verified'],
  };

  @override
  Widget build(BuildContext context) {
    // Receive listing from navigation arguments
    final listing = ModalRoute.of(context)?.settings.arguments as Listing?;

    // Fallback if opened directly without arguments
    if (listing == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              const AppBackButton(),
              const Expanded(
                child: Center(
                  child: Text('Listing not found', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bgColor = _catBg[listing.category] ?? const Color(0xFF141826);
    final amenities = listing.amenities.isNotEmpty
        ? listing.amenities
        : (_catAmenities[listing.category] ?? []);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageSection(listing, bgColor),
                    _buildDetailSheet(context, listing, amenities),
                  ],
                ),
              ),
            ),
            AppBottomNav(currentIndex: -1),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Listing listing, Color bgColor) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, AppColors.bg],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(listing.emoji, style: const TextStyle(fontSize: 72)),
          ),
          // Back button
          Positioned(
            top: 12,
            left: 12,
            child: const AppBackButton(),
          ),
          // Save button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => setState(() => _isSaved = !_isSaved),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Text(
                    _isSaved ? '❤️' : '🤍',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          // Image dots
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final isActive = i == _imgIndex;
                return GestureDetector(
                  onTap: () => setState(() => _imgIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.cyan
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSheet(BuildContext context, Listing listing, List<String> amenities) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 0.5),
            left: BorderSide(color: AppColors.borderLight, width: 0.5),
            right: BorderSide(color: AppColors.borderLight, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              listing.title,
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            // Location + category + rating
            Wrap(
              spacing: 6,
              children: [
                Text('📍 ${listing.location}',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                Text('·', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                Text(listing.category,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                Text('·', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                Text('⭐ ${listing.rating} (${listing.reviews} reviews)',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 12),
            // Amenity pills
            if (amenities.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: amenities
                    .map((a) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderLight, width: 0.5),
                          ),
                          child: Text(a,
                              style: GoogleFonts.dmSans(
                                  fontSize: 10, color: AppColors.textSecondary)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            // Description
            if (listing.description.isNotEmpty) ...[
              Text(
                listing.description,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Host card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  UserAvatar(initials: listing.hostInitials, size: 34),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.hostName,
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                      Text('✓ CNIC Verified',
                          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: Text('Message',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.cyan, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Price + Book
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'PKR ${listing.price}',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan,
                            ),
                          ),
                          TextSpan(
                            text: listing.priceUnit,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      listing.category == 'Properties'
                          ? 'Negotiable · Contact host'
                          : 'Best price guaranteed',
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    BookingState().setListing(listing);
                    Navigator.pushNamed(context, '/booking');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Book Now',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
