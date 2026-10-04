import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/society_model.dart';
import '../../providers/society_provider.dart';
import '../../theme/app_theme.dart';
import 'confirm_details_screen.dart';

class JoinSocietyScreen extends StatefulWidget {
  const JoinSocietyScreen({super.key});

  @override
  State<JoinSocietyScreen> createState() => _JoinSocietyScreenState();
}

class _JoinSocietyScreenState extends State<JoinSocietyScreen> {
  final _codeController = TextEditingController(text: 'PRG2026');
  SocietyModel? _foundSociety;
  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _searchSociety() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _searchError = 'Please enter a 6-character society code');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _foundSociety = null;
    });

    final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
    final society = await societyProvider.searchSocietyByCode(code);

    setState(() {
      _isSearching = false;
      if (society != null) {
        _foundSociety = society;
      } else {
        _searchError = 'No housing society found with code "$code". Check with your secretary or try "PRG2026".';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Join Housing Society'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Society Join Code',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the 6-character code provided by your society management committee or builder in Kharghar.',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Code Input with Search button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: AppTheme.primaryCrimson,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. PRG2026',
                        prefixIcon: Icon(Icons.vpn_key_outlined, color: AppTheme.textSubtle),
                      ),
                      onFieldSubmitted: (_) => _searchSociety(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchSociety,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Search'),
                    ),
                  ),
                ],
              ),

              if (_searchError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.alertUrgent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.alertUrgent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.alertUrgent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _searchError!,
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.alertUrgent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Found Society Preview Card
              if (_foundSociety != null) ...[
                Text(
                  'MATCHED SOCIETY',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSubtle,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent, width: 1.5),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: AppTheme.primaryCrimson,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _foundSociety!.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _foundSociety!.sector,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.goldDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.goldLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Verified',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.goldDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSubtle),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _foundSociety!.address,
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.groups_outlined, size: 16, color: AppTheme.textSubtle),
                          const SizedBox(width: 6),
                          Text(
                            '${_foundSociety!.totalFlats} Flats • ${_foundSociety!.wingsCount} Wings',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ConfirmDetailsScreen(society: _foundSociety!),
                              ),
                            );
                          },
                          child: const Text('Proceed with this Society'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Helpful Kharghar Demo Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.goldDark, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Kharghar Society',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.goldDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use code PRG2026 to join our sample verified society "Raj Rajeshwari CHS, Sector 20, Kharghar" to experience live discussions, events and voting.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
