import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Alert
  Future<String> createAlert({
    required String title,
    required String description,
    required String type, // 'urgent', 'maintenance', 'notice'
    required String societyId,
  }) async {
    try {
      final docRef = _firestore.collection('alerts').doc();
      final alert = AlertModel(
        id: docRef.id,
        title: title,
        description: description,
        type: type,
        societyId: societyId,
        timestamp: DateTime.now(),
        readBy: [],
      );

      await docRef.set(alert.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating alert: $e');
      rethrow;
    }
  }

  // Stream Alerts strictly filtered by societyId
  Stream<List<AlertModel>> getAlertsStream(String societyId) {
    return _firestore
        .collection('alerts')
        .where('societyId', isEqualTo: societyId)
        .snapshots()
        .map((snapshot) {
      final alerts = snapshot.docs.map((doc) {
        return AlertModel.fromMap(doc.data(), doc.id);
      }).toList();
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    });
  }

  // Mark single alert read
  Future<void> markAlertRead(String alertId, String uid) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'readBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      debugPrint('Error marking alert read: $e');
      rethrow;
    }
  }

  // Mark all alerts read for a society
  Future<void> markAllAlertsRead(String societyId, String uid) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('societyId', isEqualTo: societyId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        final alert = AlertModel.fromMap(doc.data(), doc.id);
        if (!alert.isReadBy(uid)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([uid]),
          });
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all alerts read: $e');
      rethrow;
    }
  }
}
