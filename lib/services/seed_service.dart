import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/society_model.dart';

class SeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String defaultSocietyId = 'raj_rajeshwari_sec20';
  static const String defaultJoinCode = 'PRG2026';

  Future<void> seedKhargharDataIfEmpty() async {
    try {
      final doc = await _firestore.collection('societies').doc(defaultSocietyId).get();
      if (doc.exists) {
        debugPrint('Kharghar demo society already exists in Firestore.');
        return;
      }

      debugPrint('Seeding authentic Kharghar society data...');

      // 1. Create Society
      final society = SocietyModel(
        id: defaultSocietyId,
        name: 'Raj Rajeshwari CHS',
        address: 'Plot 42, Sector 20, Near Jalvayu Vihar',
        sector: 'Sector 20',
        joinCode: defaultJoinCode,
        adminUid: 'admin_kharghar_uid',
        totalFlats: 144,
        wingsCount: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      await _firestore.collection('societies').doc(defaultSocietyId).set(society.toMap());

      // 2. Add sample admin member
      await _firestore.collection('societies').doc(defaultSocietyId).collection('members').doc('admin_kharghar_uid').set({
        'name': 'Rajesh K. Patil (Secretary)',
        'phone': '+91 98200 12345',
        'flatNumber': '201',
        'block': 'Wing A',
        'status': 'approved',
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 3. Add pending member for Admin Approval screen
      await _firestore.collection('societies').doc(defaultSocietyId).collection('members').doc('pending_member_1').set({
        'name': 'Amitabh Sharma',
        'phone': '+91 98212 99881',
        'flatNumber': '402',
        'block': 'Wing B',
        'status': 'pending',
        'role': 'Owner',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('societies').doc(defaultSocietyId).collection('members').doc('pending_member_2').set({
        'name': 'Pooja Iyer',
        'phone': '+91 97690 33441',
        'flatNumber': '704',
        'block': 'Wing C',
        'status': 'pending',
        'role': 'Tenant',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 4. Seed Posts / Discussions
      final samplePosts = [
        {
          'id': 'post_water_pipeline',
          'title': 'CIDCO Pipeline Repair update on Sector 20 Main Road',
          'description': 'The CIDCO water pipeline near Jalvayu Vihar junction has been temporarily repaired. Full water pressure expected by 8:00 PM tonight. Please regulate domestic tank consumption.',
          'authorUid': 'admin_kharghar_uid',
          'authorName': 'Rajesh Patil',
          'authorFlat': 'A-201',
          'societyId': defaultSocietyId,
          'category': 'Maintenance',
          'likes': ['user_1', 'user_2', 'user_3', 'user_4'],
          'commentCount': 3,
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        },
        {
          'id': 'post_solar_inverter',
          'title': 'Rooftop Solar Generation Reached 4,200 Units this Month!',
          'description': 'Our society rooftop solar panels generated over 4,200 units of electricity this month, reducing our common area electricity bill by approximately 42%! Kudos to the green initiative committee.',
          'authorUid': 'user_sunil',
          'authorName': 'Sunil Deshmukh',
          'authorFlat': 'B-501',
          'societyId': defaultSocietyId,
          'category': 'General',
          'likes': ['admin_kharghar_uid', 'user_1', 'user_5'],
          'commentCount': 2,
          'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
        },
        {
          'id': 'post_dandiya_pass',
          'title': 'Navratri Dandiya Night Passes Available at Society Office',
          'description': 'Residents can collect free entry passes and food coupons for family & registered guests from the Society Office starting 6 PM today.',
          'authorUid': 'admin_kharghar_uid',
          'authorName': 'Rajesh Patil',
          'authorFlat': 'A-201',
          'societyId': defaultSocietyId,
          'category': 'Social',
          'likes': ['user_1', 'user_2', 'user_7', 'user_8', 'user_9'],
          'commentCount': 4,
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
      ];

      for (var p in samplePosts) {
        final id = p['id'] as String;
        await _firestore.collection('posts').doc(id).set({
          'title': p['title'],
          'description': p['description'],
          'authorUid': p['authorUid'],
          'authorName': p['authorName'],
          'authorFlat': p['authorFlat'],
          'societyId': p['societyId'],
          'category': p['category'],
          'likes': p['likes'],
          'commentCount': p['commentCount'],
          'timestamp': Timestamp.fromDate(p['timestamp'] as DateTime),
        });

        // Add sample comment
        await _firestore.collection('posts').doc(id).collection('comments').doc('c1').set({
          'authorUid': 'user_vikram',
          'authorName': 'Vikram Joshi',
          'authorFlat': 'C-103',
          'text': 'Thank you for the prompt update! Really appreciate the committee team.',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
        });
      }

      // 5. Seed Events
      final sampleEvents = [
        {
          'id': 'event_dandiya',
          'title': 'Grand Navratri Dandiya & Garba Mahotsav',
          'description': 'Traditional Gujarati live orchestra, traditional attire competition, and delicious chaat counters for all residents.',
          'date': DateTime.now().add(const Duration(days: 4)),
          'time': '7:30 PM - 11:00 PM',
          'location': 'Central Amphitheatre, Raj Rajeshwari CHS',
          'category': 'Festival',
          'societyId': defaultSocietyId,
          'interestedUsers': ['user_1', 'user_2', 'user_3', 'user_4', 'user_5', 'user_6'],
        },
        {
          'id': 'event_agm',
          'title': 'Annual General Body Meeting (AGM 2026)',
          'description': 'Discussion on audited balance sheet, lift AMC contract renewal, and security guard agency review.',
          'date': DateTime.now().add(const Duration(days: 12)),
          'time': '10:30 AM - 1:00 PM',
          'location': 'Clubhouse Banquet Hall, Kharghar',
          'category': 'Meeting',
          'societyId': defaultSocietyId,
          'interestedUsers': ['admin_kharghar_uid', 'user_1'],
        },
        {
          'id': 'event_cycling',
          'title': 'Kharghar Hills Sunday Morning Cyclothon',
          'description': 'Community fitness ride from Sector 20 to Kharghar Hills viewpoint. Helmets mandatory.',
          'date': DateTime.now().add(const Duration(days: 7)),
          'time': '6:00 AM - 8:00 AM',
          'location': 'Starting Point: Society Main Gate 1',
          'category': 'Sports',
          'societyId': defaultSocietyId,
          'interestedUsers': ['user_2', 'user_3', 'user_8'],
        },
      ];

      for (var ev in sampleEvents) {
        final id = ev['id'] as String;
        await _firestore.collection('events').doc(id).set({
          'title': ev['title'],
          'description': ev['description'],
          'date': Timestamp.fromDate(ev['date'] as DateTime),
          'time': ev['time'],
          'location': ev['location'],
          'category': ev['category'],
          'societyId': ev['societyId'],
          'interestedUsers': ev['interestedUsers'],
        });
      }

      // 6. Seed Polls
      final samplePolls = [
        {
          'id': 'poll_rfid_barrier',
          'question': 'Should we install automated RFID Fastag Boom Barriers at Main Gate 1 & 2?',
          'options': [
            {'id': 'opt_1', 'text': 'Yes, install RFID boom barriers', 'voteCount': 28},
            {'id': 'opt_2', 'text': 'No, maintain existing manual barrier', 'voteCount': 6},
            {'id': 'opt_3', 'text': 'Need more vendor quotations first', 'voteCount': 11},
          ],
          'totalVotes': 45,
          'societyId': defaultSocietyId,
          'votedUsers': {'user_1': 'opt_1', 'user_2': 'opt_1', 'user_3': 'opt_3'},
          'postedBy': 'Managing Committee',
          'endDate': DateTime.now().add(const Duration(days: 5)),
          'status': 'active',
        },
        {
          'id': 'poll_gym_timings',
          'question': 'Proposed extension of Society Gymnasium morning hours starting 5:30 AM?',
          'options': [
            {'id': 'opt_1', 'text': 'Yes, open from 5:30 AM', 'voteCount': 34},
            {'id': 'opt_2', 'text': 'Keep current 6:30 AM timing', 'voteCount': 12},
          ],
          'totalVotes': 46,
          'societyId': defaultSocietyId,
          'votedUsers': {},
          'postedBy': 'Sports & Fitness Committee',
          'endDate': DateTime.now().add(const Duration(days: 2)),
          'status': 'active',
        },
      ];

      for (var poll in samplePolls) {
        final id = poll['id'] as String;
        await _firestore.collection('polls').doc(id).set({
          'question': poll['question'],
          'options': poll['options'],
          'totalVotes': poll['totalVotes'],
          'societyId': poll['societyId'],
          'votedUsers': poll['votedUsers'],
          'postedBy': poll['postedBy'],
          'endDate': Timestamp.fromDate(poll['endDate'] as DateTime),
          'status': poll['status'],
        });
      }

      // 7. Seed Alerts
      final sampleAlerts = [
        {
          'id': 'alert_cidco_water',
          'title': 'CIDCO 24-Hr Water Supply Shutdown Notice',
          'description': 'CIDCO has announced emergency pipeline maintenance for Kharghar Sectors 18, 19 & 20 on Thursday from 9:00 AM to Friday 9:00 AM. Overhead society tanks will be filled to capacity tonight; please store water at home.',
          'type': 'urgent',
          'societyId': defaultSocietyId,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'readBy': [],
        },
        {
          'id': 'alert_lift_service',
          'title': 'Wing B Passenger Lift Servicing on Saturday',
          'description': 'Kone Elevators technicians will be carrying out quarterly safety audit and wire replacement for Lift #2 between 10:30 AM and 2:30 PM. Please use service lift during this period.',
          'type': 'maintenance',
          'societyId': defaultSocietyId,
          'timestamp': DateTime.now().subtract(const Duration(hours: 14)),
          'readBy': [],
        },
        {
          'id': 'alert_festive_decor',
          'title': 'Volunteers Invited for Prangan Festive Decoration',
          'description': 'Residents wishing to participate in the Diwali & Navratri flower rangoli decoration committee, please meet today at 8 PM near Clubhouse.',
          'type': 'notice',
          'societyId': defaultSocietyId,
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'readBy': [],
        },
      ];

      for (var al in sampleAlerts) {
        final id = al['id'] as String;
        await _firestore.collection('alerts').doc(id).set({
          'title': al['title'],
          'description': al['description'],
          'type': al['type'],
          'societyId': al['societyId'],
          'timestamp': Timestamp.fromDate(al['timestamp'] as DateTime),
          'readBy': al['readBy'],
        });
      }

      debugPrint('Kharghar demo society seeded successfully!');
    } catch (e) {
      debugPrint('Kharghar data init note: $e');
    }
  }

  /// Ensure demo items (Discussions, Events, Polls, Alerts) exist in Firestore for any society
  Future<void> seedSocietyDataIfEmpty(String societyId) async {
    if (societyId.isEmpty) return;
    try {
      // Check if posts exist for this society
      final postsSnap = await _firestore
          .collection('posts')
          .where('societyId', isEqualTo: societyId)
          .limit(1)
          .get();

      if (postsSnap.docs.isNotEmpty) {
        debugPrint('Society $societyId already has demo items.');
        return;
      }

      debugPrint('Seeding demo items for society $societyId into Firestore...');

      // 1. Seed Posts
      final demoPosts = [
        {
          'title': '💧 CIDCO Water Supply & Pressure Update',
          'description': 'CIDCO main line maintenance in Kharghar has concluded. Water supply in our building overhead tanks will be restored to full pressure by 7:30 PM. Please keep taps closed.',
          'authorUid': 'admin_desk',
          'authorName': 'Rajesh Patil (Secretary)',
          'authorFlat': 'Wing A-201',
          'category': 'Maintenance',
          'likes': ['user_1', 'user_2', 'user_3', 'user_4'],
          'commentCount': 3,
        },
        {
          'title': '☀️ Society Rooftop Solar Milestone: 4,500 Units!',
          'description': 'Our Kharghar residential green energy project generated 4,500 units of solar power this month, cutting common area electricity dues by 40%.',
          'authorUid': 'resident_sunil',
          'authorName': 'Sunil Deshmukh',
          'authorFlat': 'Wing B-501',
          'category': 'General',
          'likes': ['user_1', 'user_5'],
          'commentCount': 2,
        },
        {
          'title': '🎉 Navratri & Dandiya Night Pass Distribution',
          'description': 'Passes for Dandiya Raas Night and community dinner coupons are available for pickup at the Society Clubhouse Office today from 6:00 PM to 9:00 PM.',
          'authorUid': 'admin_desk',
          'authorName': 'Managing Committee',
          'authorFlat': 'Society Office',
          'category': 'Social',
          'likes': ['user_1', 'user_2', 'user_3', 'user_6', 'user_7'],
          'commentCount': 5,
        },
        {
          'title': '🚗 EV Charging Station Survey & Discussion',
          'description': 'We are gathering resident feedback regarding installing 4 dedicated EV charging stations in the visitor parking area. Drop your thoughts below!',
          'authorUid': 'resident_amit',
          'authorName': 'Amitabh Sharma',
          'authorFlat': 'Wing B-402',
          'category': 'General',
          'likes': ['user_2', 'user_4'],
          'commentCount': 1,
        },
      ];

      for (var i = 0; i < demoPosts.length; i++) {
        final p = demoPosts[i];
        final docRef = _firestore.collection('posts').doc('demo_post_${societyId}_$i');
        await docRef.set({
          'title': p['title'],
          'description': p['description'],
          'authorUid': p['authorUid'],
          'authorName': p['authorName'],
          'authorFlat': p['authorFlat'],
          'societyId': societyId,
          'category': p['category'],
          'likes': p['likes'],
          'commentCount': p['commentCount'],
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: (i + 1) * 3))),
        });

        // Add a sample comment
        await docRef.collection('comments').doc('c1').set({
          'authorUid': 'resident_vikram',
          'authorName': 'Vikram Joshi',
          'authorFlat': 'Wing C-103',
          'text': 'Great initiative and quick update! Thank you.',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 45))),
        });
      }

      // 2. Seed Events
      final demoEvents = [
        {
          'title': 'Grand Navratri Dandiya & Garba Mahotsav',
          'description': 'Traditional live orchestra, festive Gujarati snacks, dress competition for kids & adults.',
          'date': DateTime.now().add(const Duration(days: 3)),
          'time': '7:30 PM - 11:00 PM',
          'location': 'Central Amphitheatre & Lawns',
          'category': 'Festival',
          'interestedUsers': ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
        },
        {
          'title': 'Annual General Body Meeting (AGM 2026)',
          'description': 'Review of audited annual accounts, lift AMC renewal, and security agency performance review.',
          'date': DateTime.now().add(const Duration(days: 10)),
          'time': '10:30 AM - 1:00 PM',
          'location': 'Clubhouse Banquet Hall',
          'category': 'Meeting',
          'interestedUsers': ['user_1', 'user_3'],
        },
        {
          'title': 'Sunday Kharghar Hills Cyclothon & Jog',
          'description': 'Community fitness ride and walking session to Kharghar Hills viewpoint. Refreshments at finish line.',
          'date': DateTime.now().add(const Duration(days: 6)),
          'time': '6:00 AM - 8:00 AM',
          'location': 'Starting Point: Society Main Gate 1',
          'category': 'Sports',
          'interestedUsers': ['user_2', 'user_4', 'user_6'],
        },
      ];

      for (var i = 0; i < demoEvents.length; i++) {
        final ev = demoEvents[i];
        await _firestore.collection('events').doc('demo_ev_${societyId}_$i').set({
          'title': ev['title'],
          'description': ev['description'],
          'date': Timestamp.fromDate(ev['date'] as DateTime),
          'time': ev['time'],
          'location': ev['location'],
          'category': ev['category'],
          'societyId': societyId,
          'interestedUsers': ev['interestedUsers'],
        });
      }

      // 3. Seed Polls
      final demoPolls = [
        {
          'question': 'Install Automated RFID Fastag Boom Barriers at Main Gates?',
          'options': [
            {'id': 'opt_1', 'text': 'Yes, install RFID boom barriers', 'voteCount': 32},
            {'id': 'opt_2', 'text': 'No, maintain existing manual barrier', 'voteCount': 7},
            {'id': 'opt_3', 'text': 'Need more vendor cost estimates first', 'voteCount': 12},
          ],
          'totalVotes': 51,
          'postedBy': 'Managing Committee',
          'votedUsers': {'user_1': 'opt_1', 'user_2': 'opt_1'},
          'endDate': DateTime.now().add(const Duration(days: 5)),
          'status': 'active',
        },
        {
          'question': 'Extend Society Gymnasium Morning Timings from 5:30 AM?',
          'options': [
            {'id': 'opt_1', 'text': 'Yes, open early at 5:30 AM', 'voteCount': 41},
            {'id': 'opt_2', 'text': 'Keep current 6:30 AM opening', 'voteCount': 9},
          ],
          'totalVotes': 50,
          'postedBy': 'Sports & Fitness Committee',
          'votedUsers': {'user_3': 'opt_1'},
          'endDate': DateTime.now().add(const Duration(days: 2)),
          'status': 'active',
        },
      ];

      for (var i = 0; i < demoPolls.length; i++) {
        final poll = demoPolls[i];
        await _firestore.collection('polls').doc('demo_poll_${societyId}_$i').set({
          'question': poll['question'],
          'options': poll['options'],
          'totalVotes': poll['totalVotes'],
          'societyId': societyId,
          'votedUsers': poll['votedUsers'],
          'postedBy': poll['postedBy'],
          'endDate': Timestamp.fromDate(poll['endDate'] as DateTime),
          'status': poll['status'],
        });
      }

      // 4. Seed Alerts
      final demoAlerts = [
        {
          'title': 'CIDCO 24-Hr Water Supply Maintenance Notice',
          'description': 'CIDCO scheduled major pipeline maintenance for Kharghar sector on Thursday. Society overhead tanks are filled; please use water conservatively.',
          'type': 'urgent',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'readBy': [],
        },
        {
          'title': 'Wing B Passenger Lift Quarterly Servicing',
          'description': 'Kone Elevators technicians will be on-site Saturday from 10:30 AM to 2:30 PM for lift motor inspection. Please use service lift during this period.',
          'type': 'maintenance',
          'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
          'readBy': [],
        },
        {
          'title': 'Prangan Festive Decoration Committee Meeting',
          'description': 'Volunteers interested in planning flower rangoli and entrance lighting for upcoming festivals, please meet today at 8:00 PM near Clubhouse.',
          'type': 'notice',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'readBy': [],
        },
      ];

      for (var i = 0; i < demoAlerts.length; i++) {
        final al = demoAlerts[i];
        await _firestore.collection('alerts').doc('demo_alert_${societyId}_$i').set({
          'title': al['title'],
          'description': al['description'],
          'type': al['type'],
          'societyId': societyId,
          'timestamp': Timestamp.fromDate(al['timestamp'] as DateTime),
          'readBy': al['readBy'],
        });
      }

      debugPrint('Demo items for society $societyId successfully saved in Firebase!');
    } catch (e) {
      debugPrint('Error auto-seeding demo items for society $societyId: $e');
    }
  }
}
