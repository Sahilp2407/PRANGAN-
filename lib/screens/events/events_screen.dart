import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '7:00 PM');
    final locCtrl = TextEditingController(text: 'Society Clubhouse, Kharghar');
    String cat = 'Festival';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Schedule Society Event', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (e.g. 7:00 PM)')),
                const SizedBox(height: 12),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Venue in Kharghar')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: cat,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Festival', 'Meeting', 'Sports', 'Cultural'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => cat = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final eventProvider = Provider.of<EventProvider>(context, listen: false);
                final societyId = auth.userModel?.societyId ?? 'raj_rajeshwari_sec20';

                await eventProvider.createEvent(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  date: selectedDate,
                  time: timeCtrl.text.trim(),
                  location: locCtrl.text.trim(),
                  category: cat,
                  societyId: societyId,
                );

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final societyId = auth.userModel?.societyId ?? 'raj_rajeshwari_sec20';
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Community Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryCrimson),
            tooltip: 'Add Event',
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Upcoming vs Past)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => eventProvider.setShowUpcomingOnly(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: eventProvider.showUpcomingOnly ? AppTheme.primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: eventProvider.showUpcomingOnly ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                        ),
                      ),
                      child: Text(
                        'Upcoming Events',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: eventProvider.showUpcomingOnly ? FontWeight.w700 : FontWeight.w500,
                          color: eventProvider.showUpcomingOnly ? AppTheme.primaryCrimson : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => eventProvider.setShowUpcomingOnly(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !eventProvider.showUpcomingOnly ? AppTheme.primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !eventProvider.showUpcomingOnly ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                        ),
                      ),
                      child: Text(
                        'Past Events',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: !eventProvider.showUpcomingOnly ? FontWeight.w700 : FontWeight.w500,
                          color: !eventProvider.showUpcomingOnly ? AppTheme.primaryCrimson : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Chips
          Container(
            color: Colors.white,
            height: 48,
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: eventProvider.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = eventProvider.categories[index];
                final isSelected = eventProvider.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppTheme.goldDark,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                  side: BorderSide(color: isSelected ? AppTheme.goldDark : AppTheme.cardBorder),
                  onSelected: (_) => eventProvider.setCategory(cat),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Events Stream
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: eventProvider.streamEvents(societyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 54, color: AppTheme.textSubtle.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            eventProvider.showUpcomingOnly ? 'No upcoming events scheduled' : 'No past events found',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Festivals, society meetings & celebrations will appear here.',
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
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final isRSVPed = event.isInterested(uid);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Banner
                                Container(
                                  width: 56,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.primaryCrimson.withValues(alpha: 0.2)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('MMM').format(event.date).toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryCrimson,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd').format(event.date),
                                        style: GoogleFonts.outfit(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryCrimson,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.goldLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          event.category,
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.goldDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSubtle),
                                const SizedBox(width: 4),
                                Text(event.time, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                                const SizedBox(width: 12),
                                const Icon(Icons.place_outlined, size: 14, color: AppTheme.textSubtle),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),

                            // RSVP Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_alt_outlined, size: 16, color: AppTheme.goldDark),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${event.interestedUsers.length} residents interested',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(
                                    isRSVPed ? Icons.check_circle_rounded : Icons.star_border_rounded,
                                    size: 16,
                                    color: isRSVPed ? Colors.white : AppTheme.primaryCrimson,
                                  ),
                                  label: Text(
                                    isRSVPed ? 'Attending' : 'RSVP',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isRSVPed ? Colors.white : AppTheme.primaryCrimson,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isRSVPed ? AppTheme.primaryCrimson : AppTheme.primaryLight,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    eventProvider.toggleRSVP(event.id, uid, isRSVPed);
                                  },
                                ),
                              ],
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
