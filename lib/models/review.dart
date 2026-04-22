class Review {
  final String id;
  final String listingId;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerInitials;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.listingId,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerInitials,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class SampleReviews {
  static final List<Review> forListing1 = [
    Review(
      id: 'r1',
      listingId: '1',
      bookingId: 'PKR-2026-00612',
      reviewerId: 'u5',
      reviewerName: 'Usman Malik',
      reviewerInitials: 'UM',
      rating: 5.0,
      comment: 'Excellent property! Very clean and exactly as described. Host was very responsive.',
      createdAt: DateTime(2026, 4, 13),
    ),
    Review(
      id: 'r2',
      listingId: '1',
      bookingId: 'PKR-2026-00500',
      reviewerId: 'u3',
      reviewerName: 'Fatima Bibi',
      reviewerInitials: 'FB',
      rating: 4.5,
      comment: 'Great location and spacious rooms. Parking was a bonus. Would rent again.',
      createdAt: DateTime(2026, 3, 20),
    ),
    Review(
      id: 'r3',
      listingId: '1',
      bookingId: 'PKR-2026-00400',
      reviewerId: 'u2',
      reviewerName: 'Muhammad Zohaib',
      reviewerInitials: 'MZ',
      rating: 4.0,
      comment: 'Good value for money. Minor maintenance issues but host fixed them quickly.',
      createdAt: DateTime(2026, 2, 10),
    ),
  ];
}
