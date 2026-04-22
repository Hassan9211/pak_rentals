import '../models/listing.dart';

/// Listing service — replace with real HTTP calls when backend is ready.
class ListingService {
  /// Fetch paginated listings with optional filters.
  static Future<List<Listing>> getListings({
    String? category,
    String? city,
    double? maxPrice,
    int page = 1,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SampleData.searchResults;
  }

  /// Fetch featured listings for home screen.
  static Future<List<Listing>> getFeatured() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [...SampleData.featured, ...SampleData.shadiFeatured];
  }

  /// Fetch a single listing by ID.
  static Future<Listing?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = [...SampleData.featured, ...SampleData.shadiFeatured, ...SampleData.searchResults];
    try {
      return all.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new listing (stub).
  static Future<String?> createListing(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'new_listing_id';
  }

  /// Update an existing listing (stub).
  static Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  /// Delete a listing (stub).
  static Future<bool> deleteListing(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
