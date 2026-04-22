import '../models/listing.dart';
import '../services/api_client.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  ListingRepository
//  Converts raw API Map responses into typed Listing objects.
//  UI calls this — never calls ListingsApi directly.
// ═══════════════════════════════════════════════════════════════════════════
class ListingRepository {
  static final ListingRepository _i = ListingRepository._();
  factory ListingRepository() => _i;
  ListingRepository._();

  // ── Featured listings (home screen) ──
  Future<List<Listing>> fetchFeatured() async {
    final res = await ListingsApi.getFeatured();
    final list = res['data'] as List? ?? [];
    return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Browse / search with filters ──
  Future<({List<Listing> listings, int total, int page, int pages})> fetchAll({
    String? q,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
    String sort = 'newest',
  }) async {
    final res = await ListingsApi.getAll(
      q: q,
      category: category,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      limit: limit,
      sort: sort,
    );
    final list = res['data'] as List? ?? [];
    final meta = res['meta'] as Map<String, dynamic>? ?? {};
    return (
      listings: list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta['total'] as int? ?? list.length,
      page: meta['current_page'] as int? ?? page,
      pages: meta['last_page'] as int? ?? 1,
    );
  }

  // ── Single listing detail ──
  Future<Listing> fetchOne(String id) async {
    final res = await ListingsApi.getOne(id);
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return Listing.fromJson(data);
  }

  // ── My listings (host dashboard) ──
  Future<List<Listing>> fetchMine() async {
    final res = await ListingsApi.getMine();
    final list = res['data'] as List? ?? [];
    return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
  }
}
