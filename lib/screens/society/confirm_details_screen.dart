import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/society_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/society_provider.dart';
import '../../theme/app_theme.dart';
import 'pending_approval_screen.dart';

class ConfirmDetailsScreen extends StatefulWidget {
  final SocietyModel society;

  const ConfirmDetailsScreen({super.key, required this.society});

  @override
  State<ConfirmDetailsScreen> createState() => _ConfirmDetailsScreenState();
}

class _ConfirmDetailsScreenState extends State<ConfirmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _wingController;
  late TextEditingController _flatController;

  String _role = 'Owner';
  bool _agreedToBylaws = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.userModel;

    _nameController = TextEditingController(text: user?.name.isNotEmpty == true ? user!.name : 'Amitabh Sharma');
    _phoneController = TextEditingController(text: user?.phone.isNotEmpty == true ? user!.phone : '+91 98200 12345');
    _wingController = TextEditingController(text: user?.block.isNotEmpty == true ? user!.block : 'Wing B');
    _flatController = TextEditingController(text: user?.flatNumber.isNotEmpty == true ? user!.flatNumber : '402');
    _role = user?.role == 'Tenant' ? 'Tenant' : 'Owner';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wingController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToBylaws) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the society bylaws declaration to proceed.'),
          backgroundColor: AppTheme.alertUrgent,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
    final uid = authProvider.currentUid.isNotEmpty
        ? authProvider.currentUid
        : (authProvider.userModel?.uid ?? 'user_${_phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')}');

    final success = await societyProvider.requestToJoin(
      societyId: widget.society.id,
      uid: uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      flatNumber: _flatController.text.trim(),
      block: _wingController.text.trim(),
      role: _role,
    );

    if (success && mounted) {
      // Update local auth state
      if (authProvider.userModel != null) {
        await authProvider.saveProfile(
          authProvider.userModel!.copyWith(
            societyId: widget.society.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            flatNumber: _flatController.text.trim(),
            block: _wingController.text.trim(),
            role: _role,
            status: 'pending',
          ),
        );
      }

      societyProvider.loadSociety(widget.society.id);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final societyProvider = Provider.of<SocietyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Confirm Membership Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Society Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: AppTheme.subtleShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.apartment_rounded, color: AppTheme.primaryCrimson),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.society.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              widget.society.sector,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Verify Your Flat Details',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These details will be verified by the society secretary or admin committee.',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Name
                Text('Full Resident Name', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Full Name'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Phone
                Text('Phone Number', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(hintText: '+91 98200 12345'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Wing and Flat
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wing / Tower', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _wingController,
                            decoration: const InputDecoration(hintText: 'e.g. Wing B'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Flat Number', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _flatController,
                            decoration: const InputDecoration(hintText: 'e.g. 402'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Role Dropdown
                Text('Residency Status', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'Owner', child: Text('Flat Owner (Resident)')),
                    DropdownMenuItem(value: 'Tenant', child: Text('Registered Tenant / Rentee')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _role = val);
                  },
                ),
                const SizedBox(height: 24),

                // Declaration Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToBylaws,
                      activeColor: AppTheme.primaryCrimson,
                      onChanged: (val) => setState(() => _agreedToBylaws = val ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'I declare that I am a bonafide resident of this flat in ${widget.society.name} and agree to follow society guidelines.',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: societyProvider.isLoading ? null : _submitRequest,
                    child: societyProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Submit Join Request',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
