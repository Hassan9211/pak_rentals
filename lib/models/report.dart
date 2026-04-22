class Report {
  final String id;
  final String type; // fraud | misleading | inappropriate | dispute
  final String title;
  final String description;
  final String reportedBy;
  final String reportedByInitials;
  final String? listingId;
  final String? listingTitle;
  final String? bookingId;
  final String status; // open | resolved | escalated
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Report({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reportedBy,
    required this.reportedByInitials,
    this.listingId,
    this.listingTitle,
    this.bookingId,
    required this.status,
    this.adminNote,
    required this.createdAt,
    this.resolvedAt,
  });

  String get typeLabel {
    switch (type) {
      case 'fraud':
        return 'FRAUD ALERT';
      case 'misleading':
        return 'LISTING REPORT';
      case 'dispute':
        return 'BOOKING DISPUTE';
      default:
        return 'REPORT';
    }
  }
}

class SampleReports {
  static final List<Report> open = [
    Report(
      id: 'rep1',
      type: 'dispute',
      title: 'Renter claims host cancelled last minute',
      description: 'Host cancelled booking 2 hours before check-in without refund.',
      reportedBy: 'Ahmed Khan',
      reportedByInitials: 'AK',
      listingId: '1',
      listingTitle: '3-Bed House Model Town',
      bookingId: 'PKR-2026-00847',
      status: 'open',
      createdAt: DateTime(2026, 4, 18),
    ),
    Report(
      id: 'rep2',
      type: 'fraud',
      title: 'Suspicious payment activity on booking #PKR-248',
      description: 'Multiple failed payment attempts from different numbers.',
      reportedBy: 'System',
      reportedByInitials: 'SY',
      bookingId: 'PKR-2026-00248',
      status: 'open',
      createdAt: DateTime(2026, 4, 19),
    ),
    Report(
      id: 'rep3',
      type: 'misleading',
      title: 'Misleading photos — property looks different',
      description: 'Photos show a different property. Actual condition is much worse.',
      reportedBy: 'Fatima Bibi',
      reportedByInitials: 'FB',
      listingId: '3',
      listingTitle: 'Bridal Lehenga Set',
      status: 'open',
      createdAt: DateTime(2026, 4, 17),
    ),
  ];
}
