import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/user_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──
  late final AnimationController _logoCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _particleCtrl;

  // ── Logo animations ──
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;

  // ── Buttons (only for guests) ──
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  // ── Glow pulse ──
  late final Animation<double> _glowScale;

  // ── Particles ──
  late final Animation<double> _particleAnim;

  // Whether to show auth buttons (false = logged in user)
  bool _showButtons = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _isLoggedIn = UserState().isLoggedIn;

    // Logo — 1.2s
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // Buttons — 800ms
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // Glow — loops
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    // Particles — loops
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _logoSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _logoCtrl, curve: Curves.easeOutCubic));

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn));

    _contentSlide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _contentCtrl, curve: Curves.easeOutCubic));

    _glowScale = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _particleAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_particleCtrl);

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Play logo animation
    await _logoCtrl.forward();
    if (!mounted) return;

    if (_isLoggedIn) {
      // ── Logged in: show logo for 1s then go to home ──
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // ── Guest: wait 800ms then show auth buttons ──
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _showButtons = true);
      _contentCtrl.forward();
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0D14),
                  Color(0xFF0C1020),
                  Color(0xFF071520),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Ambient glow top-right ──
          Positioned(
            top: -60, right: -60,
            child: AnimatedBuilder(
              animation: _glowScale,
              builder: (_, __) => Transform.scale(
                scale: _glowScale.value,
                child: Container(
                  width: 260, height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withValues(alpha: 0.12),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Ambient glow bottom-left ──
          Positioned(
            bottom: -40, left: -40,
            child: AnimatedBuilder(
              animation: _glowScale,
              builder: (_, __) => Transform.scale(
                scale: 1.2 - (_glowScale.value - 0.85) * 0.5,
                child: Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.cyan.withValues(alpha: 0.08),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Floating particles ──
          AnimatedBuilder(
            animation: _particleAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(_particleAnim.value),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Logo ──
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _logoOpacity,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Column(
                            children: [
                              // Icon with glow ring
                              AnimatedBuilder(
                                animation: _glowScale,
                                builder: (_, __) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: _glowScale.value,
                                      child: Container(
                                        width: 110, height: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(colors: [
                                            AppColors.cyan.withValues(alpha: 0.18),
                                            Colors.transparent,
                                          ]),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.cyan.withValues(alpha: 0.2),
                                            AppColors.purple.withValues(alpha: 0.15),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: AppColors.cyan.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.cyan.withValues(alpha: 0.2),
                                            blurRadius: 24,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text('🏠', style: TextStyle(fontSize: 36)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // App name
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: 'Pak',
                                    style: GoogleFonts.syne(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Rentals',
                                    style: GoogleFonts.syne(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.cyan,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                'Rent Anything in Pakistan',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Category pills
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: ['🏠 Homes', '🏍️ Bikes', '👗 Shadi Wear']
                                    .map((label) => Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.bgCard,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                                color: AppColors.borderLight, width: 0.5),
                                          ),
                                          child: Text(label,
                                              style: GoogleFonts.dmSans(
                                                  fontSize: 11,
                                                  color: AppColors.textMuted)),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Auth buttons — only for guests ──
                  if (_showButtons)
                    AnimatedBuilder(
                      animation: _contentCtrl,
                      builder: (_, __) => FadeTransition(
                        opacity: _contentOpacity,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            children: [
                              _GradientButton(
                                label: 'Create Account',
                                onTap: () => Navigator.pushNamed(context, '/register'),
                              ),
                              const SizedBox(height: 12),
                              _OutlineButton(
                                label: 'Sign In',
                                onTap: () => Navigator.pushNamed(context, '/login'),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/home'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Continue as Guest',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13, color: AppColors.textMuted)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 11, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Placeholder height while animating / logged-in loading
                    SizedBox(
                      height: _isLoggedIn ? 40 : 180,
                      child: _isLoggedIn
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(AppColors.cyan),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Welcome back, ${UserState().firstName}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13, color: AppColors.textMuted)),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient CTA button ──
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.cyan, Color(0xFF00B8D9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.2)),
        ),
      ),
    );
  }
}

// ── Outline button ──
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.cyan.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35), width: 1),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cyan,
                  letterSpacing: 0.2)),
        ),
      ),
    );
  }
}

// ── Floating particles painter ──
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  static const List<_Particle> _particles = [
    _Particle(x: 0.12, y: 0.15, size: 2.5, speed: 0.6, opacity: 0.4),
    _Particle(x: 0.85, y: 0.22, size: 1.8, speed: 0.4, opacity: 0.3),
    _Particle(x: 0.25, y: 0.72, size: 3.0, speed: 0.7, opacity: 0.25),
    _Particle(x: 0.70, y: 0.65, size: 2.0, speed: 0.5, opacity: 0.35),
    _Particle(x: 0.45, y: 0.10, size: 1.5, speed: 0.8, opacity: 0.2),
    _Particle(x: 0.90, y: 0.80, size: 2.2, speed: 0.3, opacity: 0.3),
    _Particle(x: 0.05, y: 0.50, size: 1.8, speed: 0.6, opacity: 0.2),
    _Particle(x: 0.60, y: 0.90, size: 2.5, speed: 0.45, opacity: 0.25),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final phase = (progress * p.speed) % 1.0;
      final dy = -20.0 * phase;
      final opacity = p.opacity * (1.0 - phase * 0.5);
      final paint = Paint()
        ..color = AppColors.cyan.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height + dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, size, speed, opacity;
  const _Particle(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});
}
