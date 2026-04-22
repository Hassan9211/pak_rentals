import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/user_state.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selected = '';

  final List<Map<String, dynamic>> _methods = [
    {'id': 'JazzCash', 'logo': 'JC', 'color': Color(0xFFE24B4A), 'sub': 'Mobile wallet · Instant'},
    {'id': 'EasyPaisa', 'logo': 'EP', 'color': Color(0xFF639922), 'sub': 'Mobile wallet · Instant'},
    {'id': 'Bank Transfer', 'logo': 'BT', 'color': Color(0xFF185FA5), 'sub': '1-2 business days'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = UserState().paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Select default payment method',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 14),
                  ..._methods.map((m) {
                    final isSelected = _selected == m['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selected = m['id'] as String);
                        UserState().updatePaymentMethod(m['id'] as String);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.cyan.withValues(alpha: 0.4) : AppColors.borderLight,
                            width: isSelected ? 1 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 24,
                              decoration: BoxDecoration(
                                color: m['color'] as Color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(m['logo'] as String,
                                    style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m['id'] as String,
                                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                  Text(m['sub'] as String,
                                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.cyan : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.cyan : AppColors.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)))
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_selected.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Text('✅', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Text('$_selected set as default',
                              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.cyan)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.bgInput, shape: BoxShape.circle, border: Border.all(color: AppColors.borderLight)),
              child: const Icon(Icons.arrow_back_ios_new, size: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text('Payment Methods', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
