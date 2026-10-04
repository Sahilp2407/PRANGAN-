import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/society_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_crest.dart';
import 'signup_screen.dart';
import '../society/join_society_screen.dart';
import '../dashboard/dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final societyProvider = Provider.of<SocietyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const AppCrest(size: 84),
              const SizedBox(height: 18),

              Text(
                'Welcome to Prangan',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A private, verified community network for residential societies across Kharghar, Navi Mumbai.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Option 1: Create Society Card
              _RoleCard(
                title: 'Create New Society',
                subtitle: 'For RWA Committee, Secretary, or Builders to register and manage their society.',
                icon: Icons.domain_add_rounded,
                isPrimary: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignUpScreen(targetFlow: 'create'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Option 2: Join Existing Society Card
              _RoleCard(
                title: 'Join Your Society',
                subtitle: 'For Flat Owners & Tenants who have a 6-character society code (e.g. PRG2026).',
                icon: Icons.group_add_rounded,
                isPrimary: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignUpScreen(targetFlow: 'join'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Divider with "or"
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR SIGN IN WITH',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSubtle,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Continue with Google Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: AppTheme.primaryCrimson),
                  label: Text(
                    'Continue with Google',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.cardBorder, width: 1.4),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final success = await authProvider.signInWithGoogle();
                    if (success && context.mounted) {
                      final societyId = authProvider.userModel?.societyId ?? 'raj_rajeshwari_sec20';
                      societyProvider.loadSociety(societyId);
                      if (authProvider.hasSociety && (authProvider.isApproved || authProvider.isAdmin)) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const DashboardScreen()),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JoinSocietyScreen()),
                        );
                      }
                    } else if (context.mounted && authProvider.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage!),
                          backgroundColor: AppTheme.alertUrgent,
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Quick Kharghar Demo Resident Login (One-click instant login)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, color: AppTheme.goldAccent),
                  label: Text(
                    'Quick Demo: Enter as Kharghar Resident',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    // Log in demo resident into Raj Rajeshwari CHS
                    final success = await authProvider.loginWithDemoPhone(
                      phoneNumber: '+919820123456',
                      name: 'Sahil Pandey',
                      flatNumber: '702',
                      block: 'Wing A',
                      role: 'Owner',
                    );
                    if (success && context.mounted) {
                      societyProvider.loadSociety('raj_rajeshwari_sec20');
                      if (authProvider.userModel?.societyId == null) {
                        await authProvider.saveProfile(
                          authProvider.userModel!.copyWith(
                            societyId: 'raj_rajeshwari_sec20',
                            status: 'approved',
                            role: 'admin',
                          ),
                        );
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'By signing in, you agree to Prangan\'s Society Bylaws & Privacy Guidelines for Kharghar Societies.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.textSubtle,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary ? AppTheme.primaryCrimson.withValues(alpha: 0.3) : AppTheme.cardBorder,
            width: isPrimary ? 1.5 : 1.0,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isPrimary ? AppTheme.primaryLight : AppTheme.goldLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isPrimary ? AppTheme.primaryCrimson : AppTheme.goldDark,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? AppTheme.primaryCrimson : AppTheme.textSubtle,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
