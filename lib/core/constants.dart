class AppConstants {
  // App info
  static const String appName = 'PakRentals';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Rent Anything in Pakistan';

  // API
  static const String apiBaseUrl = 'https://api.pakrentals.pk/v1';
  static const String imageBaseUrl = 'https://cdn.pakrentals.pk';

  // Commission
  static const double platformCommissionPercent = 10.0;
  static const double deliveryFeeFlat = 500.0;

  // Pagination
  static const int pageSize = 20;

  // Payment gateways
  static const String gatewayJazzCash = 'jazzcash';
  static const String gatewayEasyPaisa = 'easypaisa';
  static const String gatewayBankTransfer = 'bank_transfer';

  // Booking statuses
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingCancelled = 'cancelled';
  static const String bookingCompleted = 'completed';

  // Listing statuses
  static const String listingDraft = 'draft';
  static const String listingPending = 'pending';
  static const String listingActive = 'active';
  static const String listingRejected = 'rejected';

  // User roles
  static const String roleRenter = 'renter';
  static const String roleHost = 'host';
  static const String roleAdmin = 'admin';

  // Report types
  static const String reportFraud = 'fraud';
  static const String reportMisleading = 'misleading';
  static const String reportInappropriate = 'inappropriate';
  static const String reportDispute = 'dispute';

  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyOnboarded = 'onboarded';
}
