import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_client.dart' show StorageHelper;

class Listing {
  final String id;
  final String title;
  final String location;
  final String price;
  final String priceUnit;
  final String rating;
  final int reviews;
  final String emoji;
  final Color bgColor;
  final String? badge;
  final Color? badgeColor;
  final String category;
  final String hostName;
  final String hostInitials;
  final List<String> amenities;
  final String description;
  // API extras
  final String? hostId;
  final List<String> photoUrls;
  final bool isFeatured;
  final String status;

  const Listing({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.priceUnit,
    required this.rating,
    required this.reviews,
    required this.emoji,
    required this.bgColor,
    this.badge,
    this.badgeColor,
    required this.category,
    required this.hostName,
    required this.hostInitials,
    this.amenities = const [],
    this.description = '',
    this.hostId,
    this.photoUrls = const [],
    this.isFeatured = false,
    this.status = 'active',
  });

  // ── fromJson — maps Laravel API response to Listing ──
  factory Listing.fromJson(Map<String, dynamic> json) {
    final category = _categoryName(json);
    final price = _parsePrice(json);
    final priceUnit = _parsePriceUnit(json);
    final host = json['host'] as Map<String, dynamic>?;
    final hostName = host?['name'] as String? ?? 'Host';
    final hostInitials = _initials(hostName);
    final avgRating = (json['avg_rating'] ?? json['rating'] ?? 0).toDouble();
    final reviewCount = (json['review_count'] ?? json['reviews_count'] ?? 0) as int;
    final isFeatured = json['is_featured'] == true || json['is_featured'] == 1;

    return Listing(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      location: _parseLocation(json),
      price: price,
      priceUnit: priceUnit,
      rating: avgRating > 0 ? avgRating.toStringAsFixed(1) : '0.0',
      reviews: reviewCount,
      emoji: _categoryEmoji(category),
      bgColor: _categoryBg(category),
      badge: isFeatured ? 'Featured' : null,
      category: category,
      hostName: hostName,
      hostInitials: hostInitials,
      hostId: host?['id']?.toString(),
      amenities: (json['amenities'] as List?)?.cast<String>() ?? [],
      description: json['description'] as String? ?? '',
      photoUrls: StorageHelper.urls(json['images'] as List?),
      isFeatured: isFeatured,
      status: json['status'] as String? ?? 'active',
    );
  }

  // ── Helpers ──
  static String _categoryName(Map<String, dynamic> json) {
    final cat = json['category'];
    if (cat is Map) return cat['name'] as String? ?? 'Others';
    return cat as String? ?? 'Others';
  }

  static String _parsePrice(Map<String, dynamic> json) {
    final day = json['price_per_day'];
    final week = json['price_per_week'];
    final month = json['price_per_month'];
    final val = day ?? week ?? month ?? json['price'] ?? 0;
    final double num2 = (val is int)
        ? val.toDouble()
        : (val is double)
            ? val
            : double.tryParse(val.toString()) ?? 0.0;
    if (num2 >= 1000) {
      final k = num2 / 1000;
      return k == k.truncateToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return num2.toInt().toString();
  }

  static String _parsePriceUnit(Map<String, dynamic> json) {
    if (json['price_per_day'] != null) return '/day';
    if (json['price_per_week'] != null) return '/week';
    if (json['price_per_month'] != null) return '/month';
    return json['price_unit'] as String? ?? '/day';
  }

  static String _parseLocation(Map<String, dynamic> json) {
    final city = json['location_city'] as String?;
    final tehsil = json['location_tehsil'] as String?;
    if (city != null && tehsil != null) return '$tehsil, $city';
    return city ?? json['location'] as String? ?? '';
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'H';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  static String _categoryEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'properties': return '🏠';
      case 'vehicles': return '🚗';
      case 'shadi wear': return '👗';
      case 'electronics': return '📱';
      case 'furniture': return '🛋️';
      default: return '📦';
    }
  }

  static Color _categoryBg(String cat) {
    switch (cat.toLowerCase()) {
      case 'properties': return const Color(0xFF0D1F1A);
      case 'vehicles': return const Color(0xFF0D1520);
      case 'shadi wear': return const Color(0xFF1A0D14);
      case 'electronics': return const Color(0xFF0D1428);
      default: return AppColors.bgCard;
    }
  }
}

// Sample data
class SampleData {
  static final List<Listing> featured = [
    Listing(
      id: '1',
      title: '3-Bed House – Model Town',
      location: 'Bahawalpur',
      price: '25K',
      priceUnit: '/mo',
      rating: '4.8',
      reviews: 12,
      emoji: '🏠',
      bgColor: const Color(0xFF0D1F1A),
      badge: 'Featured',
      category: 'Properties',
      hostName: 'Ahmed Khan',
      hostInitials: 'AK',
      amenities: ['3 Beds', '2 Baths', 'Parking', 'Generator'],
      description:
          'Spacious 3-bedroom house in the heart of Model Town, Bahawalpur. Fully furnished with modern amenities.',
    ),
    Listing(
      id: '2',
      title: 'Honda CD-70 Daily Rent',
      location: 'Bahawalpur',
      price: '800',
      priceUnit: '/day',
      rating: '4.6',
      reviews: 8,
      emoji: '🏍️',
      bgColor: const Color(0xFF0D1520),
      category: 'Vehicles',
      hostName: 'Usman Malik',
      hostInitials: 'UM',
    ),
  ];

  static final List<Listing> shadiFeatured = [
    Listing(
      id: '3',
      title: 'Bridal Lehenga Full Set',
      location: 'Bahawalpur',
      price: '15K',
      priceUnit: '/event',
      rating: '5.0',
      reviews: 24,
      emoji: '👗',
      bgColor: const Color(0xFF1A0D14),
      badge: 'Verified',
      badgeColor: AppColors.pink,
      category: 'Shadi Wear',
      hostName: 'Fatima Bibi',
      hostInitials: 'FB',
    ),
    Listing(
      id: '4',
      title: 'Jewelry Set – Gold Look',
      location: 'Bahawalpur',
      price: '5K',
      priceUnit: '/event',
      rating: '4.9',
      reviews: 15,
      emoji: '💍',
      bgColor: const Color(0xFF1A1408),
      category: 'Shadi Wear',
      hostName: 'Zara Abbasi',
      hostInitials: 'ZA',
    ),
  ];

  static final List<Listing> searchResults = [
    Listing(
      id: '1',
      title: '3-Bed House Portion – Model Town',
      location: 'Model Town, Bahawalpur',
      price: '25,000',
      priceUnit: '/mo',
      rating: '4.8',
      reviews: 12,
      emoji: '🏠',
      bgColor: const Color(0xFF0D1F1A),
      badge: 'Verified',
      category: 'Properties',
      hostName: 'Ahmed Khan',
      hostInitials: 'AK',
    ),
    Listing(
      id: '2',
      title: 'Honda CD-70 – Daily/Weekly',
      location: 'Bahawalpur City',
      price: '800',
      priceUnit: '/day',
      rating: '4.6',
      reviews: 8,
      emoji: '🏍️',
      bgColor: const Color(0xFF0D1520),
      category: 'Vehicles',
      hostName: 'Usman Malik',
      hostInitials: 'UM',
    ),
    Listing(
      id: '3',
      title: 'Bridal Lehenga – Red Full Package',
      location: 'Satellite Town, BWP',
      price: '15,000',
      priceUnit: '/event',
      rating: '5.0',
      reviews: 24,
      emoji: '👗',
      bgColor: const Color(0xFF1A0D14),
      badge: 'Featured',
      badgeColor: AppColors.pink,
      category: 'Shadi Wear',
      hostName: 'Fatima Bibi',
      hostInitials: 'FB',
    ),
    Listing(
      id: '4',
      title: 'Shop for Rent – Circular Road',
      location: 'Circular Road, Bahawalpur',
      price: '18,000',
      priceUnit: '/mo',
      rating: '4.4',
      reviews: 5,
      emoji: '🏢',
      bgColor: const Color(0xFF141826),
      category: 'Properties',
      hostName: 'Zara Abbasi',
      hostInitials: 'ZA',
    ),
    Listing(
      id: '5',
      title: '1-Bed Flat – Near University',
      location: 'University Road, BWP',
      price: '8,000',
      priceUnit: '/mo',
      rating: '4.2',
      reviews: 7,
      emoji: '🏠',
      bgColor: const Color(0xFF0D1F1A),
      category: 'Properties',
      hostName: 'Usman Malik',
      hostInitials: 'UM',
    ),
    Listing(
      id: '6',
      title: 'Toyota Corolla – Daily Rent',
      location: 'Bahawalpur City',
      price: '5,000',
      priceUnit: '/day',
      rating: '4.7',
      reviews: 14,
      emoji: '🚗',
      bgColor: const Color(0xFF0D1520),
      category: 'Vehicles',
      hostName: 'Ahmed Khan',
      hostInitials: 'AK',
    ),
    Listing(
      id: '7',
      title: 'Sherwani – Groom Full Set',
      location: 'Model Town, BWP',
      price: '12,000',
      priceUnit: '/event',
      rating: '4.8',
      reviews: 9,
      emoji: '🤵',
      bgColor: const Color(0xFF1A0D14),
      category: 'Shadi Wear',
      hostName: 'Zara Abbasi',
      hostInitials: 'ZA',
    ),
    Listing(
      id: '8',
      title: 'Motorcycle Suzuki GS-150',
      location: 'Satellite Town, BWP',
      price: '1,200',
      priceUnit: '/day',
      rating: '4.3',
      reviews: 6,
      emoji: '🏍️',
      bgColor: const Color(0xFF0D1520),
      category: 'Vehicles',
      hostName: 'Fatima Bibi',
      hostInitials: 'FB',
    ),
    Listing(
      id: '9',
      title: 'Jewelry & Accessories Set',
      location: 'Bahawalpur City',
      price: '5,000',
      priceUnit: '/event',
      rating: '4.9',
      reviews: 18,
      emoji: '💍',
      bgColor: const Color(0xFF1A1408),
      category: 'Shadi Wear',
      hostName: 'Ahmed Khan',
      hostInitials: 'AK',
    ),
    Listing(
      id: '10',
      title: 'Office Space – 2 Rooms',
      location: 'Circular Road, Bahawalpur',
      price: '35,000',
      priceUnit: '/mo',
      rating: '4.5',
      reviews: 3,
      emoji: '🏢',
      bgColor: const Color(0xFF141826),
      category: 'Properties',
      hostName: 'Usman Malik',
      hostInitials: 'UM',
    ),
  ];
}
