import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String targetFlow; // 'create' or 'join'

  const SignUpScreen({super.key, required this.targetFlow});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wingController = TextEditingController();
  final _flatController = TextEditingController();

  String _selectedRole = 'Owner';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wingController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rawPhone = _phoneController.text.trim();
    final formattedPhone = rawPhone.startsWith('+') ? rawPhone : '+91$rawPhone';

    authProvider.sendDemoOtp(
      phoneNumber: formattedPhone,
      onOtpGenerated: (otp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Demo OTP: $otp (Auto-filled for testing)'),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryCrimson,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(
              verificationId: 'DEMO_$otp',
              phoneNumber: formattedPhone,
              name: _nameController.text.trim(),
              block: _wingController.text.trim(),
              flatNumber: _flatController.text.trim(),
              role: _selectedRole,
              targetFlow: widget.targetFlow,
              demoOtp: otp,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.targetFlow == 'create' ? 'Admin Registration' : 'Resident Sign Up',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal & Flat Details',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'We verify every resident in Kharghar societies to maintain community privacy & safety.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name
                Text(
                  'Full Name',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ramesh Kadam',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textSubtle),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your full name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number
                Text(
                  'Mobile Number',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '98200 12345',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      width: 65,
                      child: Text(
                        '+91',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter your phone number';
                    if (val.trim().length < 10) return 'Enter a valid 10-digit mobile number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Role Selection (Owner / Tenant)
                Text(
                  'Residency Type',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _RoleSelectRadio(
                        title: 'Flat Owner',
                        icon: Icons.home_rounded,
                        isSelected: _selectedRole == 'Owner',
                        onTap: () => setState(() => _selectedRole = 'Owner'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _RoleSelectRadio(
                        title: 'Tenant / Rent',
                        icon: Icons.key_rounded,
                        isSelected: _selectedRole == 'Tenant',
                        onTap: () => setState(() => _selectedRole = 'Tenant'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Wing and Flat No row
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wing / Block',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _wingController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Wing A',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Required';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flat / Unit No.',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _flatController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 702',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Required';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Send OTP Verification',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelectRadio extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectRadio({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCrimson : AppTheme.cardBorder,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryCrimson : AppTheme.textSubtle,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryCrimson : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
