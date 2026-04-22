import '../models/booking.dart';

/// Booking service — replace with real HTTP calls when backend is ready.
class BookingService {
  /// Get bookings for the current user.
  static Future<List<Booking>> getMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SampleBookings.myBookings;
  }

  /// Get incoming booking requests for a host.
  static Future<List<Booking>> getHostRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SampleBookings.myBookings;
  }

  /// Create a new booking.
  static Future<String?> createBooking({
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required String paymentGateway,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return 'PKR-2026-${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  /// Cancel a booking.
  static Future<bool> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  /// Admin: cancel and refund.
  static Future<bool> adminCancelRefund(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
