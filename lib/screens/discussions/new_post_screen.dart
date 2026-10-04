import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/society_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'General';
  Uint8List? _imageBytes;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  final List<String> _categories = [
    'General',
    'Maintenance',
    'Security',
    'Social',
    'Buy/Sell',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final storage = StorageService();
    final file = await storage.pickImage();
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);

    final user = auth.userModel;
    final societyId = societyProvider.currentSociety?.id ?? user?.societyId ?? 'raj_rajeshwari_sec20';
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    String? imageUrl;
    if (_imageBytes != null) {
      setState(() => _isUploading = true);
      try {
        final storage = StorageService();
        imageUrl = await storage.uploadImage(
          path: 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg',
          bytes: _imageBytes!,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      } catch (e) {
        debugPrint('Image upload failed: $e');
      } finally {
        setState(() => _isUploading = false);
      }
    }

    final success = await postProvider.createPost(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      authorUid: uid,
      authorName: user?.name.isNotEmpty == true ? user!.name : 'Resident',
      authorFlat: user?.flatDisplay.isNotEmpty == true ? user!.flatDisplay : 'A-702',
      societyId: societyId,
      category: _selectedCategory,
      imageUrl: imageUrl,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discussion post published to your society board!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postProvider.errorMessage ?? 'Failed to publish post'),
            backgroundColor: AppTheme.alertUrgent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Start Discussion'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selector
                Text(
                  'Select Topic Category',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryCrimson,
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Post Title
                Text(
                  'Discussion Headline',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Inverter battery replacement or water tanker schedule',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a headline' : null,
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Detailed Description',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe your suggestion, observation, or question for fellow residents in Kharghar...',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please provide details' : null,
                ),
                const SizedBox(height: 20),

                // Image Attachment section
                Text(
                  'Attach Photo (Optional)',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                if (_imageBytes != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(_imageBytes!, height: 160, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.6),
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            padding: EdgeInsets.zero,
                            onPressed: () => setState(() => _imageBytes = null),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                    label: const Text('Add Image from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _pickImage,
                  ),
                ],

                if (_isUploading) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _uploadProgress, color: AppTheme.primaryCrimson),
                ],

                const SizedBox(height: 24),

                // Privacy notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.primaryCrimson),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your post will only be visible to verified members of your housing society.',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Publish Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: postProvider.isCreatingPost || _isUploading ? null : _submitPost,
                    child: postProvider.isCreatingPost || _isUploading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Publish Discussion Post',
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
