import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../core/theme.dart';

/// Holds listings created by the current user during this session.
/// In a real app this would sync with a backend.
class ListingState extends ChangeNotifier {
  static final ListingState _instance = ListingState._internal();
  factory ListingState() => _instance;
  ListingState._internal();

  final List<Listing> _userListings = [];

  List<Listing> get userListings => List.unmodifiable(_userListings);

  /// All listings = sample data + user created
  List<Listing> get allListings => [
        ...SampleData.searchResults,
        ..._userListings,
      ];

  /// Featured = sample featured + first 2 user listings
  List<Listing> get featured => [
        ...SampleData.featured,
        ..._userListings.take(2),
      ];

  void addListing({
    required String title,
    required String location,
    required String price,
    required String priceUnit,
    required String category,
    required String hostName,
    required String hostInitials,
    required String description,
    required List<String> amenities,
    String? firstPhotoPath,
  }) {
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Category → emoji + bg color
    final emoji = _categoryEmoji(category);
    final bgColor = _categoryBg(category);

    final listing = Listing(
      id: id,
      title: title,
      location: location,
      price: price,
      priceUnit: priceUnit,
      rating: '0.0',
      reviews: 0,
      emoji: emoji,
      bgColor: bgColor,
      badge: 'New',
      category: category,
      hostName: hostName,
      hostInitials: hostInitials,
      amenities: amenities,
      description: description,
    );

    _userListings.insert(0, listing); // newest first
    notifyListeners();
  }

  void removeListing(String id) {
    _userListings.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  void clear() {
    _userListings.clear();
    notifyListeners();
  }

  String _categoryEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'properties': return '🏠';
      case 'vehicles': return '🚗';
      case 'shadi wear': return '👗';
      case 'electronics': return '📱';
      case 'furniture': return '🛋️';
      default: return '📦';
    }
  }

  Color _categoryBg(String cat) {
    switch (cat.toLowerCase()) {
      case 'properties': return const Color(0xFF0D1F1A);
      case 'vehicles': return const Color(0xFF0D1520);
      case 'shadi wear': return const Color(0xFF1A0D14);
      case 'electronics': return const Color(0xFF0D1428);
      default: return AppColors.bgCard;
    }
  }
}
