import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../services/listing_state.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCat = 0;

  final List<Map<String, String>> _categories = [
    {'icon': '🏠', 'label': 'Properties'},
    {'icon': '🏍️', 'label': 'Vehicles'},
    {'icon': '👗', 'label': 'Shadi Wear'},
    {'icon': '📦', 'label': 'Others'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ListingState(),
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      _buildCategories(),
                      const SizedBox(height: 14),
                      SectionHeader(
                        title: 'Featured Near You',
                        action: 'See all',
                        onAction: () => Navigator.pushNamed(context, '/search'),
                      ),
                      const SizedBox(height: 10),
                      _buildHorizontalCards(ListingState().featured),
                      const SizedBox(height: 14),
                      SectionHeader(
                        title: 'Trending: Shadi Wear',
                        action: 'See all',
                        onAction: () => Navigator.pushNamed(context, '/search'),
                      ),
                      const SizedBox(height: 10),
                      _buildHorizontalCards(SampleData.shadiFeatured),
                      // Show user listings section if any
                      if (ListingState().userListings.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SectionHeader(
                          title: 'My Listings',
                          action: 'See all',
                          onAction: () => Navigator.pushNamed(context, '/dashboard'),
                        ),
                        const SizedBox(height: 10),
                        _buildHorizontalCards(ListingState().userListings),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              AppBottomNav(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = UserState();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppLogo(),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: const Center(
                      child: Text('🔔', style: TextStyle(fontSize: 15))),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: UserAvatar(initials: user.initials),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final user = UserState();
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgElevated, AppColors.bgCard],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${user.firstName}',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            '📍 Bahawalpur, Punjab',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(
                    'Search listings...',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.cyan.withOpacity(0.2),
                          width: 0.5),
                    ),
                    child: Text(
                      'Filter',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final isActive = i == _selectedCat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.cyan.withOpacity(0.12)
                      : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? AppColors.cyan.withOpacity(0.3)
                        : AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(cat['icon']!,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      cat['label']!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColors.cyan
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHorizontalCards(List<Listing> listings) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: listings.asMap().entries.map((entry) {
          final isLast = entry.key == listings.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: ListingCard(
              listing: entry.value,
              width: MediaQuery.of(context).size.width * 0.55,
              onTap: () => Navigator.pushNamed(
                context,
                '/listing-detail',
                arguments: entry.value,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
