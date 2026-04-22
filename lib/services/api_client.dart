import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PakRentals — Central API Client
//  Aligned with Laravel api.php (Sanctum auth)
//
//  Backend response format:
//    { "data": { "token": "...", "user": {...} }, "message": "..." }
//    OR flat: { "token": "...", "user": {...} }
//  Both formats handled automatically.
//
//  Image paths from backend are storage paths (e.g. "listings/abc.jpg").
//  Use StorageHelper.url(path) to get the full URL.
// ═══════════════════════════════════════════════════════════════════════════

// ── Storage URL helper ─────────────────────────────────────────────────────
class StorageHelper {
  /// Converts a Laravel storage path to a full public URL.
  /// e.g. "listings/abc.jpg" → "https://your-domain.com/storage/listings/abc.jpg"
  /// Already-full URLs are returned as-is.
  static String url(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = AppConstants.storageBaseUrl.replaceAll(RegExp(r'/$'), '');
    final p = path.replaceAll(RegExp(r'^/'), '');
    return '$base/$p';
  }

  /// Convert a list of storage paths to full URLs.
  static List<String> urls(List<dynamic>? paths) {
    if (paths == null) return [];
    return paths.map((p) => url(p?.toString())).where((u) => u.isNotEmpty).toList();
  }
}

// ── Exception ──────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors; // Laravel validation errors

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Returns first validation error message for a field
  String? fieldError(String field) {
    final list = errors?[field];
    if (list is List && list.isNotEmpty) return list.first as String;
    return null;
  }
}

// ── Base HTTP client ────────────────────────────────────────────────────────
class ApiClient {
  static const String _base = AppConstants.apiBaseUrl;

  // ── Token ──
  static Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(AppConstants.keyAuthToken);
  }

  static Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.keyAuthToken, token);
  }

  static Future<void> clearToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(AppConstants.keyAuthToken);
  }

  // ── Headers ──
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // ── Response handler ──
  // Backend returns two formats:
  //   1. { "data": {...}, "message": "..." }          ← most endpoints
  //   2. { "data": [...], "meta": {...} }              ← paginated lists
  //   3. { "token": "...", "user": {...} }             ← auth (flat)
  // All handled here — just use res['data'] in callers.
  static Map<String, dynamic> _handle(http.Response res) {
    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'message': res.body};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    // 401 — token expired → clear it so app can re-login
    if (res.statusCode == 401) {
      clearToken();
    }

    throw ApiException(
      statusCode: res.statusCode,
      message: body['message'] as String? ?? 'Request failed',
      errors: body['errors'] as Map<String, dynamic>?,
    );
  }

  // ── GET ──
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: await _headers(auth: auth));
    return _handle(res);
  }

  // ── POST ──
  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final res = await http.post(
      uri,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(res);
  }

  // ── PUT ──
  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final res = await http.put(
      uri,
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(res);
  }

  // ── DELETE ──
  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final res = await http.delete(uri, headers: await _headers(auth: auth));
    return _handle(res);
  }

  // ── MULTIPART upload ──
  static Future<Map<String, dynamic>> upload(
    String path, {
    String method = 'POST',
    required Map<String, String> fields,
    Map<String, File>? files,
    Map<String, List<File>>? multiFiles, // for arrays like photos[]
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final req = http.MultipartRequest(method, uri);

    final headers = await _headers(auth: auth);
    headers.remove('Content-Type');
    req.headers.addAll(headers);
    req.fields.addAll(fields);

    if (files != null) {
      for (final e in files.entries) {
        req.files.add(await http.MultipartFile.fromPath(e.key, e.value.path));
      }
    }
    if (multiFiles != null) {
      for (final e in multiFiles.entries) {
        for (final file in e.value) {
          // Use field name with [] suffix — matches Laravel's images.* / photos.*
          req.files.add(await http.MultipartFile.fromPath('${e.key}[]', file.path));
        }
      }
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  AUTH  —  /api/register  /api/login  /api/logout  /api/user
// ═══════════════════════════════════════════════════════════════════════════
class AuthApi {
  /// Extract token from backend response.
  /// Backend returns: { "data": { "token": "...", "user": {...} }, "message": "..." }
  /// Fallback: flat { "token": "..." }
  static String? _extractToken(Map<String, dynamic> res) {
    // Try nested: res['data']['token']
    final data = res['data'];
    if (data is Map<String, dynamic>) {
      final t = data['token'];
      if (t is String && t.isNotEmpty) return t;
    }
    // Try flat: res['token']
    final t = res['token'];
    if (t is String && t.isNotEmpty) return t;
    return null;
  }

  /// Extract user from backend response.
  static Map<String, dynamic>? extractUser(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is Map<String, dynamic>) {
      final u = data['user'];
      if (u is Map<String, dynamic>) return u;
    }
    final u = res['user'];
    if (u is Map<String, dynamic>) return u;
    return null;
  }

  /// POST /api/register
  /// Note: backend does not accept 'role' — all users register as 'user'.
  /// Admin/moderator roles assigned later via /api/admin/users/:id/role
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? tehsil,
    String? cnic,
  }) async {
    final res = await ApiClient.post('/register', body: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (city != null && city.isNotEmpty) 'city': city,
      if (tehsil != null && tehsil.isNotEmpty) 'location_tehsil': tehsil,
      if (cnic != null && cnic.isNotEmpty) 'cnic': cnic,
    }, auth: false);
    final token = _extractToken(res);
    if (token != null) await ApiClient.saveToken(token);
    return res;
  }

  /// POST /api/login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.post('/login', body: {
      'email': email,
      'password': password,
    }, auth: false);
    final token = _extractToken(res);
    if (token != null) await ApiClient.saveToken(token);
    return res;
  }

  /// POST /api/logout
  static Future<void> logout() async {
    try {
      await ApiClient.post('/logout');
    } finally {
      await ApiClient.clearToken();
    }
  }

  /// GET /api/user
  static Future<Map<String, dynamic>> getMe() async {
    return ApiClient.get('/user');
  }

  /// PUT /api/user
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? city,
    String? cnic,
  }) async {
    return ApiClient.put('/user', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (city != null) 'city': city,
      if (cnic != null) 'cnic': cnic,
    });
  }

  /// POST /api/user/photo  (multipart)
  static Future<String> uploadProfilePhoto(File photo) async {
    final res = await ApiClient.upload(
      '/user/photo',
      fields: {},
      files: {'photo': photo},
    );
    return res['photo_url'] as String;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DASHBOARD  —  /api/dashboard
// ═══════════════════════════════════════════════════════════════════════════
class DashboardApi {
  /// GET /api/dashboard
  /// Returns: my_listings, my_bookings, host_requests,
  ///          unread_count, pending_payments_count, open_reports_count
  static Future<Map<String, dynamic>> get() async {
    return ApiClient.get('/dashboard');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CATEGORIES  —  /api/categories
// ═══════════════════════════════════════════════════════════════════════════
class CategoriesApi {
  /// GET /api/categories
  static Future<Map<String, dynamic>> getAll() async {
    return ApiClient.get('/categories', auth: false);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  LISTINGS  —  /api/listings  /api/my-listings
// ═══════════════════════════════════════════════════════════════════════════
class ListingsApi {
  /// GET /api/listings
  static Future<Map<String, dynamic>> getAll({
    String? q,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
    String sort = 'newest',
  }) async {
    return ApiClient.get('/listings', query: {
      if (q != null) 'q': q,
      if (category != null) 'category': category,
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
    }, auth: false);
  }

  /// GET /api/listings/featured
  static Future<Map<String, dynamic>> getFeatured() async {
    return ApiClient.get('/listings/featured', auth: false);
  }

  /// GET /api/listings/:id
  static Future<Map<String, dynamic>> getOne(String id) async {
    return ApiClient.get('/listings/$id', auth: false);
  }

  /// GET /api/listings/:id/reviews
  static Future<Map<String, dynamic>> getReviews(String id,
      {int page = 1}) async {
    return ApiClient.get('/listings/$id/reviews',
        query: {'page': page.toString()}, auth: false);
  }

  /// GET /api/listings/:id/availability
  static Future<Map<String, dynamic>> getAvailability(String id) async {
    return ApiClient.get('/listings/$id/availability', auth: false);
  }

  /// GET /api/my-listings
  static Future<Map<String, dynamic>> getMine() async {
    return ApiClient.get('/my-listings');
  }

  /// POST /api/listings  (multipart)
  static Future<Map<String, dynamic>> create({
    required String title,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double pricePerDay,
    double? pricePerWeek,
    double? pricePerMonth,
    double? securityDeposit,
    required String locationCity,
    String? locationTehsil,
    required List<File> images,
  }) async {
    return ApiClient.upload(
      '/listings',
      fields: {
        'title': title,
        'description': description,
        'category_id': categoryId,
        if (subCategoryId != null) 'sub_category_id': subCategoryId,
        'price_per_day': pricePerDay.toString(),
        if (pricePerWeek != null) 'price_per_week': pricePerWeek.toString(),
        if (pricePerMonth != null) 'price_per_month': pricePerMonth.toString(),
        if (securityDeposit != null)
          'security_deposit': securityDeposit.toString(),
        'location_city': locationCity,
        if (locationTehsil != null) 'location_tehsil': locationTehsil,
      },
      multiFiles: {'images': images},
    );
  }

  /// PUT /api/listings/:id
  /// Backend only accepts: title, description, price_per_day,
  /// price_per_week, price_per_month, location_city
  /// Status values allowed: draft | inactive  (not 'approved' — admin sets that)
  static Future<Map<String, dynamic>> update(
    String id, {
    String? title,
    String? description,
    double? pricePerDay,
    double? pricePerWeek,
    double? pricePerMonth,
    String? locationCity,
    String? status, // draft | inactive only
  }) async {
    return ApiClient.put('/listings/$id', body: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (pricePerDay != null) 'price_per_day': pricePerDay,
      if (pricePerWeek != null) 'price_per_week': pricePerWeek,
      if (pricePerMonth != null) 'price_per_month': pricePerMonth,
      if (locationCity != null) 'location_city': locationCity,
      if (status != null) 'status': status,
    });
  }

  /// DELETE /api/listings/:id
  static Future<void> delete(String id) async {
    await ApiClient.delete('/listings/$id');
  }

  /// POST /api/listings/:id/availability
  static Future<void> updateAvailability(
    String id, {
    required String startDate,
    required String endDate,
    required bool isAvailable,
    String? note,
  }) async {
    await ApiClient.post('/listings/$id/availability', body: {
      'start_date': startDate,
      'end_date': endDate,
      'is_available': isAvailable,
      if (note != null) 'note': note,
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  WISHLIST  —  /api/wishlist  /api/wishlist/:id
// ═══════════════════════════════════════════════════════════════════════════
class WishlistApi {
  /// GET /api/wishlist
  static Future<Map<String, dynamic>> getAll() async {
    return ApiClient.get('/wishlist');
  }

  /// POST /api/wishlist/:id  (toggle save/unsave)
  /// Returns: { saved: true|false }
  static Future<bool> toggle(String listingId) async {
    final res = await ApiClient.post('/wishlist/$listingId');
    return res['saved'] as bool? ?? false;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOOKINGS  —  /api/bookings
// ═══════════════════════════════════════════════════════════════════════════
class BookingsApi {
  /// POST /api/bookings
  static Future<Map<String, dynamic>> create({
    required String listingId,
    required String startDate, // "2026-05-08"
    required String endDate,   // "2026-05-14"
  }) async {
    return ApiClient.post('/bookings', body: {
      'listing_id': listingId,
      'start_date': startDate,
      'end_date': endDate,
    });
  }

  /// GET /api/bookings
  /// Returns: { as_renter: [...], as_host: [...] }
  static Future<Map<String, dynamic>> getAll() async {
    return ApiClient.get('/bookings');
  }

  /// GET /api/bookings/:id
  static Future<Map<String, dynamic>> getOne(String id) async {
    return ApiClient.get('/bookings/$id');
  }

  /// POST /api/bookings/:id/approve  (host)
  static Future<Map<String, dynamic>> approve(String id) async {
    return ApiClient.post('/bookings/$id/approve');
  }

  /// POST /api/bookings/:id/reject  (host)
  static Future<Map<String, dynamic>> reject(String id) async {
    return ApiClient.post('/bookings/$id/reject');
  }

  /// POST /api/bookings/:id/pay  (renter)
  /// gateway: jazzcash | easypaisa | bank-transfer
  static Future<Map<String, dynamic>> pay(
      String id, String gateway) async {
    return ApiClient.post('/bookings/$id/pay', body: {'gateway': gateway});
  }

  /// POST /api/bookings/:id/complete  (host)
  static Future<Map<String, dynamic>> complete(String id) async {
    return ApiClient.post('/bookings/$id/complete');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HANDOVER PROOFS  —  /api/bookings/:id/handover  /api/bookings/:id/finalize
// ═══════════════════════════════════════════════════════════════════════════
class HandoverApi {
  /// GET /api/bookings/:id/handover
  /// Backend returns:
  /// {
  ///   data: {
  ///     pickup: { host: HandoverProof|null, renter: HandoverProof|null },
  ///     return: { host: HandoverProof|null, renter: HandoverProof|null },
  ///     all_submitted: bool   (true when proofs.count >= 4)
  ///   }
  /// }
  static Future<Map<String, dynamic>> getProofs(String bookingId) async {
    return ApiClient.get('/bookings/$bookingId/handover');
  }

  /// POST /api/bookings/:id/handover  (multipart)
  /// type: pickup | return
  static Future<Map<String, dynamic>> uploadProof({
    required String bookingId,
    required String type, // pickup | return
    required List<File> photos,
    String? note,
  }) async {
    return ApiClient.upload(
      '/bookings/$bookingId/handover',
      fields: {
        'type': type,
        if (note != null) 'note': note,
      },
      multiFiles: {'photos': photos},
    );
  }

  /// POST /api/bookings/:id/finalize
  static Future<Map<String, dynamic>> finalize(String bookingId) async {
    return ApiClient.post('/bookings/$bookingId/finalize');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  REVIEWS  —  /api/reviews  /api/reviews/latest
// ═══════════════════════════════════════════════════════════════════════════
class ReviewsApi {
  /// POST /api/reviews
  static Future<Map<String, dynamic>> submit({
    required String bookingId,
    required String listingId,
    required int rating,
    String? comment,
  }) async {
    return ApiClient.post('/reviews', body: {
      'booking_id': bookingId,
      'listing_id': listingId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
  }

  /// GET /api/reviews/latest  (home screen)
  static Future<Map<String, dynamic>> getLatest() async {
    return ApiClient.get('/reviews/latest', auth: false);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MESSAGES  —  /api/conversations  /api/messages
// ═══════════════════════════════════════════════════════════════════════════
class MessagesApi {
  /// GET /api/conversations
  static Future<Map<String, dynamic>> getConversations() async {
    return ApiClient.get('/conversations');
  }

  /// GET /api/conversations/:listing_id/:user_id
  static Future<Map<String, dynamic>> getThread(
      String listingId, String userId) async {
    return ApiClient.get('/conversations/$listingId/$userId');
  }

  /// POST /api/messages
  static Future<Map<String, dynamic>> send({
    required String receiverId,
    required String listingId,
    required String message,
  }) async {
    return ApiClient.post('/messages', body: {
      'receiver_id': receiverId,
      'listing_id': listingId,
      'message': message,
    });
  }

  /// POST /api/messages/:id/read
  static Future<void> markRead(String messageId) async {
    await ApiClient.post('/messages/$messageId/read');
  }

  /// GET /api/messages/unread-count
  static Future<int> getUnreadCount() async {
    final res = await ApiClient.get('/messages/unread-count');
    return res['count'] as int? ?? 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  NOTIFICATIONS  —  /api/notifications
// ═══════════════════════════════════════════════════════════════════════════
class NotificationsApi {
  /// GET /api/notifications
  /// Returns: booking_requests, payment_alerts, unread_messages, open_reports
  static Future<Map<String, dynamic>> getAll() async {
    return ApiClient.get('/notifications');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  REPORTS  —  /api/reports
// ═══════════════════════════════════════════════════════════════════════════
class ReportsApi {
  /// POST /api/reports
  /// type: booking_dispute | listing_issue | payment_issue | fraud | other
  /// Backend field: 'subject' (not 'title')
  static Future<Map<String, dynamic>> create({
    required String type,
    required String subject,   // maps to backend 'subject' field
    required String description,
    String? bookingId,
    String? listingId,
  }) async {
    return ApiClient.post('/reports', body: {
      'type': type,
      'subject': subject,
      'description': description,
      if (bookingId != null) 'booking_id': bookingId,
      if (listingId != null) 'listing_id': listingId,
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ADMIN  —  /api/admin/*
//  All methods use POST (not PUT) to match Laravel routes
// ═══════════════════════════════════════════════════════════════════════════
class AdminApi {
  // ── Stats ──
  /// GET /api/admin/stats
  static Future<Map<String, dynamic>> getStats() async {
    return ApiClient.get('/admin/stats');
  }

  // ── Users ──
  /// GET /api/admin/users
  static Future<Map<String, dynamic>> getUsers({int page = 1}) async {
    return ApiClient.get('/admin/users',
        query: {'page': page.toString()});
  }

  /// POST /api/admin/users/:id/verify  (toggles verified_at)
  static Future<Map<String, dynamic>> toggleVerify(String userId) async {
    return ApiClient.post('/admin/users/$userId/verify');
  }

  /// POST /api/admin/users/:id/role
  /// role: user | moderator | admin
  static Future<void> setRole(String userId, String role) async {
    await ApiClient.post('/admin/users/$userId/role', body: {'role': role});
  }

  /// POST /api/admin/users/:id/suspend  (toggles suspension)
  static Future<Map<String, dynamic>> toggleSuspend(String userId) async {
    return ApiClient.post('/admin/users/$userId/suspend');
  }

  // ── Listings ──
  /// GET /api/admin/listings  (all, with pagination)
  static Future<Map<String, dynamic>> getListings({int page = 1}) async {
    return ApiClient.get('/admin/listings',
        query: {'page': page.toString()});
  }

  /// POST /api/admin/listings/:id/approve
  static Future<void> approveListing(String id) async {
    await ApiClient.post('/admin/listings/$id/approve');
  }

  /// POST /api/admin/listings/:id/reject
  static Future<void> rejectListing(String id, {String? reason}) async {
    await ApiClient.post('/admin/listings/$id/reject',
        body: {if (reason != null) 'reason': reason});
  }

  // ── Bookings ──
  /// GET /api/admin/bookings
  static Future<Map<String, dynamic>> getBookings({int page = 1}) async {
    return ApiClient.get('/admin/bookings',
        query: {'page': page.toString()});
  }

  /// POST /api/admin/bookings/:id/cancel
  static Future<void> cancelBooking(String id) async {
    await ApiClient.post('/admin/bookings/$id/cancel');
  }

  /// POST /api/admin/bookings/:id/refund
  static Future<void> refundBooking(String id) async {
    await ApiClient.post('/admin/bookings/$id/refund');
  }

  // ── Reports ──
  /// GET /api/admin/reports
  static Future<Map<String, dynamic>> getReports({int page = 1}) async {
    return ApiClient.get('/admin/reports',
        query: {'page': page.toString()});
  }

  /// GET /api/admin/payouts
  static Future<Map<String, dynamic>> getPayouts({int page = 1}) async {
    return ApiClient.get('/admin/payouts',
        query: {'page': page.toString()});
  }

  /// POST /api/admin/reports/:id/status
  /// status: under_review | resolved | rejected
  /// Backend field: 'admin_note' (not 'note')
  static Future<void> updateReportStatus(String id, String status,
      {String? adminNote}) async {
    await ApiClient.post('/admin/reports/$id/status', body: {
      'status': status,
      if (adminNote != null) 'admin_note': adminNote,
    });
  }
}
