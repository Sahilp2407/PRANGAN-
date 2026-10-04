import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/alert_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  void _showPostAlertDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String alertType = 'urgent';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Issue Society Notice', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: alertType,
                  decoration: const InputDecoration(labelText: 'Notice Severity'),
                  items: const [
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent Notice (Water/Power/Security)')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance (Lift/Pumps/Cleaning)')),
                    DropdownMenuItem(value: 'notice', child: Text('General Notice / Meeting')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => alertType = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notice Title',
                    hintText: 'e.g. CIDCO Water Supply Interruption',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Notice Text',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;

                final auth = Provider.of<AuthProvider>(context, listen: false);
                final alertProvider = Provider.of<AlertProvider>(context, listen: false);
                final societyId = auth.userModel?.societyId ?? 'raj_rajeshwari_sec20';

                await alertProvider.createAlert(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  type: alertType,
                  societyId: societyId,
                );

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Broadcast Notice'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final user = auth.userModel;
    final societyId = user?.societyId ?? 'raj_rajeshwari_sec20';
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Neighborhood Alerts'),
        actions: [
          TextButton(
            onPressed: () {
              alertProvider.markAllRead(societyId, uid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All alerts marked as read')),
              );
            },
            child: Text(
              'Mark all read',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryCrimson,
              ),
            ),
          ),
          if (user?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.add_alert_rounded, color: AppTheme.primaryCrimson),
              tooltip: 'Post Notice',
              onPressed: _showPostAlertDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (All, Urgent, Maintenance, Notice)
          Container(
            color: Colors.white,
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alertProvider.alertTypes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = alertProvider.alertTypes[index];
                final isSelected = alertProvider.selectedType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryCrimson,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                  ),
                  onSelected: (_) => alertProvider.setSelectedType(type),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Alerts Stream
          Expanded(
            child: StreamBuilder<List<AlertModel>>(
              stream: alertProvider.streamAlerts(societyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final alerts = snapshot.data ?? [];
                if (alerts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 54, color: AppTheme.textSubtle.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No alerts in this category',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Important notices from CIDCO, police, or committee will appear here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    final isRead = alert.isReadBy(uid);

                    Color badgeColor;
                    Color badgeBg;
                    String badgeLabel;
                    IconData badgeIcon;

                    if (alert.type == 'urgent') {
                      badgeColor = AppTheme.alertUrgent;
                      badgeBg = const Color(0xFFFFE4E6);
                      badgeLabel = 'URGENT';
                      badgeIcon = Icons.warning_rounded;
                    } else if (alert.type == 'maintenance') {
                      badgeColor = AppTheme.alertMaintenance;
                      badgeBg = const Color(0xFFFEF3C7);
                      badgeLabel = 'MAINTENANCE';
                      badgeIcon = Icons.build_rounded;
                    } else {
                      badgeColor = AppTheme.alertNotice;
                      badgeBg = const Color(0xFFDBEAFE);
                      badgeLabel = 'NOTICE';
                      badgeIcon = Icons.info_outline_rounded;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : badgeBg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isRead ? AppTheme.cardBorder : badgeColor.withValues(alpha: 0.4),
                          width: isRead ? 1.0 : 1.5,
                        ),
                        boxShadow: AppTheme.subtleShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge and timestamp row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(badgeIcon, size: 13, color: badgeColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        badgeLabel,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: badgeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(alert.timestamp),
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppTheme.textSubtle,
                                  ),
                                ),
                                const Spacer(),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.alertUrgent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Alert Title
                            Text(
                              alert.title,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Alert Body Description
                            Text(
                              alert.description,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Mark Read Action
                            if (!isRead)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.done_all_rounded, size: 16),
                                  label: const Text('Mark as Read'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryCrimson,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  onPressed: () {
                                    alertProvider.markRead(alert.id, uid);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
