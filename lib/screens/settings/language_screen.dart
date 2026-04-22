import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/user_state.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = '';

  final List<Map<String, String>> _languages = [
    {'code': 'English', 'label': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'code': 'Urdu', 'label': 'Urdu', 'native': 'اردو', 'flag': '🇵🇰'},
    {'code': 'Punjabi', 'label': 'Punjabi', 'native': 'پنجابی', 'flag': '🇵🇰'},
    {'code': 'Sindhi', 'label': 'Sindhi', 'native': 'سنڌي', 'flag': '🇵🇰'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = UserState().language;
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
                  Text('Choose your preferred language',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 14),
                  ..._languages.map((lang) {
                    final isSelected = _selected == lang['code'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selected = lang['code']!);
                        UserState().setLanguage(lang['code']!);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.cyan.withValues(alpha: 0.08) : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.cyan.withValues(alpha: 0.4) : AppColors.borderLight,
                            width: isSelected ? 1 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lang['label']!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? AppColors.cyan : AppColors.textPrimary,
                                      )),
                                  Text(lang['native']!,
                                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppColors.cyan, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
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
          Text('Language', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
