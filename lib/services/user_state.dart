import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global user state — poori app ka central state.
/// Login/Register ke baad data SharedPreferences mein save hota hai.
/// App restart pe automatically restore hota hai.
class UserState extends ChangeNotifier {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;
  UserState._internal();

  // ── SharedPreferences keys ──
  static const _kName = 'user_name';
  static const _kEmail = 'user_email';
  static const _kPhone = 'user_phone';
  static const _kRole = 'user_role';
  static const _kLoggedIn = 'user_logged_in';
  static const _kJoinedAt = 'user_joined_at';
  static const _kCnicVerified = 'user_cnic_verified';
  static const _kPaymentMethod = 'user_payment_method';
  static const _kNotifications = 'user_notifications';
  static const _kLanguage = 'user_language';
  static const _kProfilePhoto = 'user_profile_photo';

  // ── Core identity ──
  String _name = 'Guest';
  String _email = '';
  String _phone = '';
  String _role = 'renter';
  bool _isLoggedIn = false;
  DateTime? _joinedAt;
  String _profilePhotoPath = ''; // local file path

  // ── Verification ──
  bool _cnicVerified = false;

  // ── Stats ──
  int _totalBookings = 0;
  int _savedCount = 0;
  int _unreadMessages = 0;
  double _avgRating = 0.0;
  int _totalReviews = 0;

  // ── Settings ──
  bool _notificationsEnabled = true;
  String _language = 'English';
  String _paymentMethod = '';

  // ── Getters ──
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  DateTime? get joinedAt => _joinedAt;
  bool get cnicVerified => _cnicVerified;
  int get totalBookings => _totalBookings;
  int get savedCount => _savedCount;
  int get unreadMessages => _unreadMessages;
  double get avgRating => _avgRating;
  int get totalReviews => _totalReviews;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  String get paymentMethod => _paymentMethod;

  bool get isHost => _role == 'host' || _role == 'admin';
  bool get isAdmin => _role == 'admin';

  String get roleLabel {
    switch (_role) {
      case 'host': return 'Host';
      case 'admin': return 'Admin';
      default: return 'Renter';
    }
  }

  String get initials {
    if (_name == 'Guest') return 'G';
    final parts = _name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String get firstName {
    if (_name == 'Guest') return 'Guest';
    final parts = _name.trim().split(' ');
    return parts.isEmpty ? 'User' : parts[0];
  }

  String get joinDateLabel {
    final d = _joinedAt ?? DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }

  String get bookingsLabel =>
      _totalBookings == 0 ? 'None yet' : '$_totalBookings total';
  String get savedLabel =>
      _savedCount == 0 ? 'None saved' : '$_savedCount saved';
  String get messagesLabel =>
      _unreadMessages == 0 ? 'No new' : '$_unreadMessages unread';
  String get reviewsLabel =>
      _totalReviews == 0 ? 'No reviews' : '${_avgRating.toStringAsFixed(1)} avg';
  String get paymentLabel =>
      _paymentMethod.isEmpty ? 'Not set' : _paymentMethod;
  String get profilePhotoPath => _profilePhotoPath;

  // ── Load from storage on app start ──
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_kLoggedIn) ?? false;
    if (!loggedIn) return; // not logged in — stay on splash

    _isLoggedIn = true;
    _name = prefs.getString(_kName) ?? 'User';
    _email = prefs.getString(_kEmail) ?? '';
    _phone = prefs.getString(_kPhone) ?? '';
    _role = prefs.getString(_kRole) ?? 'renter';
    _cnicVerified = prefs.getBool(_kCnicVerified) ?? false;
    _paymentMethod = prefs.getString(_kPaymentMethod) ?? '';
    _notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
    _language = prefs.getString(_kLanguage) ?? 'English';
    _profilePhotoPath = prefs.getString(_kProfilePhoto) ?? '';

    final joinedMs = prefs.getInt(_kJoinedAt);
    if (joinedMs != null) {
      _joinedAt = DateTime.fromMillisecondsSinceEpoch(joinedMs);
    }

    notifyListeners();
  }

  // ── Save to storage ──
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, _isLoggedIn);
    await prefs.setString(_kName, _name);
    await prefs.setString(_kEmail, _email);
    await prefs.setString(_kPhone, _phone);
    await prefs.setString(_kRole, _role);
    await prefs.setBool(_kCnicVerified, _cnicVerified);
    await prefs.setString(_kPaymentMethod, _paymentMethod);
    await prefs.setBool(_kNotifications, _notificationsEnabled);
    await prefs.setString(_kLanguage, _language);
    await prefs.setString(_kProfilePhoto, _profilePhotoPath);
    if (_joinedAt != null) {
      await prefs.setInt(_kJoinedAt, _joinedAt!.millisecondsSinceEpoch);
    }
  }

  // ── Setters ──

  Future<void> setUser({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    _name = name;
    _email = email;
    _phone = phone;
    _role = role;
    _isLoggedIn = true;
    _joinedAt = DateTime.now();
    notifyListeners();
    await _save();
  }

  Future<void> updateName(String name) async {
    _name = name;
    notifyListeners();
    await _save();
  }

  Future<void> updatePhone(String phone) async {
    _phone = phone;
    notifyListeners();
    await _save();
  }

  Future<void> updateProfilePhoto(String path) async {
    _profilePhotoPath = path;
    notifyListeners();
    await _save();
  }

  Future<void> updatePaymentMethod(String method) async {
    _paymentMethod = method;
    notifyListeners();
    await _save();
  }

  Future<void> setCnicVerified(bool verified) async {
    _cnicVerified = verified;
    notifyListeners();
    await _save();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    await _save();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    await _save();
  }

  void incrementBookings() {
    _totalBookings++;
    notifyListeners();
  }

  void setSavedCount(int count) {
    _savedCount = count;
    notifyListeners();
  }

  void setUnreadMessages(int count) {
    _unreadMessages = count;
    notifyListeners();
  }

  void setStats({
    int? bookings,
    int? saved,
    int? unread,
    double? rating,
    int? reviews,
  }) {
    if (bookings != null) _totalBookings = bookings;
    if (saved != null) _savedCount = saved;
    if (unread != null) _unreadMessages = unread;
    if (rating != null) _avgRating = rating;
    if (reviews != null) _totalReviews = reviews;
    notifyListeners();
  }

  Future<void> logout() async {
    _name = 'Guest';
    _email = '';
    _phone = '';
    _role = 'renter';
    _isLoggedIn = false;
    _joinedAt = null;
    _cnicVerified = false;
    _totalBookings = 0;
    _savedCount = 0;
    _unreadMessages = 0;
    _avgRating = 0.0;
    _totalReviews = 0;
    _notificationsEnabled = true;
    _language = 'English';
    _paymentMethod = '';
    _profilePhotoPath = '';
    notifyListeners();

    // Clear storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
