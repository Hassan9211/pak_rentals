import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/user_state.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _tehsilCtrl  = TextEditingController();
  final _cnicCtrl    = TextEditingController();

  String _role = 'renter';
  bool _obscure        = true;
  bool _obscureConfirm = true;
  bool _agreed         = false;
  bool _loading        = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _cityCtrl.dispose();
    _tehsilCtrl.dispose();
    _cnicCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      _showError('Please agree to the Terms of Service to continue.');
      return;
    }
    setState(() => _loading = true);

    try {
      final res = await AuthApi.register(
        name:    _nameCtrl.text.trim(),
        email:   _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        phone:   _phoneCtrl.text.trim(),
        city:    _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        tehsil:  _tehsilCtrl.text.trim().isEmpty ? null : _tehsilCtrl.text.trim(),
        cnic:    _cnicCtrl.text.trim().isEmpty ? null : _cnicCtrl.text.trim(),
      );

      if (!mounted) return;

      final user  = AuthApi.extractUser(res);
      final name  = user?['name']  as String? ?? _nameCtrl.text.trim();
      final email = user?['email'] as String? ?? _emailCtrl.text.trim();
      final phone = user?['phone'] as String? ?? _phoneCtrl.text.trim();
      final roles = user?['roles'] as List?;
      final role  = roles?.isNotEmpty == true
          ? (roles!.first['name'] as String? ?? 'user')
          : 'user';

      await UserState().setUser(name: name, email: email, phone: phone, role: role);
      UserState().setStats(bookings: 0, saved: 0, unread: 0, rating: 0.0, reviews: 0);
      await UserState().setCnicVerified(false);
      await UserState().updatePaymentMethod('');

      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final emailErr = e.fieldError('email');
      final passErr  = e.fieldError('password');
      _showError(emailErr ?? passErr ?? e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Connection failed. Check your internet and try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.bgInput,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const AppLogo(fontSize: 20),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Create account',
                    style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Join PakRentals today',
                    style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 24),

                // ── Role ──
                _label('I want to'),
                const SizedBox(height: 8),
                Row(children: [
                  _roleBtn('renter', '🔍 Rent items'),
                  const SizedBox(width: 10),
                  _roleBtn('host', '🏠 List items'),
                ]),
                const SizedBox(height: 20),

                // ── Personal Info ──
                _sectionHeader('Personal Information'),
                const SizedBox(height: 12),

                _label('Full Name *'),
                const SizedBox(height: 6),
                _field(
                  controller: _nameCtrl,
                  hint: 'Ahmed Khan',
                  icon: '👤',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Full name is required';
                    if (v.trim().length < 3) return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _label('Phone Number *'),
                const SizedBox(height: 6),
                _field(
                  controller: _phoneCtrl,
                  hint: '03001234567',
                  icon: '📱',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return 'Enter a valid Pakistani phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _label('CNIC Number'),
                const SizedBox(height: 6),
                _field(
                  controller: _cnicCtrl,
                  hint: '12345-1234567-1',
                  icon: '🪪',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length != 13) return 'CNIC must be 13 digits (e.g. 12345-1234567-1)';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Location ──
                _sectionHeader('Location'),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('City *'),
                        const SizedBox(height: 6),
                        _field(
                          controller: _cityCtrl,
                          hint: 'Bahawalpur',
                          icon: '🏙️',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'City is required';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Tehsil'),
                        const SizedBox(height: 6),
                        _field(
                          controller: _tehsilCtrl,
                          hint: 'Bahawalpur City',
                          icon: '📍',
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Account ──
                _sectionHeader('Account Details'),
                const SizedBox(height: 12),

                _label('Email Address *'),
                const SizedBox(height: 6),
                _field(
                  controller: _emailCtrl,
                  hint: 'ahmed@example.com',
                  icon: '📧',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _label('Password *'),
                const SizedBox(height: 6),
                _passwordField(
                  controller: _passCtrl,
                  hint: '••••••••',
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Must contain a letter';
                    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain a number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _label('Confirm Password *'),
                const SizedBox(height: 6),
                _passwordField(
                  controller: _confirmCtrl,
                  hint: '••••••••',
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Terms ──
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18, height: 18,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: _agreed ? AppColors.cyan.withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _agreed ? AppColors.cyan : AppColors.borderLight,
                            width: 0.5,
                          ),
                        ),
                        child: _agreed
                            ? const Center(child: Text('✓', style: TextStyle(fontSize: 11, color: AppColors.cyan)))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(text: 'Terms of Service',
                                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy',
                                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                _loading ? _loadingBtn() : GradientButton(label: 'Create Account', onTap: _submit),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text('Sign In',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppColors.cyan, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(title,
            style: GoogleFonts.syne(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 0.5, color: AppColors.borderLight)),
      ],
    );
  }

  Widget _roleBtn(String value, String label) {
    final isSelected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyan.withValues(alpha: 0.12) : AppColors.bgInput,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.cyan.withValues(alpha: 0.4) : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.cyan : AppColors.textSecondary)),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: _deco(hint: hint, icon: icon),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: _deco(hint: hint, icon: '🔒').copyWith(
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(obscure ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }

  InputDecoration _deco({required String hint, required String icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(icon, style: const TextStyle(fontSize: 16)),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: AppColors.bgInput,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 0.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1)),
      errorStyle: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    );
  }

  Widget _loadingBtn() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.cyan, Color(0xFF00A8CC)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 22, height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
        ),
      ),
    );
  }
}
