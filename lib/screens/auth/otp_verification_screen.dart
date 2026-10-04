import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../society/create_society_screen.dart';
import '../society/join_society_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String name;
  final String block;
  final String flatNumber;
  final String role;
  final String targetFlow; // 'create' or 'join'
  final String demoOtp;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.name,
    required this.block,
    required this.flatNumber,
    required this.role,
    required this.targetFlow,
    this.demoOtp = '123456',
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-fill demo OTP after first frame for seamless testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFillOtp();
    });
  }

  void _autoFillOtp() {
    final code = widget.demoOtp;
    for (int i = 0; i < 6 && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the OTP'),
          backgroundColor: AppTheme.alertUrgent,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyDemoOtp(
      enteredOtp: code,
      phoneNumber: widget.phoneNumber,
      name: widget.name,
      flatNumber: widget.flatNumber,
      block: widget.block,
      role: widget.targetFlow == 'create' ? 'admin' : widget.role,
    );

    if (success && mounted) {
      final uid = authProvider.currentUid;
      final profile = UserModel(
        uid: uid,
        name: widget.name,
        phone: widget.phoneNumber,
        flatNumber: widget.flatNumber,
        block: widget.block,
        status: widget.targetFlow == 'create' ? 'approved' : 'pending',
        role: widget.targetFlow == 'create' ? 'admin' : widget.role,
        joinedAt: DateTime.now(),
      );
      await authProvider.saveProfile(profile);

      if (!mounted) return;

      if (widget.targetFlow == 'create') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CreateSocietyScreen(
              adminName: widget.name,
              adminPhone: widget.phoneNumber,
              adminFlat: widget.flatNumber,
              adminBlock: widget.block,
            ),
          ),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const JoinSocietyScreen()),
          (route) => false,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid OTP. Use Demo OTP: ${widget.demoOtp}'),
          backgroundColor: AppTheme.alertUrgent,
        ),
      );
    }
  }

  void _resendCode() {
    _startTimer();
    _autoFillOtp();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 8),
            Text('✨ Demo OTP is: ${widget.demoOtp} (Auto-filled)'),
          ],
        ),
        backgroundColor: AppTheme.primaryCrimson,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppTheme.primaryCrimson,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Verify Phone Number',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMuted),
                  children: [
                    const TextSpan(text: 'Verification code for '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Prominent Demo OTP Notification Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppTheme.goldDark, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Verification Code',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.goldDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use OTP: ${widget.demoOtp}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: AppTheme.primaryCrimson,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _autoFillOtp,
                      icon: const Icon(Icons.flash_on_rounded, size: 14),
                      label: const Text('Auto-Fill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCrimson,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6-digit boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryCrimson,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryCrimson,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_otpCode.length == 6) {
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Timer / Resend Button
              if (_secondsRemaining > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textSubtle),
                    const SizedBox(width: 6),
                    Text(
                      'Resend in 0:${_secondsRemaining.toString().padLeft(2, '0')}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                )
              else
                TextButton(
                  onPressed: _resendCode,
                  child: Text(
                    'Resend Demo OTP',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryCrimson,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Verify & Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _verifyOtp,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Verify & Proceed',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Change Number
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Change mobile number',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
