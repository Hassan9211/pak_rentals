class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // renter | host | admin
  final String initials;
  final bool cnicVerified;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final int totalBookings;
  final int totalListings;
  final double avgRating;
  final String? profileImageUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.initials,
    this.cnicVerified = false,
    this.verifiedAt,
    required this.createdAt,
    this.totalBookings = 0,
    this.totalListings = 0,
    this.avgRating = 0.0,
    this.profileImageUrl,
  });

  bool get isHost => role == 'host' || role == 'admin';
  bool get isAdmin => role == 'admin';

  AppUser copyWith({
    String? name,
    String? phone,
    bool? cnicVerified,
    DateTime? verifiedAt,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      initials: initials,
      cnicVerified: cnicVerified ?? this.cnicVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt,
      totalBookings: totalBookings,
      totalListings: totalListings,
      avgRating: avgRating,
      profileImageUrl: profileImageUrl,
    );
  }
}

// Sample users
class SampleUsers {
  static final AppUser currentUser = AppUser(
    id: 'u1',
    name: 'Ahmed Khan',
    email: 'ahmed.k@gmail.com',
    phone: '0300-1234567',
    role: 'host',
    initials: 'AK',
    cnicVerified: true,
    verifiedAt: DateTime(2024, 1, 15),
    createdAt: DateTime(2024, 1, 10),
    totalBookings: 23,
    totalListings: 4,
    avgRating: 4.8,
  );

  static final List<AppUser> adminList = [
    AppUser(
      id: 'u2',
      name: 'Muhammad Zohaib',
      email: 'zohabanwr63@gmail.com',
      phone: '0311-0000000',
      role: 'host',
      initials: 'MZ',
      cnicVerified: false,
      createdAt: DateTime(2024, 3, 1),
      totalListings: 2,
    ),
    AppUser(
      id: 'u3',
      name: 'Fatima Bibi',
      email: 'f.bibi92@yahoo.com',
      phone: '0333-9876543',
      role: 'renter',
      initials: 'FB',
      cnicVerified: false,
      createdAt: DateTime(2024, 2, 20),
      totalBookings: 5,
    ),
    AppUser(
      id: 'u4',
      name: 'Zara Abbasi',
      email: 'zara.a@gmail.com',
      phone: '0321-1111111',
      role: 'host',
      initials: 'ZA',
      cnicVerified: false,
      createdAt: DateTime(2024, 4, 5),
      totalListings: 1,
    ),
    AppUser(
      id: 'u5',
      name: 'Usman Malik',
      email: 'usman.m@gmail.com',
      phone: '0345-2222222',
      role: 'host',
      initials: 'UM',
      cnicVerified: false,
      createdAt: DateTime(2024, 4, 10),
      totalListings: 1,
    ),
  ];
}
