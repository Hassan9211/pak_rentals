/// Auth service — wire up to your backend when ready.
/// Currently returns mock data so the UI works without a server.
class AuthService {
  static String? _token;
  static String? _userId;
  static String? _role;

  static bool get isLoggedIn => _token != null;
  static String? get userId => _userId;
  static String? get role => _role;
  static bool get isAdmin => _role == 'admin';

  /// Simulate login — replace body with real HTTP call.
  static Future<bool> login(String emailOrPhone, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Mock: any credentials succeed
    _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    _userId = 'u1';
    _role = 'host';
    return true;
  }

  /// Simulate registration.
  static Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _token = 'mock_token_new';
    _userId = 'u_new';
    _role = role;
    return true;
  }

  static Future<void> logout() async {
    _token = null;
    _userId = null;
    _role = null;
  }

  static Future<bool> sendPasswordReset(String emailOrPhone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
