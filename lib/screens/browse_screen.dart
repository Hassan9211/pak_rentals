import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../models/category.dart';
import '../services/api_client.dart';
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
  List<Category> _categories = [];
  List<Listing> _listings = [];
  int _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadListings();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await CategoriesApi.getAll();
      final list = res['data'] as List? ?? [];
      if (mounted) {
        setState(() {
          _categories = list.map((e) {
            final m = e as Map<String, dynamic>;
            return Category(
              id: m['id'].toString(),
              name: m['name'] as String? ?? '',
              slug: m['slug'] as String? ?? '',
              icon: m['icon'] as String? ?? '📦',
            );
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    try {
      final category = _selectedCat > 0 && _selectedCat < _categories.length
          ? _categories[_selectedCat].slug
          : null;
      final res = await ListingsApi.getAll(category: category);
      final list = res['data'] as List? ?? [];
      final meta = res['meta'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _listings = list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
          _total = meta['total'] as int? ?? _listings.length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_categories.isNotEmpty) _buildCategories(),
            _buildResultsBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _listings.isEmpty
                      ? Center(child: Text('No listings', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)))
                      : RefreshIndicator(
                          color: AppColors.cyan,
                          backgroundColor: AppColors.bgCard,
                          onRefresh: _loadListings,
                          child: _isGrid ? _buildGrid() : _buildList(),
                        ),
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
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/search'),
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
              child: Center(child: Icon(_isGrid ? Icons.list : Icons.grid_view, size: 18, color: AppColors.textSecondary)),
            ),
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
          children: [
            CategoryCard(
              category: const Category(id: '0', name: 'All', slug: '', icon: '📦'),
              isSelected: _selectedCat == 0,
              onTap: () { setState(() => _selectedCat = 0); _loadListings(); },
            ),
            const SizedBox(width: 8),
            ..._categories.asMap().entries.map((entry) {
              final i = entry.key + 1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryCard(
                  category: entry.value,
                  isSelected: i == _selectedCat,
                  onTap: () { setState(() => _selectedCat = i); _loadListings(); },
                ),
              );
            }),
          ],
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
          Text('$_total listings found',
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
      itemCount: _listings.length,
      itemBuilder: (context, i) => ListingListItem(
        listing: _listings[i],
        onTap: () => Navigator.pushNamed(context, '/listing-detail', arguments: _listings[i]),
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
      itemCount: _listings.length,
      itemBuilder: (context, i) => ListingCard(
        listing: _listings[i],
        onTap: () => Navigator.pushNamed(context, '/listing-detail', arguments: _listings[i]),
      ),
    );
  }
}
