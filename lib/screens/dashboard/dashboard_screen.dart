import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/post_model.dart';
import '../../models/event_model.dart';
import '../../models/alert_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/society_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/alert_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_crest.dart';
import '../discussions/discussion_list_screen.dart';
import '../discussions/post_detail_screen.dart';
import '../discussions/new_post_screen.dart';
import '../events/events_screen.dart';
import '../polls/poll_screen.dart';
import '../alerts/alerts_screen.dart';
import '../admin/admin_approvals_screen.dart';
import '../auth/welcome_screen.dart';
import '../../services/seed_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final societyProvider = Provider.of<SocietyProvider>(context, listen: false);
      final societyId = societyProvider.currentSociety?.id ?? auth.userModel?.societyId ?? 'raj_rajeshwari_sec20';
      SeedService().seedSocietyDataIfEmpty(societyId).catchError((e) {
        debugPrint('Auto-seed check note: $e');
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 0) return;
    setState(() => _currentNavIndex = index);

    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiscussionListScreen()));
    } else if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsScreen()));
    } else if (index == 3) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PollScreen()));
    } else if (index == 4) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final societyProvider = Provider.of<SocietyProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);

    final user = auth.userModel;
    final society = societyProvider.currentSociety;
    final societyId = society?.id ?? user?.societyId ?? 'raj_rajeshwari_sec20';
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      appBar: AppBar(
        toolbarHeight: 74,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.cardBorder.withValues(alpha: 0.6),
            height: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldAccent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const AppCrest(size: 38),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          society?.name ?? 'Prangan Society',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, size: 15, color: AppTheme.goldDark),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          society?.sector ?? 'Kharghar, Navi Mumbai',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Stream unread alerts count badge
          StreamBuilder<int>(
            stream: alertProvider.streamUnreadCount(societyId, uid),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: unreadCount > 0 ? AppTheme.primaryLight : const Color(0xFFF3F0EC),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  padding: EdgeInsets.zero,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                        size: 20,
                        color: unreadCount > 0 ? AppTheme.primaryCrimson : AppTheme.textDark,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppTheme.alertUrgent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                            child: Text(
                              '$unreadCount',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlertsScreen()),
                    );
                  },
                ),
              );
            },
          ),

          // Admin shortcut button if admin
          if (user?.isAdmin == true)
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: AppTheme.goldLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
              ),
              child: IconButton(
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.shield_rounded, size: 19, color: AppTheme.goldDark),
                tooltip: 'Admin Approvals',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminApprovalsScreen()),
                  );
                },
              ),
            ),

          // Menu button
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F0EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert_rounded, size: 17, color: AppTheme.textDark),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) async {
              if (value == 'admin') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminApprovalsScreen()),
                );
              } else if (value == 'logout') {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              if (user?.isAdmin == true)
                const PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryCrimson, size: 20),
                      SizedBox(width: 10),
                      Text('Admin Approvals Queue'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppTheme.alertUrgent, size: 20),
                    SizedBox(width: 10),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Premium Resident Hero Card
            _buildResidentHeroCard(user, society),
            const SizedBox(height: 18),

            // 2. Search & Category Filter Strip
            _buildSearchAndFilters(postProvider),
            const SizedBox(height: 24),

            // 3. Community Desk (Quick Actions)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COMMUNITY DESK',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppTheme.textSubtle,
                  ),
                ),
                Text(
                  'Quick Hub',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.goldDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCommunityDeskGrid(context, user),
            const SizedBox(height: 26),

            // 4. Urgent Announcement Banner (Real-time stream)
            _buildUrgentAlertBanner(alertProvider, societyId),

            // 5. Trending Discussions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppTheme.primaryCrimson, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Trending Discussions',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DiscussionListScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryCrimson,
                    textStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDiscussionsPreview(postProvider, societyId, uid, society?.name),
            const SizedBox(height: 28),

            // 6. Upcoming Events Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.celebration_rounded, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Society Events & Meets',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EventsScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD97706),
                    textStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildEventsPreview(context, eventProvider, societyId),
            const SizedBox(height: 28),

            // 7. Society Services & Emergency Contacts Strip
            _buildSocietyServicesCard(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCrimson.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            'New Post',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.4),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NewPostScreen()),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: _onNavTapped,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppTheme.primaryLight,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryCrimson),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum_rounded, color: AppTheme.primaryCrimson),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event_rounded, color: AppTheme.primaryCrimson),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.poll_outlined),
              selectedIcon: Icon(Icons.poll_rounded, color: AppTheme.primaryCrimson),
              label: 'Polls',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none_rounded),
              selectedIcon: Icon(Icons.notifications_rounded, color: AppTheme.primaryCrimson),
              label: 'Alerts',
            ),
          ],
        ),
      ),
    );
  }

  // 1. Premium Resident Hero Card
  Widget _buildResidentHeroCard(dynamic user, dynamic society) {
    final name = user?.name ?? "Resident";
    final flat = user?.flatDisplay.isNotEmpty == true ? user!.flatDisplay : 'Wing A-303';
    final isAdmin = user?.role == 'admin' || user?.isAdmin == true;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF56111E),
            Color(0xFF330911),
            Color(0xFF1D0308),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.goldAccent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF56111E).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background ambient shine circle
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.goldAccent.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with gold border ring
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF420B15),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'R',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Namaste, $name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text('🙏', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.goldAccent.withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.home_rounded, size: 12, color: Color(0xFFFDE68A)),
                                    const SizedBox(width: 4),
                                    Text(
                                      flat.toLowerCase().startsWith('flat') ? flat : 'Flat $flat',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAdmin ? '🛡️ Committee Admin' : '✓ Verified Resident',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mini Society Stats Bar inside Hero
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeroStat('Flats', '${society?.totalFlats ?? 144}', Icons.apartment_rounded),
                      Container(width: 1, height: 22, color: Colors.white.withValues(alpha: 0.15)),
                      _buildHeroStat('Wings', '${society?.wingsCount ?? 4}', Icons.grid_view_rounded),
                      Container(width: 1, height: 22, color: Colors.white.withValues(alpha: 0.15)),
                      _buildHeroStat('Security', '24/7 Live', Icons.shield_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String title, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFFFDE68A)),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Search & Category Filters
  Widget _buildSearchAndFilters(PostProvider postProvider) {
    return Column(
      children: [
        // Search Input Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search discussions, notices, neighbors...',
              hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: AppTheme.textSubtle),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryCrimson, size: 22),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryCrimson),
                ),
                onPressed: () {
                  if (_searchController.text.trim().isNotEmpty) {
                    postProvider.setSearchQuery(_searchController.text.trim());
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DiscussionListScreen()),
                    );
                  }
                },
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                postProvider.setSearchQuery(val.trim());
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DiscussionListScreen()),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 12),

        // Quick Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryPill('All Feed', 'All', postProvider, Icons.dynamic_feed_rounded),
              _buildCategoryPill('Security', 'Security', postProvider, Icons.security_rounded),
              _buildCategoryPill('Notices', 'General', postProvider, Icons.campaign_rounded),
              _buildCategoryPill('Maintenance', 'Maintenance', postProvider, Icons.handyman_rounded),
              _buildCategoryPill('Social', 'Social', postProvider, Icons.groups_rounded),
              _buildCategoryPill('Marketplace', 'Buy/Sell', postProvider, Icons.storefront_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPill(String label, String value, PostProvider postProvider, IconData icon) {
    final isSelected = postProvider.selectedCategory == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            postProvider.setCategory(value);
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryCrimson : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryCrimson.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3. Redesigned Community Desk (Quick Action Hub)
  Widget _buildCommunityDeskGrid(BuildContext context, dynamic user) {
    final actions = [
      _QuickActionCard(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Discussions',
        subtitle: 'Feed',
        gradientColors: const [Color(0xFF86243A), Color(0xFF5B1625)],
        badgeText: 'Live',
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiscussionListScreen()));
        },
      ),
      _QuickActionCard(
        icon: Icons.event_available_rounded,
        title: 'Events',
        subtitle: 'Calendar',
        gradientColors: const [Color(0xFFEA580C), Color(0xFFC2410C)],
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsScreen()));
        },
      ),
      _QuickActionCard(
        icon: Icons.how_to_vote_outlined,
        title: 'Polls',
        subtitle: 'Vote',
        gradientColors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PollScreen()));
        },
      ),
      _QuickActionCard(
        icon: Icons.notifications_active_outlined,
        title: 'Alerts',
        subtitle: 'Urgent',
        gradientColors: const [Color(0xFFE11D48), Color(0xFFBE123C)],
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsScreen()));
        },
      ),
      if (user?.isAdmin == true)
        _QuickActionCard(
          icon: Icons.verified_user_outlined,
          title: 'Admin',
          subtitle: 'Desk',
          gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)],
          badgeText: 'Review',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminApprovalsScreen()));
          },
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map((card) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: card,
                ))
            .toList(),
      ),
    );
  }

  // 4. Urgent Announcement Banner
  Widget _buildUrgentAlertBanner(AlertProvider alertProvider, String societyId) {
    return StreamBuilder<List<AlertModel>>(
      stream: alertProvider.streamAlerts(societyId),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];
        final urgentAlerts = alerts.where((a) => a.type == 'urgent').toList();
        if (urgentAlerts.isEmpty) return const SizedBox.shrink();

        final topAlert = urgentAlerts.first;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.alertUrgent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.alertUrgent.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppTheme.alertUrgent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.alertUrgent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'EMERGENCY BROADCAST',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM, hh:mm a').format(topAlert.timestamp),
                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topAlert.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      topAlert.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. Trending Discussions Preview
  Widget _buildDiscussionsPreview(PostProvider postProvider, String societyId, String uid, String? societyName) {
    return StreamBuilder<List<PostModel>>(
      stream: postProvider.streamPosts(societyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_outlined, color: AppTheme.primaryCrimson, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Discussions Yet',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Be the first to share an update or question in ${societyName ?? "your society"}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewPostScreen()));
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Start Discussion'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          );
        }

        final previewPosts = posts.take(3).toList();
        return Column(
          children: previewPosts.map((post) {
            return _EnhancedDiscussionCard(
              post: post,
              uid: uid,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                );
              },
              onLikeToggle: () {
                postProvider.toggleLike(post.id, uid, post.isLikedBy(uid));
              },
            );
          }).toList(),
        );
      },
    );
  }

  // 6. Upcoming Events Preview
  Widget _buildEventsPreview(BuildContext context, EventProvider eventProvider, String societyId) {
    return StreamBuilder<List<EventModel>>(
      stream: eventProvider.streamEvents(societyId),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Host a Society Gathering',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF78350F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Festival, sports meet or AGM? Schedule an event for residents.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Color(0xFFB45309), size: 28),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsScreen()));
                  },
                ),
              ],
            ),
          );
        }

        final topEvent = events.first;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Date badge with gradient
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF86243A), Color(0xFF5B1625)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCrimson.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(topEvent.date).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFDE68A),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      DateFormat('dd').format(topEvent.date),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
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
                    Text(
                      topEvent.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.textSubtle),
                        const SizedBox(width: 4),
                        Text(topEvent.time, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                        const SizedBox(width: 10),
                        const Icon(Icons.place_outlined, size: 13, color: AppTheme.textSubtle),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            topEvent.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 7. Society Quick Services & Helpdesk Strip
  Widget _buildSocietyServicesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: AppTheme.goldDark, size: 20),
              const SizedBox(width: 8),
              Text(
                'Society Helpdesk & Services',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildServiceIcon(Icons.phone_in_talk_rounded, 'Main Gate', 'Dial Security'),
              _buildServiceIcon(Icons.water_drop_rounded, 'Water Tank', 'Twice Daily'),
              _buildServiceIcon(Icons.delete_sweep_rounded, 'Garbage', '8:30 AM Daily'),
              _buildServiceIcon(Icons.electric_bolt_rounded, 'Electrician', 'On Call'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String title, String sub) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.goldLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.goldDark, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        Text(
          sub,
          style: GoogleFonts.outfit(fontSize: 9.5, color: AppTheme.textSubtle),
        ),
      ],
    );
  }
}

// Modern Quick Action Tile
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String? badgeText;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              if (badgeText != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: gradientColors.first, width: 1.2),
                    ),
                    child: Text(
                      badgeText!,
                      style: GoogleFonts.outfit(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: gradientColors.first,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Discussion Card
class _EnhancedDiscussionCard extends StatelessWidget {
  final PostModel post;
  final String uid;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;

  const _EnhancedDiscussionCard({
    required this.post,
    required this.uid,
    required this.onTap,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.isLikedBy(uid);

    Color categoryColor;
    Color categoryBg;
    switch (post.category.toLowerCase()) {
      case 'security':
        categoryColor = const Color(0xFFD97706);
        categoryBg = const Color(0xFFFEF3C7);
        break;
      case 'maintenance':
        categoryColor = const Color(0xFF2563EB);
        categoryBg = const Color(0xFFDBEAFE);
        break;
      case 'social':
        categoryColor = const Color(0xFF059669);
        categoryBg = const Color(0xFFD1FAE5);
        break;
      default:
        categoryColor = AppTheme.primaryCrimson;
        categoryBg = AppTheme.primaryLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'R',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.primaryCrimson,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            post.authorFlat.isNotEmpty ? 'Flat ${post.authorFlat}' : 'Resident',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.textSubtle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: categoryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.category,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Post Title
                Text(
                  post.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),

                // Post Description
                Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                const Divider(height: 1),
                const SizedBox(height: 10),

                // Engagement action bar
                Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: onLikeToggle,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: isLiked ? AppTheme.alertUrgent : AppTheme.textSubtle,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${post.likes.length}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isLiked ? AppTheme.alertUrgent : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Comments button
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.textSubtle),
                        const SizedBox(width: 5),
                        Text(
                          '${post.commentCount} replies',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Read details arrow
                    Row(
                      children: [
                        Text(
                          'Open',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryCrimson,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryCrimson),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
