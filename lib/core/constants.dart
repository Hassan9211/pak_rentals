class AppConstants {
  // ── App info ──────────────────────────────────────────────────────────
  static const String appName = 'PakRentals';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Rent Anything in Pakistan';

  // ── API ───────────────────────────────────────────────────────────────
  // Local development — Laravel running with --host=0.0.0.0 --port=8000
  // Physical device / emulator on same Wi-Fi uses the PC's LAN IP
  static const String apiBaseUrl = 'http://192.168.2.102:8000/api';

  // Production URL — swap before release
  // static const String apiBaseUrl = 'https://your-domain.com/api';

  // Android emulator (maps to host loopback)
  // static const String apiBaseUrl = 'http://10.0.2.2:8000/api';

  // Storage base — Laravel public disk
  // Listing images and handover photos are stored as relative paths.
  // Full URL = storageBaseUrl + "/" + path
  // e.g. "listings/abc.jpg" → "http://192.168.2.102:8000/storage/listings/abc.jpg"
  static const String storageBaseUrl = 'http://192.168.2.102:8000/storage';
  // Production: static const String storageBaseUrl = 'https://your-domain.com/storage';

  // ── Commission ────────────────────────────────────────────────────────
  static const double platformCommissionPercent = 12.0; // backend uses 12%
  static const double deliveryFeeFlat = 0.0;            // backend sets to 0

  // ── Pagination ────────────────────────────────────────────────────────
  static const int pageSize = 20;

  // ── Payment gateways — must match Laravel 'in' validation ─────────────
  static const String gatewayJazzCash     = 'jazzcash';
  static const String gatewayEasyPaisa    = 'easypaisa';
  static const String gatewayBankTransfer = 'bank-transfer'; // note: hyphen not underscore

  // ── Booking statuses — must match Laravel backend ─────────────────────
  static const String bookingPending   = 'pending';
  static const String bookingApproved  = 'approved';
  static const String bookingActive    = 'active';
  static const String bookingCompleted = 'completed';
  static const String bookingRejected  = 'rejected';
  static const String bookingCancelled = 'cancelled';

  // ── Payment statuses ──────────────────────────────────────────────────
  static const String paymentPending  = 'pending';
  static const String paymentPaid     = 'paid';
  static const String paymentFailed   = 'failed';
  static const String paymentRefunded = 'refunded';

  // ── Listing statuses ──────────────────────────────────────────────────
  static const String listingPending  = 'pending';
  static const String listingApproved = 'approved';
  static const String listingRejected = 'rejected';
  static const String listingDraft    = 'draft';
  static const String listingInactive = 'inactive';

  // ── Report types — must match Laravel 'in' validation ─────────────────
  static const String reportBookingDispute = 'booking_dispute';
  static const String reportListingIssue   = 'listing_issue';
  static const String reportPaymentIssue   = 'payment_issue';
  static const String reportFraud          = 'fraud';
  static const String reportOther          = 'other';

  // ── User roles ────────────────────────────────────────────────────────
  static const String roleUser      = 'user';
  static const String roleModerator = 'moderator';
  static const String roleAdmin     = 'admin';

  // ── SharedPreferences keys ────────────────────────────────────────────
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId    = 'user_id';
  static const String keyUserRole  = 'user_role';
  static const String keyOnboarded = 'onboarded';
}
