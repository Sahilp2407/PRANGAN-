import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/society_provider.dart';
import '../../theme/app_theme.dart';

class AdminApprovalsScreen extends StatelessWidget {
  const AdminApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final societyProvider = Provider.of<SocietyProvider>(context);
    final user = auth.userModel;
    final societyId = user?.societyId ?? 'raj_rajeshwari_sec20';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Member Verifications'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: societyProvider.getPendingRequestsStream(societyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingMembers = snapshot.data ?? [];

          return Column(
            children: [
              // Header Summary Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.how_to_reg_rounded, color: AppTheme.primaryCrimson, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verification Queue',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '${pendingMembers.length} residents waiting for committee approval',
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

              // Request Cards List
              Expanded(
                child: pendingMembers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppTheme.goldLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_rounded, size: 40, color: AppTheme.goldDark),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'All caught up!',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'There are no pending join requests for your society.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pendingMembers.length,
                        itemBuilder: (context, index) {
                          final member = pendingMembers[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.cardBorder),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppTheme.primaryLight,
                                      child: Text(
                                        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryCrimson,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.name,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            member.phone,
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: member.role == 'Owner' ? AppTheme.goldLight : const Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        member.role,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: member.role == 'Owner' ? AppTheme.goldDark : const Color(0xFF4338CA),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 14),

                                // Flat details
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.home_work_outlined, size: 16, color: AppTheme.textSubtle),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Flat: ${member.flatDisplay}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSubtle),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('dd MMM, hh:mm a').format(member.joinedAt),
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: AppTheme.textSubtle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Approve / Reject action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await societyProvider.rejectMember(societyId, member.uid);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Join request for ${member.name} rejected.'),
                                                backgroundColor: AppTheme.alertUrgent,
                                              ),
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.alertUrgent,
                                          side: const BorderSide(color: AppTheme.alertUrgent),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check_rounded, size: 18),
                                        label: const Text('Approve Member'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () async {
                                          await societyProvider.approveMember(societyId, member.uid);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${member.name} (${member.flatDisplay}) approved! Access granted.'),
                                                backgroundColor: AppTheme.successGreen,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
