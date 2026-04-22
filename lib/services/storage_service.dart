import '../core/constants.dart';

/// Storage / CDN URL builder.
/// When you integrate a real backend, replace the base URL in constants.dart.
class StorageService {
  /// Build a full image URL from a relative path stored in the DB.
  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${AppConstants.imageBaseUrl}/$path';
  }

  /// Build a thumbnail URL (assumes your CDN supports query params).
  static String thumbnailUrl(String path, {int width = 400, int height = 300}) {
    final base = imageUrl(path);
    return '$base?w=$width&h=$height&fit=cover';
  }

  /// Placeholder emoji for a category when no image is available.
  static String categoryEmoji(String slug) {
    const map = {
      'properties': '🏠',
      'vehicles': '🏍️',
      'shadi-wear': '👗',
      'electronics': '📱',
      'furniture': '🛋️',
      'others': '📦',
    };
    return map[slug] ?? '📦';
  }
}
