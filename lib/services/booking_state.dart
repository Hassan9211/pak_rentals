import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../core/constants.dart';

/// Booking flow ka global state — listing se payment tak sab data yahan hai.
class BookingState extends ChangeNotifier {
  static final BookingState _instance = BookingState._internal();
  factory BookingState() => _instance;
  BookingState._internal();

  Listing? _listing;
  DateTime? _checkIn;
  DateTime? _checkOut;
  String _paymentMethod = 'JazzCash';
  String _paymentPhone = '';

  // ── Getters ──
  Listing? get listing => _listing;
  DateTime? get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  String get paymentMethod => _paymentMethod;
  String get paymentPhone => _paymentPhone;

  /// Number of days/nights between check-in and check-out
  int get nights {
    if (_checkIn == null || _checkOut == null) return 1;
    return _checkOut!.difference(_checkIn!).inDays.clamp(1, 365);
  }

  /// Parse listing price string → double (handles "25,000", "800", "15K", "25K")
  double get pricePerUnit {
    if (_listing == null) return 0;
    final raw = _listing!.price.replaceAll(',', '').replaceAll(' ', '');
    if (raw.toUpperCase().endsWith('K')) {
      return (double.tryParse(raw.substring(0, raw.length - 1)) ?? 0) * 1000;
    }
    return double.tryParse(raw) ?? 0;
  }

  /// Base amount = price × nights
  double get baseAmount => pricePerUnit * nights;

  /// Platform fee = 10% of base
  double get platformFee => baseAmount * (AppConstants.platformCommissionPercent / 100);

  /// Weekly discount — apply if 7+ days
  double get weeklyDiscount {
    if (nights >= 7) return (baseAmount * 0.06).roundToDouble(); // 6% discount
    return 0;
  }

  /// Total = base + fee - discount
  double get total => baseAmount + platformFee - weeklyDiscount;

  /// Formatted price unit label
  String get priceUnitLabel {
    if (_listing == null) return '';
    return _listing!.priceUnit; // '/day', '/mo', '/event'
  }

  /// Unit label for breakdown row
  String get unitLabel {
    if (_listing == null) return 'days';
    final u = _listing!.priceUnit.toLowerCase();
    if (u.contains('mo')) return nights == 1 ? 'month' : 'months';
    if (u.contains('event')) return nights == 1 ? 'event' : 'events';
    return nights == 1 ? 'day' : 'days';
  }

  /// Formatted PKR string
  String fmt(double v) {
    final s = v.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write(',');
      result.write(s[i]);
      count++;
    }
    return 'PKR ${result.toString().split('').reversed.join()}';
  }

  String get paymentMethodLabel {
    switch (_paymentMethod) {
      case 'EasyPaisa': return 'EasyPaisa';
      case 'Bank Transfer': return 'Bank Transfer';
      default: return 'JazzCash';
    }
  }

  // ── Setters ──

  void setListing(Listing listing) {
    _listing = listing;
    // Default dates: today → today+1
    _checkIn = DateTime.now();
    _checkOut = DateTime.now().add(const Duration(days: 1));
    notifyListeners();
  }

  void setDates(DateTime checkIn, DateTime checkOut) {
    _checkIn = checkIn;
    _checkOut = checkOut;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setPaymentPhone(String phone) {
    _paymentPhone = phone;
    notifyListeners();
  }

  void clear() {
    _listing = null;
    _checkIn = null;
    _checkOut = null;
    _paymentMethod = 'JazzCash';
    _paymentPhone = '';
    notifyListeners();
  }
}
