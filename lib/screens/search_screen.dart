import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../services/api_client.dart';
import '../widgets/common_widgets.dart';
import '../widgets/listing_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  int _activeFilter = 0;
  String _query = '';
  List<Listing> _results = [];
  int _total = 0;
  bool _loading = false;

  final List<String> _filters = ['All', 'Properties', 'Vehicles', 'Shadi Wear'];
  static const Map<String, String?> _filterMap = {
    'All': null,
    'Properties': 'properties',
    'Vehicles': 'vehicles',
    'Shadi Wear': 'shadi-wear',
  };

  @override
  void initState() {
    super.initState();
    _search();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final category = _filterMap[_filters[_activeFilter]];
      final res = await ListingsApi.getAll(
        q: _query.isEmpty ? null : _query,
        category: category,
      );
      final list = res['data'] as List? ?? [];
      final meta = res['meta'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _results = list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
          _total = meta['total'] as int? ?? _results.length;
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
            _buildFilterChips(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _loading ? 'Searching...' : '$_total listing${_total == 1 ? '' : 's'} found',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (_query.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text('· "$_query"', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.cyan)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _results.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _results.length,
                          itemBuilder: (context, i) => ListingListItem(
                            listing: _results[i],
                            onTap: () => Navigator.pushNamed(context, '/listing-detail', arguments: _results[i]),
                          ),
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
          const AppBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search listings, locations...',
                        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        setState(() => _query = v.trim());
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_query == v.trim()) _search();
                        });
                      },
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                        _search();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close, size: 16, color: AppColors.textMuted),
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

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.asMap().entries.map((entry) {
            final i = entry.key;
            final label = entry.value;
            final isActive = i == _activeFilter;
            return GestureDetector(
              onTap: () {
                setState(() => _activeFilter = i);
                _search();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.cyan.withValues(alpha: 0.12) : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.cyan.withValues(alpha: 0.3) : AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: isActive ? AppColors.cyan : AppColors.textSecondary,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 14),
          Text(_query.isNotEmpty ? 'No results for "$_query"' : 'No listings found',
              style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Try a different keyword or filter',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
          if (_query.isNotEmpty || _activeFilter != 0) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() { _query = ''; _activeFilter = 0; });
                _search();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text('Clear filters', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.cyan, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
