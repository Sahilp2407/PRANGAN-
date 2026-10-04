import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/society_model.dart';
import '../../providers/society_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';

class SocietyCreatedScreen extends StatelessWidget {
  final SocietyModel society;

  const SocietyCreatedScreen({super.key, required this.society});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: society.joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join Code "${society.joinCode}" copied to clipboard!'),
        backgroundColor: AppTheme.primaryCrimson,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareCode() {
    final message = '''
Namaste Neighbors! 

Our residential community ${society.name} (${society.sector}) is now active on the Prangan app!

Download Prangan and join using our official Society Code:
🔑 *${society.joinCode}*

Use this to access our private discussion board, maintenance notices, events & polls.
''';
    SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Join ${society.name} on Prangan',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Success Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldAccent, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppTheme.primaryCrimson,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Society Created!',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                society.name,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryCrimson,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                society.sector,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 32),

              // Join Code Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'OFFICIAL SOCIETY JOIN CODE',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.goldDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        society.joinCode,
                        style: GoogleFonts.robotoMono(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryCrimson,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Copy & Share buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy Code'),
                            onPressed: () => _copyToClipboard(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                            label: const Text('Share Code'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.goldDark,
                            ),
                            onPressed: _shareCode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Informational card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Share this code on your society WhatsApp group. Residents will request to join, and you can approve them from the Admin Approvals desk.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Enter Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
                    societyProvider.loadSociety(society.id);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Go to Society Dashboard',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
