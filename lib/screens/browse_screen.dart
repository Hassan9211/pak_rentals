import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../models/category.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  int _selectedCat = 0;
  bool _isGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategories(),
            _buildResultsBar(),
            Expanded(
              child: _isGrid ? _buildGrid() : _buildList(),
            ),
            AppBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text('Search listings...', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _isGrid = !_isGrid),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Center(
                child: Icon(
                  _isGrid ? Icons.list : Icons.grid_view,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
            ),
            child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 15))),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: SampleCategories.all.asMap().entries.map((entry) {
            final i = entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryCard(
                category: entry.value,
                isSelected: i == _selectedCat,
                onTap: () => setState(() => _selectedCat = i),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('128 listings found · Bahawalpur',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
          Row(
            children: [
              Text('Sort', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.cyan)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: SampleData.searchResults.length,
      itemBuilder: (context, i) => ListingListItem(
        listing: SampleData.searchResults[i],
        onTap: () => Navigator.pushNamed(context, '/listing-detail'),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: SampleData.searchResults.length,
      itemBuilder: (context, i) => ListingCard(
        listing: SampleData.searchResults[i],
        onTap: () => Navigator.pushNamed(context, '/listing-detail'),
      ),
    );
  }
}
