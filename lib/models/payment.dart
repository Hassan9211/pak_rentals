class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String gateway; // jazzcash | easypaisa | bank_transfer
  final String status; // pending | completed | failed | refunded
  final String? transactionId;
  final String? gatewayRef;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.gateway,
    required this.status,
    this.transactionId,
    this.gatewayRef,
    required this.createdAt,
    this.completedAt,
  });

  String get gatewayLabel {
    switch (gateway) {
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'EasyPaisa';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return gateway;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Pending';
    }
  }
}

class SamplePayments {
  static final List<Payment> records = [
    Payment(
      id: 'pay1',
      bookingId: 'PKR-2026-00847',
      userId: 'u3',
      amount: 8740,
      gateway: 'jazzcash',
      status: 'completed',
      transactionId: 'JC-20260508-00847',
      createdAt: DateTime(2026, 4, 21),
      completedAt: DateTime(2026, 4, 21, 10, 45),
    ),
    Payment(
      id: 'pay2',
      bookingId: 'PKR-2026-00612',
      userId: 'u5',
      amount: 1760,
      gateway: 'easypaisa',
      status: 'completed',
      transactionId: 'EP-20260410-00612',
      createdAt: DateTime(2026, 4, 9),
      completedAt: DateTime(2026, 4, 9, 14, 20),
    ),
    Payment(
      id: 'pay3',
      bookingId: 'PKR-2026-00900',
      userId: 'u2',
      amount: 22000,
      gateway: 'bank_transfer',
      status: 'pending',
      createdAt: DateTime(2026, 4, 20),
    ),
  ];
}
