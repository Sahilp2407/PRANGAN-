import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/society_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import 'society_created_screen.dart';

class CreateSocietyScreen extends StatefulWidget {
  final String adminName;
  final String adminPhone;
  final String adminFlat;
  final String adminBlock;

  const CreateSocietyScreen({
    super.key,
    required this.adminName,
    required this.adminPhone,
    required this.adminFlat,
    required this.adminBlock,
  });

  @override
  State<CreateSocietyScreen> createState() => _CreateSocietyScreenState();
}

class _CreateSocietyScreenState extends State<CreateSocietyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Raj Rajeshwari CHS');
  final _addressController = TextEditingController(text: 'Plot 42, Sector 20, Near Jalvayu Vihar');
  final _totalFlatsController = TextEditingController(text: '144');
  final _wingsController = TextEditingController(text: '4');

  String _selectedSector = 'Sector 20';
  Uint8List? _logoBytes;
  double _uploadProgress = 0.0;
  bool _isUploadingLogo = false;

  final List<String> _khargharSectors = [
    'Sector 7',
    'Sector 10',
    'Sector 12',
    'Sector 19',
    'Sector 20',
    'Sector 21',
    'Sector 34',
    'Sector 35',
    'Sector 36',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _totalFlatsController.dispose();
    _wingsController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final storageService = StorageService();
    final file = await storageService.pickImage();
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _logoBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
    final uid = authProvider.currentUid.isNotEmpty ? authProvider.currentUid : 'admin_uid';

    String? logoUrl;
    if (_logoBytes != null) {
      setState(() => _isUploadingLogo = true);
      try {
        final storage = StorageService();
        logoUrl = await storage.uploadImage(
          path: 'societies/${DateTime.now().millisecondsSinceEpoch}_logo.jpg',
          bytes: _logoBytes!,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      } catch (e) {
        debugPrint('Logo upload error: $e');
      } finally {
        setState(() => _isUploadingLogo = false);
      }
    }

    final society = await societyProvider.createSociety(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      sector: '$_selectedSector, Kharghar',
      adminUid: uid,
      adminName: widget.adminName,
      adminPhone: widget.adminPhone,
      adminFlat: widget.adminFlat,
      adminBlock: widget.adminBlock,
      logoUrl: logoUrl,
      totalFlats: int.tryParse(_totalFlatsController.text.trim()) ?? 100,
      wingsCount: int.tryParse(_wingsController.text.trim()) ?? 1,
    );

    if (society != null && mounted) {
      // Update local user profile state
      if (authProvider.userModel != null) {
        await authProvider.saveProfile(
          authProvider.userModel!.copyWith(
            societyId: society.id,
            role: 'admin',
            status: 'approved',
          ),
        );
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SocietyCreatedScreen(society: society),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(societyProvider.errorMessage ?? 'Failed to create society'),
          backgroundColor: AppTheme.alertUrgent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final societyProvider = Provider.of<SocietyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Register Housing Society'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.primaryCrimson, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kharghar Society Portal Setup',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                            Text(
                              'As admin, you will manage approvals, post notices & lead community polls.',
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

                // Society Logo Picker
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.goldAccent, width: 2),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: _logoBytes != null
                              ? ClipOval(
                                  child: Image.memory(_logoBytes!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, color: AppTheme.goldDark, size: 26),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Logo',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.goldDark,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Society Crest / Logo (Optional)',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSubtle),
                      ),
                      if (_isUploadingLogo) ...[
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: _uploadProgress, color: AppTheme.primaryCrimson),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Society Name
                Text('Society Name', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Raj Rajeshwari CHS',
                    prefixIcon: Icon(Icons.apartment_rounded, color: AppTheme.textSubtle),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter society name' : null,
                ),
                const SizedBox(height: 20),

                // Sector in Kharghar
                Text('Sector in Kharghar', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSector,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.textSubtle),
                  ),
                  items: _khargharSectors.map((sector) {
                    return DropdownMenuItem(
                      value: sector,
                      child: Text('$sector, Kharghar, Navi Mumbai'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSector = val);
                  },
                ),
                const SizedBox(height: 20),

                // Address
                Text('Full Plot / Street Address', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Plot 42, Sector 20, Roadpali Link Road',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter street address' : null,
                ),
                const SizedBox(height: 20),

                // Flats and Wings
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Flats', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _totalFlatsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '144'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wings / Towers', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _wingsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '4'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: societyProvider.isLoading ? null : _submit,
                    child: societyProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Register Society & Generate Code',
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
