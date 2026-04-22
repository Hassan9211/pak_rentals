import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/common/gradient_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              if (!_sent) ...[
                Text('Reset Password', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number or email and we\'ll send you a reset link.',
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted, height: 1.5),
                ),
                const SizedBox(height: 32),
                Text('Phone / Email', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text('📱', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '0300-1234567 or email',
                            hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: 'Send Reset Link',
                  onTap: () => setState(() => _sent = true),
                ),
              ] else ...[
                const Center(child: Text('✅', style: TextStyle(fontSize: 56))),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Link Sent!',
                    style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Check your phone or email for the password reset link.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted, height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Back to Sign In',
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
