import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/user_state.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // ── Call real backend API ──
      final res = await AuthApi.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (!mounted) return;

      // Extract user from response
      final user = AuthApi.extractUser(res);
      final name = user?['name'] as String? ?? _emailCtrl.text.trim();
      final email = user?['email'] as String? ?? _emailCtrl.text.trim();
      final phone = user?['phone'] as String? ?? '';
      final roles = user?['roles'] as List?;
      final role = roles?.isNotEmpty == true
          ? (roles!.first['name'] as String? ?? 'user')
          : 'user';

      // Save to local state
      await UserState().setUser(
        name: name,
        email: email,
        phone: phone,
        role: role,
      );

      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final emailErr = e.fieldError('email');
      _showError(emailErr ?? e.message);
    } catch (e) {
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
                const SizedBox(height: 32),
                const Center(child: AppLogo(fontSize: 26)),
                const SizedBox(height: 40),
                Text(
                  'Welcome back',
                  style: GoogleFonts.syne(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in to continue',
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 32),
                _label('Email / Phone'),
                const SizedBox(height: 6),
                _inputField(
                  controller: _emailCtrl,
                  hint: 'ahmed@example.com',
                  icon: '📧',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email or phone is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Password'),
                const SizedBox(height: 6),
                _passwordField(),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _loading
                    ? _loadingBtn()
                    : GradientButton(label: 'Sign In', onTap: _submit),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _divider(),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight, width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        'Continue as Guest',
                        style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Admin quick-fill
                GestureDetector(
                  onTap: () {
                    _emailCtrl.text = 'admin@pakrentals.pk';
                    _passCtrl.text = 'admin123';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.purple.withValues(alpha: 0.2), width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded,
                            color: AppColors.purple, size: 14),
                        const SizedBox(width: 6),
                        Text('Tap to fill Admin credentials',
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.purple)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
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
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        errorStyle: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: _obscure,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('🔒', style: TextStyle(fontSize: 16)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(_obscure ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        errorStyle: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  Widget _loadingBtn() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cyan, Color(0xFF00A8CC)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}
