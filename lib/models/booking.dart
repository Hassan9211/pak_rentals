class Booking {
  final String id;
  final String listingId;
  final String listingTitle;
  final String listingEmoji;
  final String hostId;
  final String hostName;
  final String renterId;
  final String renterName;
  final DateTime checkIn;
  final DateTime checkOut;
  final double baseAmount;
  final double platformFee;
  final double discount;
  final double totalAmount;
  final String status; // pending | confirmed | cancelled | completed
  final String paymentStatus; // unpaid | paid | refunded
  final String paymentGateway;
  final String? transactionId;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingEmoji,
    required this.hostId,
    required this.hostName,
    required this.renterId,
    required this.renterName,
    required this.checkIn,
    required this.checkOut,
    required this.baseAmount,
    required this.platformFee,
    this.discount = 0,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentGateway,
    this.transactionId,
    required this.createdAt,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }
}

class SampleBookings {
  static final List<Booking> myBookings = [
    Booking(
      id: 'PKR-2026-00847',
      listingId: '1',
      listingTitle: '3-Bed House – Model Town',
      listingEmoji: '🏠',
      hostId: 'u1',
      hostName: 'Ahmed Khan',
      renterId: 'u3',
      renterName: 'Fatima Bibi',
      checkIn: DateTime(2026, 5, 8),
      checkOut: DateTime(2026, 5, 14),
      baseAmount: 8400,
      platformFee: 840,
      discount: 500,
      totalAmount: 8740,
      status: 'confirmed',
      paymentStatus: 'paid',
      paymentGateway: 'jazzcash',
      transactionId: 'JC-20260508-00847',
      createdAt: DateTime(2026, 4, 21),
    ),
    Booking(
      id: 'PKR-2026-00612',
      listingId: '2',
      listingTitle: 'Honda CD-70 Daily Rent',
      listingEmoji: '🏍️',
      hostId: 'u1',
      hostName: 'Ahmed Khan',
      renterId: 'u5',
      renterName: 'Usman Malik',
      checkIn: DateTime(2026, 4, 10),
      checkOut: DateTime(2026, 4, 12),
      baseAmount: 1600,
      platformFee: 160,
      totalAmount: 1760,
      status: 'completed',
      paymentStatus: 'paid',
      paymentGateway: 'easypaisa',
      createdAt: DateTime(2026, 4, 9),
    ),
  ];
}
