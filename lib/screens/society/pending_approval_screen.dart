import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/society_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/welcome_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<String>? _tempStatusSubscription;
  Timer? _pollingTimer;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _startListeningForApproval();
  }

  void _startListeningForApproval() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
    final user = auth.userModel;

    if (user != null && user.societyId != null) {
      // 1. Immediate check right away
      _checkStatusNow();

      // 2. Stream listener on user.uid
      _statusSubscription = societyProvider
          .listenApprovalStatus(user.societyId!, user.uid)
          .listen((status) {
        if (status == 'approved') {
          _handleApproval();
        }
      });

      // 3. Fallback stream listener on legacy temp_resident_uid
      _tempStatusSubscription = societyProvider
          .listenApprovalStatus(user.societyId!, 'temp_resident_uid')
          .listen((status) {
        if (status == 'approved') {
          _handleApproval();
        }
      });

      // 4. Polling check every 2 seconds for guaranteed realtime sync
      _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _checkStatusNow();
      });
    }
  }

  Future<void> _checkStatusNow() async {
    if (!mounted || _isTransitioning) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final refreshedUser = await auth.refreshProfile();
    if (refreshedUser != null && refreshedUser.isApproved) {
      _handleApproval();
    }
  }

  Future<void> _handleApproval() async {
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;
    _pollingTimer?.cancel();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.userModel;
    if (user != null && !user.isApproved) {
      await auth.saveProfile(user.copyWith(status: 'approved'));
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Your flat has been approved by the committee! Welcome to Prangan.'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 4),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _tempStatusSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _demoApproveSelf() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
    final user = auth.userModel;

    if (user != null && user.societyId != null) {
      try {
        await societyProvider.approveMember(user.societyId!, user.uid);
      } catch (_) {}
      try {
        await societyProvider.approveMember(user.societyId!, 'temp_resident_uid');
      } catch (_) {}
      await auth.saveProfile(user.copyWith(status: 'approved'));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final societyProvider = Provider.of<SocietyProvider>(context);
    final user = auth.userModel;
    final society = societyProvider.currentSociety;

    // If user already approved, immediately transition
    if (user != null && user.isApproved && !_isTransitioning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleApproval();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Pending Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Clock/Approval Emblem
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 42,
                  color: AppTheme.goldDark,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Approval Under Review',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your flat verification request has been submitted to the society committee.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      society?.name ?? user?.societyId ?? 'Housing Society',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryCrimson,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      society?.sector ?? 'Kharghar, Navi Mumbai',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textSubtle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Resident', value: user?.name ?? 'Resident'),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Flat / Unit',
                      value: user?.flatDisplay ?? 'Pending',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Status',
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pending Admin Approval',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.goldDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status pulse indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Listening for real-time committee approval...',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSubtle,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Instant Demo Approval Button for quick testing
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, color: AppTheme.goldDark),
                  label: const Text('Instant Demo Approval (Test Mode)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.goldDark,
                    side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _demoApproveSelf,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Once approved, this screen will instantly transition to your Community Dashboard.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
      ],
    );
  }
}
