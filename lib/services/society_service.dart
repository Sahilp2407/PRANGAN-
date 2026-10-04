import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/society_model.dart';
import '../models/user_model.dart';

class SocietyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique join code e.g. "PRG4521"
  String generateJoinCode() {
    const chars = '0123456789';
    final random = Random();
    final numberPart = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    return 'PRG$numberPart';
  }

  // Create Society
  Future<SocietyModel> createSociety({
    required String name,
    required String address,
    required String sector,
    required String adminUid,
    required String adminName,
    required String adminPhone,
    required String adminFlat,
    required String adminBlock,
    String? logoUrl,
    int totalFlats = 100,
    int wingsCount = 2,
  }) async {
    try {
      final societyRef = _firestore.collection('societies').doc();
      final joinCode = generateJoinCode();

      final society = SocietyModel(
        id: societyRef.id,
        name: name,
        address: address,
        sector: sector,
        joinCode: joinCode,
        adminUid: adminUid,
        logoUrl: logoUrl,
        totalFlats: totalFlats,
        wingsCount: wingsCount,
        createdAt: DateTime.now(),
      );

      // Batch write to create society and add admin as member
      final batch = _firestore.batch();
      batch.set(societyRef, society.toMap());

      // Add admin to society members subcollection
      final adminMemberRef = societyRef.collection('members').doc(adminUid);
      final adminMemberData = {
        'name': adminName,
        'phone': adminPhone,
        'flatNumber': adminFlat,
        'block': adminBlock,
        'status': 'approved',
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      };
      batch.set(adminMemberRef, adminMemberData);

      // Update user doc
      final userRef = _firestore.collection('users').doc(adminUid);
      batch.set(userRef, {
        'societyId': societyRef.id,
        'status': 'approved',
        'role': 'admin',
        'flatNumber': adminFlat,
        'block': adminBlock,
      }, SetOptions(merge: true));

      await batch.commit();
      return society;
    } catch (e) {
      debugPrint('Error creating society: $e');
      rethrow;
    }
  }

  // Find Society by 6-character Join Code (e.g. "PRG4521")
  Future<SocietyModel?> findSocietyByJoinCode(String code) async {
    try {
      final cleanCode = code.trim().toUpperCase();
      final query = await _firestore
          .collection('societies')
          .where('joinCode', isEqualTo: cleanCode)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return SocietyModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error finding society by code: $e');
      return null;
    }
  }

  // Request to Join Society
  Future<void> requestToJoinSociety({
    required String societyId,
    required String uid,
    required String name,
    required String phone,
    required String flatNumber,
    required String block,
    required String role, // Owner or Tenant
  }) async {
    try {
      final batch = _firestore.batch();

      // Add to society members subcollection with 'pending' status
      final memberRef = _firestore
          .collection('societies')
          .doc(societyId)
          .collection('members')
          .doc(uid);

      batch.set(memberRef, {
        'name': name,
        'phone': phone,
        'flatNumber': flatNumber,
        'block': block,
        'status': 'pending',
        'role': role,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update user document
      final userRef = _firestore.collection('users').doc(uid);
      batch.set(userRef, {
        'societyId': societyId,
        'status': 'pending',
        'role': role,
        'flatNumber': flatNumber,
        'block': block,
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      debugPrint('Error requesting to join society: $e');
      rethrow;
    }
  }

  // Real-time listener for member approval on Pending Approval screen
  Stream<String> listenMemberStatus(String societyId, String uid) {
    return _firestore
        .collection('societies')
        .doc(societyId)
        .collection('members')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['status'] as String? ?? 'pending';
      }
      return 'pending';
    });
  }

  // Stream pending member requests for Admin Approval screen
  Stream<List<UserModel>> getPendingMembersStream(String societyId) {
    return _firestore
        .collection('societies')
        .doc(societyId)
        .collection('members')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Approve Member
  Future<void> approveMember(String societyId, String uid) async {
    try {
      final batch = _firestore.batch();

      final memberRef = _firestore
          .collection('societies')
          .doc(societyId)
          .collection('members')
          .doc(uid);
      batch.set(memberRef, {'status': 'approved'}, SetOptions(merge: true));

      final userRef = _firestore.collection('users').doc(uid);
      batch.set(userRef, {'status': 'approved'}, SetOptions(merge: true));

      await batch.commit();

      // If uid was temp_resident_uid, also find and approve the actual user by phone
      if (uid == 'temp_resident_uid') {
        try {
          final memberDoc = await memberRef.get();
          final phone = memberDoc.data()?['phone'] as String?;
          if (phone != null && phone.isNotEmpty) {
            final userQuery = await _firestore
                .collection('users')
                .where('phone', isEqualTo: phone)
                .limit(1)
                .get();
            for (var uDoc in userQuery.docs) {
              await uDoc.reference.set({'status': 'approved'}, SetOptions(merge: true));
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error approving member: $e');
      rethrow;
    }
  }

  // Reject Member
  Future<void> rejectMember(String societyId, String uid) async {
    try {
      final batch = _firestore.batch();

      final memberRef = _firestore
          .collection('societies')
          .doc(societyId)
          .collection('members')
          .doc(uid);
      batch.update(memberRef, {'status': 'rejected'});

      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {'status': 'rejected'});

      await batch.commit();
    } catch (e) {
      debugPrint('Error rejecting member: $e');
      rethrow;
    }
  }

  // Get Society by ID
  Future<SocietyModel?> getSociety(String societyId) async {
    try {
      final doc = await _firestore.collection('societies').doc(societyId).get();
      if (doc.exists && doc.data() != null) {
        return SocietyModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting society: $e');
      return null;
    }
  }

  // Stream Society by ID
  Stream<SocietyModel?> streamSociety(String societyId) {
    return _firestore.collection('societies').doc(societyId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return SocietyModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
