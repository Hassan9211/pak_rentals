import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../services/api_client.dart';
import '../widgets/common_widgets.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Listing> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await WishlistApi.getAll();
      final list = res['data'] as List? ?? [];
      if (mounted) {
        setState(() {
          _saved = list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(Listing listing) async {
    setState(() => _saved.removeWhere((l) => l.id == listing.id));
    await WishlistApi.toggle(listing.id); // toggle off
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Removed from saved', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.cyan,
        onPressed: () async {
          await WishlistApi.toggle(listing.id); // toggle back on
          _load();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _saved.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.cyan,
                          backgroundColor: AppColors.bgCard,
                          onRefresh: _load,
                          child: _buildList(),
                        ),
            ),
            AppBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          Text('Saved', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${_saved.length}', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _saved.length,
      itemBuilder: (context, i) {
        final listing = _saved[i];
        return Dismissible(
          key: ValueKey(listing.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
          ),
          onDismissed: (_) => _remove(listing),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SavedCard(
              listing: listing,
              onTap: () => Navigator.pushNamed(context, '/listing-detail', arguments: listing),
              onRemove: () => _remove(listing),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: const Center(child: Text('❤️', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          Text('No saved listings yet', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Tap the ❤️ on any listing to save it here', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(20)),
              child: Text('Browse Listings', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _SavedCard({required this.listing, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: listing.bgColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
              ),
              child: Center(child: Text(listing.emoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title,
                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('📍 ${listing.location}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'PKR ${listing.price}',
                            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cyan)),
                        TextSpan(text: listing.priceUnit,
                            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: const Icon(Icons.favorite, size: 14, color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
