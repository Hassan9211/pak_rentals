class Category {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final int listingCount;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    this.listingCount = 0,
  });
}

class SampleCategories {
  static const List<Category> all = [
    Category(id: '1', name: 'Properties', slug: 'properties', icon: '🏠', listingCount: 84),
    Category(id: '2', name: 'Vehicles', slug: 'vehicles', icon: '🏍️', listingCount: 31),
    Category(id: '3', name: 'Shadi Wear', slug: 'shadi-wear', icon: '👗', listingCount: 47),
    Category(id: '4', name: 'Electronics', slug: 'electronics', icon: '📱', listingCount: 22),
    Category(id: '5', name: 'Furniture', slug: 'furniture', icon: '🛋️', listingCount: 18),
    Category(id: '6', name: 'Others', slug: 'others', icon: '📦', listingCount: 15),
  ];
}
