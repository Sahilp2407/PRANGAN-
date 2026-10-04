import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/society_provider.dart';
import '../services/seed_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_crest.dart';
import 'auth/welcome_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'society/pending_approval_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Seed demo Kharghar society data in Firestore if empty
    final seedService = SeedService();
    await seedService.seedKhargharDataIfEmpty().catchError((e) {
      debugPrint('Seed note: $e');
    });

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      final user = authProvider.userModel;
      if (user != null && user.societyId != null && user.societyId!.isNotEmpty) {
        societyProvider.loadSociety(user.societyId!);

        if (user.isApproved || user.isAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          return;
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          );
          return;
        }
      }
    }

    // Default to Welcome Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background ambient gradient circles
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryLight.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldLight.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Center branding
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppCrest(size: 96),
                        const SizedBox(height: 26),
                        Text(
                          'प्रांगण',
                          style: GoogleFonts.rozhaOne(
                            fontSize: 38,
                            color: AppTheme.primaryCrimson,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'PRANGAN',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.0,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.goldLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Kharghar, Navi Mumbai',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.goldDark,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Residential Society Network',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryCrimson),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connecting Kharghar Residents...',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textSubtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
